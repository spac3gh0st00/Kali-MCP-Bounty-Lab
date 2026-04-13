#!/usr/bin/env bash
# =============================================================================
#  KaliBot — Kali MCP Bounty Lab  |  Ubuntu VM Installer
#  https://github.com/spac3gh0st00/Kali-MCP-Bounty-Lab
#
#  Run as your normal (non-root) user inside the Ubuntu VM:
#    chmod +x install.sh && ./install.sh
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${CYAN}[*]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
error()   { echo -e "${RED}[✗]${NC} $*"; exit 1; }
header()  { echo -e "\n${BOLD}${CYAN}━━━ $* ━━━${NC}"; }

# ── Sanity checks ─────────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && error "Do NOT run this as root. Run as your normal user."
command -v lsb_release &>/dev/null || sudo apt-get install -y -q lsb-release

OS=$(lsb_release -si)
[[ "$OS" == "Ubuntu" ]] || warn "Tested on Ubuntu 24.04 — your OS is $OS, YMMV."

INSTALL_DIR="$HOME/kali-mcp"
VENV_DIR="$INSTALL_DIR/venv"
SERVICE_USER="$USER"

# ═════════════════════════════════════════════════════════════════════════════
header "Step 1 — Collect secrets"
# ═════════════════════════════════════════════════════════════════════════════
echo ""
echo "  You'll need four values. Press Enter to skip any you don't have yet"
echo "  (you can fill them in later by editing $INSTALL_DIR/.env)."
echo ""

read -rp "  Discord Bot Token           : " DISCORD_TOKEN
read -rp "  Discord Allowed User ID     : " ALLOWED_USER_ID
read -rp "  Anthropic API Key (sk-ant-…): " ANTHROPIC_API_KEY
read -rp "  Discord Webhook URL         : " DISCORD_WEBHOOK_URL

# ═════════════════════════════════════════════════════════════════════════════
header "Step 2 — System update & base packages"
# ═════════════════════════════════════════════════════════════════════════════
info "Updating package lists…"
sudo apt-get update -q

info "Installing prerequisites…"
sudo apt-get install -y -q \
    ca-certificates curl gnupg lsb-release git \
    python3 python3-pip python3.12-venv ufw

success "Base packages ready."

# ═════════════════════════════════════════════════════════════════════════════
header "Step 3 — Docker Engine"
# ═════════════════════════════════════════════════════════════════════════════
if command -v docker &>/dev/null; then
    success "Docker already installed ($(docker --version | head -1))."
else
    info "Adding Docker's official GPG key and repo…"
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # printf avoids any shell continuation whitespace leaking into the deb line
    printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu %s stable\n' \
        "$(dpkg --print-architecture)" "$(lsb_release -cs)" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -q
    sudo apt-get install -y -q \
        docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin

    success "Docker installed."
fi

# Add current user to docker group (permanent after re-login; sg handles this session)
if ! groups "$USER" | grep -q docker; then
    info "Adding $USER to the docker group…"
    sudo usermod -aG docker "$USER"
    warn "Docker group added. The installer uses 'sg docker' so it works right now,"
    warn "but future terminals will need a re-login or 'newgrp docker'."
fi

# ═════════════════════════════════════════════════════════════════════════════
header "Step 4 — Clone kali-mcp repository"
# ═════════════════════════════════════════════════════════════════════════════
if [[ -d "$INSTALL_DIR/.git" ]]; then
    info "Repo already exists at $INSTALL_DIR — pulling latest…"
    git -C "$INSTALL_DIR" pull
else
    info "Cloning into $INSTALL_DIR…"
    git clone https://github.com/k3nn3dy-ai/kali-mcp.git "$INSTALL_DIR"
fi
success "Repo ready at $INSTALL_DIR"

# ═════════════════════════════════════════════════════════════════════════════
header "Step 5 — Create .env file"
# ═════════════════════════════════════════════════════════════════════════════
ENV_FILE="$INSTALL_DIR/.env"

if [[ -f "$ENV_FILE" ]]; then
    warn ".env already exists — backing up to .env.bak"
    cp "$ENV_FILE" "${ENV_FILE}.bak"
fi

cat > "$ENV_FILE" <<EOF
DISCORD_TOKEN=${DISCORD_TOKEN}
ALLOWED_USER_ID=${ALLOWED_USER_ID}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
EOF

chmod 600 "$ENV_FILE"
echo ".env" >> "$HOME/.gitignore" 2>/dev/null || true
success ".env written with permissions 600."

# ═════════════════════════════════════════════════════════════════════════════
header "Step 6 — Build & start the Kali Docker container"
# ═════════════════════════════════════════════════════════════════════════════
cd "$INSTALL_DIR"

info "Building Docker image (this can take 10–20 min on first run)…"
# sg runs docker commands under the docker group without requiring a re-login
sg docker -c "docker compose build"

info "Starting container in detached mode…"
sg docker -c "docker compose up -d"

info "Waiting for container to initialise…"
sleep 6
sg docker -c "docker ps --filter name=kali-mcp-server --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

# ── Install supplementary tools inside the container ─────────────────────────
info "Installing supplementary tools inside the container…"
sg docker -c "
docker exec kali-mcp-server bash -c '
apt-get update -q &&
apt-get install -y -q dirb exploitdb wordlists &&
if ! command -v testssl.sh &>/dev/null; then
    curl -sfo /usr/local/bin/testssl.sh \
        https://raw.githubusercontent.com/drwetter/testssl.sh/3.2/testssl.sh &&
    chmod +x /usr/local/bin/testssl.sh
fi
'
" || warn "Supplementary tool install had errors — run it manually if tools are missing."

# ═════════════════════════════════════════════════════════════════════════════
header "Step 7 — Python virtual environment"
# ═════════════════════════════════════════════════════════════════════════════
info "Creating venv at $VENV_DIR…"
python3 -m venv "$VENV_DIR"

info "Installing Python dependencies…"
"$VENV_DIR/bin/pip" install --quiet --upgrade pip
"$VENV_DIR/bin/pip" install --quiet \
    "discord.py" httpx python-dotenv anthropic requests

success "Python environment ready."

# ═════════════════════════════════════════════════════════════════════════════
header "Step 8 — /health endpoint check"
# ═════════════════════════════════════════════════════════════════════════════
info "Checking /health endpoint…"
sleep 2
if curl -sf http://localhost:8000/health | grep -q healthy; then
    success "/health endpoint is up."
else
    warn "Could not reach http://localhost:8000/health."
    warn "If server.py doesn't have the /health route, follow the README to add it,"
    warn "then run: cd $INSTALL_DIR && docker compose build && docker compose up -d"
fi

# ═════════════════════════════════════════════════════════════════════════════
header "Step 9 — UFW firewall rules"
# ═════════════════════════════════════════════════════════════════════════════
# Try default route src first, fall back to first non-loopback address.
# || true inside $(...) prevents set -e from firing when grep finds no match.
VM_IP_RAW=$(ip -4 route show default | grep -oP '(?<=src )\d+\.\d+\.\d+\.\d+' | head -1 || true)
if [[ -z "$VM_IP_RAW" ]]; then
    VM_IP_RAW=$(hostname -I | tr ' ' '\n' | grep -v '^127\.' | head -1 || true)
fi
if [[ -z "$VM_IP_RAW" ]]; then
    error "Could not determine VM IP. Set VM_SUBNET manually and re-run from Step 9."
fi
VM_SUBNET=$(echo "$VM_IP_RAW" | sed 's/\.[0-9]*$/.0\/24/')
info "Detected VM subnet: $VM_SUBNET  (from IP $VM_IP_RAW)"

sudo ufw allow 22/tcp comment "SSH"
sudo ufw allow from "$VM_SUBNET" to any port 8000 comment "Kali MCP (LAN only)"
sudo ufw --force enable
success "UFW rules applied."
sudo ufw status

# ═════════════════════════════════════════════════════════════════════════════
header "Step 10 — systemd service: discord-kali-bot"
# ═════════════════════════════════════════════════════════════════════════════
sudo tee /etc/systemd/system/discord-kali-bot.service > /dev/null <<EOF
[Unit]
Description=Discord Kali MCP Bot
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=${SERVICE_USER}
WorkingDirectory=${INSTALL_DIR}
EnvironmentFile=${INSTALL_DIR}/.env
ExecStartPre=/bin/sleep 10
ExecStart=${VENV_DIR}/bin/python3 ${INSTALL_DIR}/discord_kali_bot.py
Restart=on-failure
RestartSec=10
NoNewPrivileges=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable discord-kali-bot
sudo systemctl start discord-kali-bot
success "discord-kali-bot service enabled and started."

# ═════════════════════════════════════════════════════════════════════════════
header "Step 11 — systemd service: kalibot-monitor"
# ═════════════════════════════════════════════════════════════════════════════
sudo tee /etc/systemd/system/kalibot-monitor.service > /dev/null <<EOF
[Unit]
Description=KaliBot Health Monitor
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=${SERVICE_USER}
WorkingDirectory=${INSTALL_DIR}
EnvironmentFile=${INSTALL_DIR}/.env
ExecStartPre=/bin/sleep 10
ExecStart=${VENV_DIR}/bin/python3 ${INSTALL_DIR}/health_monitor.py
Restart=always
RestartSec=10
NoNewPrivileges=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable kalibot-monitor
sudo systemctl start kalibot-monitor
success "kalibot-monitor service enabled and started."

# ═════════════════════════════════════════════════════════════════════════════
header "Step 12 — Docker container auto-restart on boot"
# ═════════════════════════════════════════════════════════════════════════════
sg docker -c "docker update --restart unless-stopped kali-mcp-server" 2>/dev/null \
    || warn "Could not set restart policy — run: docker update --restart unless-stopped kali-mcp-server"
success "Container restart policy set."

# ═════════════════════════════════════════════════════════════════════════════
header "Summary"
# ═════════════════════════════════════════════════════════════════════════════
VM_IP=$(hostname -I | awk '{print $1}')

echo ""
echo -e "${BOLD}Ubuntu VM side — complete.${NC}"
echo ""
echo "  Install dir  : $INSTALL_DIR"
echo "  Venv         : $VENV_DIR"
echo "  .env         : $ENV_FILE  (chmod 600)"
echo "  VM IP        : $VM_IP"
echo ""
# Check enabled (not active) — services have a 10s ExecStartPre delay so
# they'll be in "activating" state immediately after install, not "active" yet.
echo -e "${BOLD}Services (allow ~10s for startup delay):${NC}"
systemctl is-enabled --quiet discord-kali-bot \
    && echo -e "  ${GREEN}✓${NC} discord-kali-bot   enabled (starting…)" \
    || echo -e "  ${RED}✗${NC} discord-kali-bot   NOT enabled — check: sudo journalctl -u discord-kali-bot -n 30"
systemctl is-enabled --quiet kalibot-monitor \
    && echo -e "  ${GREEN}✓${NC} kalibot-monitor    enabled (starting…)" \
    || echo -e "  ${RED}✗${NC} kalibot-monitor    NOT enabled — check: sudo journalctl -u kalibot-monitor -n 30"
echo "  Live status: sudo systemctl status discord-kali-bot kalibot-monitor"
echo ""
sg docker -c "docker ps --filter name=kali-mcp-server --format '  Container: {{.Names}} — {{.Status}}'" 2>/dev/null || true

echo ""
echo -e "${BOLD}Remaining manual steps (Windows side):${NC}"
echo ""
echo "  1. Copy windows_setup.ps1 to your Windows machine or VM"
echo ""
echo "  2. Open PowerShell as Administrator and run:"
echo "       Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
echo "       .\\windows_setup.ps1"
echo ""
echo "     The script handles everything automatically:"
echo "     Node.js, mcp-remote, Claude Desktop, portproxy, firewall, MCP config"
echo ""
echo "  3. When prompted, enter this VM's IP: $VM_IP"
echo ""
echo "  4. Restart Claude Desktop when the script finishes."
echo ""
echo -e "${YELLOW}⚠  Authorised testing only. Hunt legally, hunt responsibly.${NC}"
echo ""

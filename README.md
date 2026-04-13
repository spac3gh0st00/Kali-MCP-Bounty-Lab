# 🤖 KaliBot — AI-Powered Bug Bounty Lab

**Kali MCP · Claude Desktop · Discord Recon Agent · Server Health Notifications**

*A complete home security lab that connects Claude Desktop to a Kali Linux Docker container running inside an Ubuntu VM on VMware — with a secure Discord bot, autonomous AI recon agent, and real-time server health monitoring built for bug bounty research and security learning.*

---

[![Platform](https://img.shields.io/badge/platform-Windows%20%2B%20VMware%20%2B%20Ubuntu%20%2B%20Docker-0d1117?style=for-the-badge&logo=vmware&logoColor=white)](https://github.com/spac3gh0st00/Kali-MCP-Bounty-Lab/blob/main)
[![Claude](https://img.shields.io/badge/Claude-Desktop-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://claude.ai/download)
[![Kali](https://img.shields.io/badge/Kali-Linux-557C94?style=for-the-badge&logo=kalilinux&logoColor=white)](https://www.kali.org/)
[![Discord](https://img.shields.io/badge/Discord-Recon%20Agent-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://github.com/spac3gh0st00/Kali-MCP-Bounty-Lab/blob/main)
[![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://github.com/spac3gh0st00/Kali-MCP-Bounty-Lab/blob/main)
[![Docker](https://img.shields.io/badge/Docker-Containerised-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://github.com/spac3gh0st00/Kali-MCP-Bounty-Lab/blob/main)
[![License](https://img.shields.io/badge/License-MIT-22c55e?style=for-the-badge)](https://github.com/spac3gh0st00/Kali-MCP-Bounty-Lab/blob/main/LICENSE)
[![Ethics](https://img.shields.io/badge/Use-Authorised%20Testing%20Only-ef4444?style=for-the-badge)](https://github.com/spac3gh0st00/Kali-MCP-Bounty-Lab/blob/main)

---

## 📌 Overview

KaliBot is a complete home security research lab that bridges **Claude Desktop** on Windows with a **fully containerised Kali Linux environment** running inside an Ubuntu VM on VMware. It gives you natural language control over 35 professional penetration testing tools, live Discord alerts for every recon event and server status change, and an autonomous AI agent that plans and executes full recon pipelines on your behalf.

> ⚠️ **Authorised use only.** This lab is designed for bug bounty programs you are enrolled in, CTF challenges, and systems you own or have explicit written permission to test.

---

## ⚡ Quick Install

Two scripts handle the entire setup automatically. Run them in their respective environments and the lab is ready.

> **Note:** Both scripts can be run inside VMs. If you want a fully isolated setup, run `windows_setup.ps1` inside a **Windows VM** and `install.sh` inside an **Ubuntu VM** — just make sure both VMs are on the same VMware network adapter (both NAT or both Host-Only) so they can reach each other.

---

### 🐧 Ubuntu VM — `install.sh`

Handles everything on the Linux side in one shot:

- Installs Docker Engine and adds your user to the docker group
- Clones the [kali-mcp](https://github.com/k3nn3dy-ai/kali-mcp) repo
- Prompts for your secrets and writes `.env` with `chmod 600`
- Builds the Kali Docker image and installs all 35 tools
- Creates the Python virtual environment and installs all dependencies
- Configures UFW firewall rules (auto-detects your subnet)
- Installs and enables both systemd services (`discord-kali-bot` + `kalibot-monitor`)
- Sets the container to auto-restart on boot

```bash
chmod +x install.sh && ./install.sh
```

> Run as your normal user — **not root**. The script uses `sudo` internally where needed.

**You will be prompted for:**

| Value | Where to get it |
|---|---|
| Discord Bot Token | [discord.com/developers/applications](https://discord.com/developers/applications) → Bot → Reset Token |
| Discord Allowed User ID | Discord Settings → Advanced → Developer Mode → right-click your name → Copy User ID |
| Anthropic API Key | [console.anthropic.com](https://console.anthropic.com) |
| Discord Webhook URL | Discord channel → Edit Channel → Integrations → Webhooks → New Webhook |

Press Enter to skip any value and fill it in later by editing `~/kali-mcp/.env`.

---

### 🪟 Windows / Windows VM — `windows_setup.ps1`

Handles everything on the Windows side:

- Checks for Hyper-V conflicts and offers to disable the hypervisor
- Creates the `netsh portproxy` rule (`localhost:8000 → Ubuntu VM:8000`)
- Adds a Windows Firewall inbound rule for port 8000
- Checks for Node.js and installs `mcp-remote` globally
- Writes (or merges into) `claude_desktop_config.json` — existing MCP servers are preserved
- Runs a live connectivity test against `/health`

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\windows_setup.ps1
```

> When prompted, enter the Ubuntu VM's IP address (run `hostname -I` inside the Ubuntu VM to get it).

---

### ✅ After both scripts complete

1. Restart Claude Desktop (system tray → right-click → **Quit**, then relaunch)
2. Click **+** in the Claude chat input → **Connectors** → you should see **kali** with a blue toggle
3. Ask Claude: *"Can you run a quick nmap scan on 127.0.0.1?"*

---

## 🏗️ Architecture

```
Windows Host or Windows VM (Claude Desktop)
        │
        │ mcp-remote (stdio → SSE bridge)
        │
   localhost:8000
        │
   netsh portproxy
        │
  192.168.x.x:8000
        │
   Ubuntu VM (VMware)
        │
      Docker
        │
  Kali Linux Container (35 tools + /health endpoint)
        │
        ├──────────────────────────────────────┐
        │                                      │
  Discord Bot (Ubuntu VM)           Health Monitor (Ubuntu VM)
        │                                      │
        │ /investigate, /generate_report       │ polls /health every 10s
        │                                      │ sends UP/DOWN Discord alerts
        ▼                                      ▼
  Anthropic API (Claude AI)         Discord Webhook
  Plans tools → runs them           Status embeds in your channel
  → writes full report
        │
  Discord slash commands
        │
  Phone / any Tailscale device
```

---

## ✨ Features

|  |  |
| --- | --- |
| 🔁 **Claude Desktop MCP Integration** <br> • Natural language → Kali tool execution <br> • 35 security tools exposed via MCP protocol <br> • Full tool output returned to Claude's context <br> • No CLI flags to memorise <br><br> 🤖 **Autonomous AI Recon Agent** <br> • `/investigate` — plans, runs, and interprets recon automatically <br> • Chains up to 8 tool calls per session <br> • `/generate_report` — reads all scan files and writes a full bug bounty report <br> • Powered by Anthropic Claude API <br><br> 🔔 **Real-Time Health Notifications** <br> • `/health` endpoint on the MCP server <br> • Health monitor polls every 10 seconds <br> • Discord embeds on UP / DOWN / DEGRADED <br> • Auto-starts as a systemd service on boot | 🤖 **Discord Recon Agent** <br> • 24 slash commands for remote recon <br> • Ephemeral responses — only you see output <br> • User ID + server ID whitelist <br> • Dangerous tools blocked from Discord <br> • Full audit log of every command <br><br> 🔐 **Security-First Design** <br> • UFW firewall restricts port 8000 to VM subnet <br> • Docker provides container isolation <br> • `.env` permissions locked to `600` <br> • No secrets hardcoded anywhere <br> • All credentials loaded from `.env` only <br><br> 📱 **Remote Access via Tailscale** <br> • Access your lab from your phone anywhere <br> • WireGuard encrypted — no open internet ports <br> • Full Kali shell via Termius on iOS/Android |

---

## 📋 Prerequisites

| Requirement | Notes |
| --- | --- |
| Windows 10/11 64-bit (or Windows VM) | Host machine or VM for Claude Desktop |
| VMware Workstation 17 Pro | For running Ubuntu VM |
| Ubuntu 24.04 LTS ISO | [Download here](https://ubuntu.com/download/desktop) |
| Claude Desktop (direct installer) | [Download here](https://claude.ai/download) — **not** the Microsoft Store version |
| Node.js LTS | [Download here](https://nodejs.org) — handled by `windows_setup.ps1` |
| Anthropic API Key | [Get one here](https://console.anthropic.com) — $5 credit lasts weeks |
| ~60GB free disk space | For VM + Docker image |
| 8GB+ RAM | Minimum for stable VM |

> **Important:** Use the direct Claude Desktop installer, not the Microsoft Store version. The Store version does not support remote MCP connections.

---

## 🗂️ Repository Structure

```
Kali-MCP-Bounty-Lab/
│
├── install.sh             # ← One-shot Ubuntu VM installer
├── windows_setup.ps1      # ← One-shot Windows host/VM setup
│
└── README.md              # This file
```

The Kali MCP server code lives in the upstream repo this lab is built on:

```
kali-mcp/  (cloned to ~/kali-mcp by install.sh)
│
├── kali_mcp_server/
│   ├── server.py          # MCP server — SSE transport, /health endpoint, all routes
│   ├── tools.py           # All 35 tool implementations
│   ├── __main__.py
│   └── __init__.py
│
├── discord_kali_bot.py    # Discord slash command bot
├── investigate.py         # AI recon agent + report writer
├── health_monitor.py      # Server health watcher → Discord alerts
├── main.py                # Entry point
├── install_check.py       # Dependency checker
│
├── .env                   # Secrets (never commit this)
├── .env.example           # Safe template
├── docker-compose.yml     # Container definition
├── Dockerfile             # Kali image
└── requirements.txt       # Python dependencies
```

---

## 🚀 Manual Setup Guide

> The scripts above handle all of the below automatically. This section is kept as a reference for troubleshooting or if you prefer to set things up step by step.

### Part 1 — Create the Ubuntu VM in VMware

**Step 1 — Create a new VM**

1. Open VMware Workstation → **Create a New Virtual Machine**
2. Select **Typical** → Next
3. Select your Ubuntu 24.04 ISO → Next
4. Set your username and password → Next
5. Click **Customize Hardware** before finishing

**Step 2 — Configure VM hardware**

| Setting | Value |
| --- | --- |
| Memory | 8192 MB minimum |
| Processors | 4 cores |
| Network Adapter | NAT |
| Disk | 60GB minimum |

**Step 3 — VMware nested virtualization note**

If you see a warning about "Virtualize AMD-V/RVI" not being supported, click **Yes** to continue without it. Docker on native Linux does not require nested virtualization — it uses kernel namespaces and cgroups directly.

If VMware refuses to start due to Hyper-V conflicts:

```bash
# Run in PowerShell as Administrator
bcdedit /set hypervisorlaunchtype off
# Restart your machine after running this
```

**Step 4 — Install Ubuntu**

1. Power on the VM
2. Choose **Normal installation**
3. Choose **Erase disk and install Ubuntu** (safe — inside the VM only)
4. Complete setup and reboot

---

### Part 2 — Install Docker Inside Ubuntu VM

**Step 5 — Update the system**

```bash
sudo apt update && sudo apt upgrade -y
```

**Step 6 — Install Docker Engine**

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu %s stable\n' \
    "$(dpkg --print-architecture)" "$(lsb_release -cs)" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**Step 7 — Add your user to the Docker group**

```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Step 8 — Verify Docker works**

```bash
docker run hello-world
# Should print: Hello from Docker!
```

---

### Part 3 — Set Up the Kali MCP Server

**Step 9 — Clone the repository**

```bash
sudo apt install -y git
git clone https://github.com/k3nn3dy-ai/kali-mcp.git
cd kali-mcp
```

**Step 10 — Build the Docker image**

> Downloads the Kali base image and installs 35 security tools. Takes 10–20 minutes on first run.

```bash
docker compose build
```

**Step 11 — Start the container**

```bash
docker compose up -d

# Verify it is running
docker ps
# Should show: kali-mcp-server  Up  0.0.0.0:8000->8000/tcp

# Check logs
docker logs kali-mcp-server
```

**Step 11b — Install missing tools inside the container**

```bash
docker exec -it kali-mcp-server bash -c "
apt-get update -q &&
apt-get install -y dirb exploitdb wordlists &&
curl -o /usr/local/bin/testssl.sh https://raw.githubusercontent.com/drwetter/testssl.sh/3.2/testssl.sh &&
chmod +x /usr/local/bin/testssl.sh
"
```

---

### Part 4 — Configure Networking

**Step 12 — Get the VM's IP address**

```bash
hostname -I
# Returns something like 192.168.91.132 — write this down
```

**Step 13 — Tighten the UFW firewall (Ubuntu)**

```bash
sudo ufw allow 22/tcp
sudo ufw allow from 192.168.91.0/24 to any port 8000
sudo ufw enable
sudo ufw status
```

**Step 14 — Set up port proxy on Windows**

Open **PowerShell as Administrator**:

```powershell
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8000 connectaddress=192.168.91.132 connectport=8000

# Verify
netsh interface portproxy show all
# Should show: 127.0.0.1:8000 -> 192.168.x.x:8000
```

Test in your Windows browser — `http://localhost:8000/sse` should return:

```
event: endpoint
data: /messages/?session_id=...
```

---

### Part 5 — Configure Claude Desktop

**Step 15 — Install mcp-remote on Windows**

```powershell
npm install -g mcp-remote
where.exe mcp-remote
```

**Step 16 — Edit Claude Desktop config**

File location: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "kali": {
      "command": "mcp-remote",
      "args": [
        "http://localhost:8000/sse"
      ]
    }
  }
}
```

**Step 17 — Restart Claude Desktop**

1. Find Claude in the system tray → right-click → **Quit**
2. Relaunch from Start menu

**Step 18 — Verify connection**

1. Click the **+** button in the chat input → **Connectors**
2. You should see **kali** listed with a blue toggle

---

### Part 6 — Remote Access via Tailscale (Optional)

**Step 19 — Install Tailscale**

- **Windows:** https://tailscale.com/download/windows
- **Ubuntu VM:**

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

- **Phone:** Download Tailscale from App Store / Play Store
- Sign into the **same Tailscale account** on all devices

**Step 20 — Enable SSH on Ubuntu**

```bash
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

**Step 21 — Connect from phone**

Install **Termius** (iOS/Android):

| Field | Value |
| --- | --- |
| Hostname | Ubuntu VM's Tailscale IP (100.x.x.x) |
| Username | your Ubuntu username |
| Port | 22 |

---

### Part 7 — Discord Bot

**Step 22 — Create the Discord application**

1. Go to https://discord.com/developers/applications → **New Application**
2. Navigate to **Bot** → **Reset Token** → copy and save your token
3. Enable **Message Content Intent** under Privileged Gateway Intents
4. Go to **OAuth2 → URL Generator** → scopes: `bot`, `applications.commands`
5. Bot permissions: `Send Messages`, `Use Slash Commands`
6. Open the generated URL → invite bot to your **private server**

**Step 23 — Get your Discord IDs**

Enable Developer Mode: Discord → Settings → Advanced → Developer Mode

- **User ID:** right-click your username → Copy User ID
- **Server ID:** right-click your server name → Copy Server ID

**Step 24 — Create the environment file**

```bash
nano ~/kali-mcp/.env
```

```
DISCORD_TOKEN=your_bot_token_here
ALLOWED_USER_ID=your_discord_user_id_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE
```

```bash
chmod 600 ~/kali-mcp/.env
echo ".env" >> ~/.gitignore
```

**Step 25 — Set up Python virtual environment**

```bash
sudo apt install python3.12-venv -y
python3 -m venv ~/kali-mcp/venv
source ~/kali-mcp/venv/bin/activate
pip install discord.py httpx python-dotenv anthropic requests
```

**Step 26 — Install Discord bot as a background service**

```bash
sudo nano /etc/systemd/system/discord-kali-bot.service
```

```ini
[Unit]
Description=Discord Kali MCP Bot
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/home/YOUR_USERNAME/kali-mcp
EnvironmentFile=/home/YOUR_USERNAME/kali-mcp/.env
ExecStartPre=/bin/sleep 10
ExecStart=/home/YOUR_USERNAME/kali-mcp/venv/bin/python3 /home/YOUR_USERNAME/kali-mcp/discord_kali_bot.py
Restart=on-failure
RestartSec=10
NoNewPrivileges=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable discord-kali-bot
sudo systemctl start discord-kali-bot
```

---

### Part 8 — AI Recon Agent

**`/investigate` — Autonomous Recon Agent**

```
/investigate target:example.com depth:standard
```

| Depth | Tool calls | Best for |
| --- | --- | --- |
| `quick` | 3–4 | Fast initial look |
| `standard` | 5–6 | Normal recon |
| `thorough` | up to 8 | Deep investigation |

Cost: ~$0.05–0.15 per investigation

**`/generate_report` — Session Report Writer**

```
/generate_report
```

Reads all scan output `.txt` files, sends them to Claude, and produces a structured bug bounty report with executive summary, severity-rated findings, attack surface map, and recommended next steps.

Cost: ~$0.03–0.10 per report

---

### Part 9 — Server Health Notification System

**Step 27 — Add the `/health` endpoint to the MCP server**

Run this script — it patches `server.py` automatically, then rebuilds and verifies the endpoint:

```bash
cd ~/kali-mcp
docker compose down

python3 - << 'EOF'
import re

path = 'kali_mcp_server/server.py'
content = open(path).read()

health_func = '''
async def health_check(request):
    from starlette.responses import JSONResponse
    return JSONResponse({"status": "healthy", "service": "kali-mcp"})

'''

content = content.replace(
    'Route("/sse"',
    'Route("/health", endpoint=health_check),\n        Route("/sse"'
)

content = content.replace(
    'async def handle_sse_connection',
    health_func + 'async def handle_sse_connection'
)

open(path, 'w').write(content)
print("server.py patched successfully")
EOF

docker compose build
docker compose up -d
sleep 5
curl -s http://localhost:8000/health
# Expected: {"status":"healthy","service":"kali-mcp"}
```

> If you prefer to edit manually: add a `health_check` function that returns `JSONResponse({"status": "healthy", "service": "kali-mcp"})` above `handle_sse_connection` in `server.py`, then add `Route("/health", endpoint=health_check)` as the first entry in the Starlette routes list.

**Step 28 — Install kalibot-monitor as a background service**

```bash
sudo nano /etc/systemd/system/kalibot-monitor.service
```

```ini
[Unit]
Description=KaliBot Health Monitor
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/home/YOUR_USERNAME/kali-mcp
EnvironmentFile=/home/YOUR_USERNAME/kali-mcp/.env
ExecStartPre=/bin/sleep 10
ExecStart=/home/YOUR_USERNAME/kali-mcp/venv/bin/python3 /home/YOUR_USERNAME/kali-mcp/health_monitor.py
Restart=always
RestartSec=10
NoNewPrivileges=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable kalibot-monitor
sudo systemctl start kalibot-monitor
```

---

## 💬 Discord Slash Commands

| Command | Description |
| --- | --- |
| `/investigate` | AI agent — autonomously chains tools and writes a full report |
| `/generate_report` | AI reads active session scan files and writes a bug bounty report |
| `/port_scan` | Nmap with presets (quick/full/stealth/service/aggressive) |
| `/dns_enum` | Full DNS enumeration with zone transfer attempts |
| `/subdomain_enum` | Subdomain discovery via subfinder + amass |
| `/network_discovery` | Multi-stage network recon |
| `/recon_auto` | Full automated recon pipeline (quick/standard/deep) |
| `/web_enum` | Web directory and endpoint discovery |
| `/web_audit` | Comprehensive web application security audit |
| `/header_analysis` | HTTP security header analysis |
| `/ssl_analysis` | SSL/TLS security assessment |
| `/spider` | Web crawling and spidering |
| `/form_analysis` | Web form discovery and analysis |
| `/vuln_scan` | Automated vulnerability assessment |
| `/exploit_search` | Search known exploits via searchsploit |
| `/enum_shares` | SMB/NFS share enumeration |
| `/hash_identify` | Identify hash types (MD5, SHA, bcrypt, NTLM...) |
| `/encode` | Base64/URL/hex/HTML/rot13 encoding |
| `/fetch_url` | Fetch and analyze web content |
| `/session_create` | Create a new pentest session |
| `/session_status` | Show current session status |
| `/session_list` | List all pentest sessions |
| `/session_history` | Show command history |
| `/create_report` | Generate a report with custom findings text |

---

## 🛠️ Available Tools (35 total)

| Category | Tools |
| --- | --- |
| Port scanning | nmap (with presets: quick, full, stealth, udp, service, aggressive) |
| DNS | dnsenum, dig, host |
| Web | nikto, gobuster, dirb, whatweb, ffuf |
| SQL injection | sqlmap |
| Password cracking | john, hashcat |
| Brute force | hydra |
| SSL/TLS | sslscan, testssl.sh, openssl |
| Wireless | aircrack-ng |
| Exploitation | metasploit-framework, searchsploit |
| Recon | subfinder, amass, sublist3r, whois |

---

## 🔐 Security Model

| Item | Detail |
| --- | --- |
| UFW firewall | Port 8000 restricted to `192.168.x.0/24` — not exposed to internet |
| Docker isolation | Container has no access to host filesystem or network stack |
| netsh portproxy | Windows-side proxy scoped to `127.0.0.1` only |
| `.env` permissions | `chmod 600` — only your user account can read secrets |
| No hardcoded secrets | All credentials loaded from `.env` via `os.getenv()` |
| Discord user ID whitelist | Only your account can trigger any command |
| Discord server ID lock | Commands silently fail in any other server |
| Ephemeral responses | Only you can see bot output in Discord |
| Blocked tools | `run`, `payload_generate`, `reverse_shell`, `hydra_attack` never exposed via Discord |
| Audit logging | Every Discord command logged with timestamp to `bot_audit.log` |
| Tailscale remote access | WireGuard encrypted — no open internet ports required |
| Service startup delay | `ExecStartPre=/bin/sleep 10` on both services prevents race with Docker on boot |

> The container runs as root internally — required for tools like nmap that need raw socket access. This is standard for security lab setups and is contained within the Docker/VM isolation layers.

---

## 📅 Day-to-Day Usage

### Daily startup

```bash
cd ~/kali-mcp && docker compose up -d
sudo systemctl status discord-kali-bot kalibot-monitor
```

### Bug bounty session workflow

```
1. /session_create name:target-2026
2. /investigate target:target.com depth:standard
3. /generate_report
4. Copy report and submit
```

### Daily shutdown

```bash
docker compose down
```

### Verify everything is running

```bash
docker ps
sudo systemctl status discord-kali-bot kalibot-monitor
curl http://localhost:8000/health
```

---

## 🔧 Common Commands

### Docker management

```bash
docker compose up -d                          # Start Kali MCP server
docker compose down                           # Stop server
docker logs -f kali-mcp-server                # View live logs
docker exec -it kali-mcp-server bash          # Shell into Kali
docker compose build && docker compose up -d  # Rebuild after code changes
```

### Service management

```bash
sudo systemctl status discord-kali-bot        # Check bot status
sudo systemctl restart discord-kali-bot       # Restart bot
sudo journalctl -u discord-kali-bot -n 50     # View bot logs

sudo systemctl status kalibot-monitor         # Check monitor status
sudo journalctl -u kalibot-monitor -n 50      # View monitor logs

cat ~/kali-mcp/bot_audit.log                  # View Discord audit log
```

### Network (Windows PowerShell)

```powershell
netsh interface portproxy show all
netsh interface portproxy reset
Get-Content "$env:APPDATA\Claude\logs\main.log" -Tail 50
```

---

## 🔧 Troubleshooting

<details>
<summary><strong>Claude Desktop shows "MCP server could not be loaded"</strong></summary>

1. Use the **direct installer** — not the Microsoft Store version
2. Verify mcp-remote is installed: `where.exe mcp-remote`
3. Check the container is running: `docker ps`
4. Test SSE endpoint in browser: `http://localhost:8000/sse`
5. Check Claude logs: `Get-Content "$env:APPDATA\Claude\logs\main.log" -Tail 50`

</details>

<details>
<summary><strong>Browser shows "connection refused" at localhost:8000</strong></summary>

```powershell
netsh interface portproxy show all
# If rule is missing, re-run windows_setup.ps1 or add manually:
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8000 connectaddress=<VM-IP> connectport=8000
```

</details>

<details>
<summary><strong>VM IP changed after reboot</strong></summary>

```bash
hostname -I   # get new IP
```

```powershell
netsh interface portproxy reset
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8000 connectaddress=<new-ip> connectport=8000
```

To prevent this permanently, assign a static IP inside Ubuntu via Netplan:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  ethernets:
    ens33:
      dhcp4: no
      addresses: [192.168.91.132/24]
      gateway4: 192.168.91.1
      nameservers:
        addresses: [8.8.8.8]
  version: 2
```

```bash
sudo netplan apply
```

</details>

<details>
<summary><strong>Services show as "activating" right after install</strong></summary>

Both services have a 10-second startup delay (`ExecStartPre=/bin/sleep 10`) to let Docker fully start first. Wait a few seconds then check again:

```bash
sudo systemctl status discord-kali-bot kalibot-monitor
```

</details>

<details>
<summary><strong>Discord bot not responding to slash commands</strong></summary>

```bash
sudo journalctl -u discord-kali-bot -n 50
sudo systemctl restart discord-kali-bot
```

If commands don't appear in Discord, global sync can take up to an hour. Force instant sync by adding to `on_ready` in `discord_kali_bot.py`:

```python
guild = discord.Object(id=YOUR_SERVER_ID)
tree.copy_global_to(guild=guild)
await tree.sync(guild=guild)
```

</details>

<details>
<summary><strong>Health monitor not sending Discord alerts</strong></summary>

```bash
grep -c "DISCORD_WEBHOOK_URL" ~/kali-mcp/.env  # Should return 1
sudo journalctl -u kalibot-monitor -n 30
sudo systemctl restart kalibot-monitor
```

</details>

<details>
<summary><strong>/health endpoint returns "Not Found"</strong></summary>

Edits to `server.py` require a container rebuild:

```bash
cd ~/kali-mcp && docker compose down && docker compose build && docker compose up -d
curl http://localhost:8000/health
```

</details>

<details>
<summary><strong>Missing tools inside container</strong></summary>

```bash
docker exec -it kali-mcp-server bash -c "
apt-get update -q &&
apt-get install -y dirb exploitdb wordlists &&
curl -o /usr/local/bin/testssl.sh https://raw.githubusercontent.com/drwetter/testssl.sh/3.2/testssl.sh &&
chmod +x /usr/local/bin/testssl.sh
"
```

</details>

<details>
<summary><strong>Docker build fails</strong></summary>

```bash
sudo apt update
docker compose build --no-cache
df -h   # Need at least 10GB free
```

</details>

---

## ⚖️ Legal Notice

This setup is for **authorised security testing only**.

- Only scan systems you own or have **explicit written permission** to test
- Always check bug bounty program scope before running any tools
- Never scan or probe systems outside your authorised scope
- Unauthorised scanning is illegal in most jurisdictions worldwide

---

## 📄 Credits

- [BsidesMCPDemo](https://github.com/kannanprabu/BsidesMCPDemo) by Kannan Prabu Ramamoorthy — the BSides San Diego workshop demo that inspired this project
- [kali-mcp](https://github.com/k3nn3dy-ai/kali-mcp) by k3nn3dy-ai — Kali Linux Docker MCP server and tool implementations
- [mcp-remote](https://www.npmjs.com/package/mcp-remote) — SSE to stdio bridge for Claude Desktop
- [Tailscale](https://tailscale.com) — Encrypted remote access
- [discord.py](https://discordpy.readthedocs.io) — Discord bot framework
- [Anthropic Claude](https://anthropic.com) — AI recon agent and report writer

---

Built for the bug bounty community. Hunt legally. Hunt responsibly. 🔐

# KaliBot — AI-Powered Bug Bounty Lab | Kali MCP + Claude Desktop + Discord Recon Agent

A complete home security lab setup that connects Claude Desktop to a Kali Linux Docker container running inside an Ubuntu VM on VMware, with a secure Discord bot and AI-powered recon agent for remote bug bounty research. Built for bug bounty research and security learning.

## Interactive Docker Cheat Sheet

[Open Cheat Sheet](https://spac3gh0st00.github.io/Kali-MCP-Server--Windows-VMware-Claude-Desktop/)

---

## Architecture

```
Windows Host (Claude Desktop)
        |
        | mcp-remote (stdio bridge)
        |
   localhost:8000
        |
   netsh portproxy
        |
  192.168.x.x:8000
        |
   Ubuntu VM (VMware)
        |
      Docker
        |
  Kali Linux Container
  (35 security tools)
        |
        | <- also reachable via:
        |
  Discord Bot (Ubuntu VM)
        |   |
        |   | /investigate or /generate_report
        |   v
        | Anthropic API (Claude AI)
        | AI plans tools -> runs them -> writes report
        |
  Discord (slash commands)
        |
  Your phone / any Tailscale device
```

---

## Bug Bounty Workflow

```
1. /session_create name:target-2026       <- start a new session
        |
2. /investigate target:target.com         <- AI plans + runs recon automatically
   OR manual slash commands:
   /recon_auto, /port_scan, /web_audit...
        |
3. /generate_report                        <- AI reads all scan outputs
        |                                     and writes a full report
4. Submit to bug bounty program
```

---

## Prerequisites

| Requirement | Notes |
| --- | --- |
| Windows 10/11 64-bit | Host machine |
| VMware Workstation 17 Pro | For running Ubuntu VM |
| Ubuntu 24.04 LTS ISO | [Download here](https://ubuntu.com/download/desktop) |
| Claude Desktop (direct installer) | [Download here](https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe) |
| Node.js LTS | [Download here](https://nodejs.org) |
| Anthropic API Key | [Get one here](https://console.anthropic.com) — $5 credit lasts weeks |
| ~40GB free disk space | For VM + Docker image |
| 8GB+ RAM | Minimum for stable VM |

> **Important:** Use the direct Claude Desktop installer, not the Microsoft Store version. The Store version does not support remote MCP connections.

---

## Part 1 — Create the Ubuntu VM in VMware

### Step 1 — Create a new VM

1. Open VMware Workstation → **Create a New Virtual Machine**
2. Select **Typical** → Next
3. Select your Ubuntu 24.04 ISO → Next
4. Set your username and password → Next
5. Click **Customize Hardware** before finishing

### Step 2 — Configure VM hardware

| Setting | Value |
| --- | --- |
| Memory | 8192 MB minimum |
| Processors | 4 cores |
| Network Adapter | NAT |
| Disk | 40GB minimum |

Click **Close → Finish**.

### Step 3 — VMware nested virtualization note

If you attempt to enable **"Virtualize AMD-V/RVI"** and see a warning that it is not supported, click **Yes** to continue without it.

> Docker on native Linux (Ubuntu) does not require nested virtualization — it uses Linux kernel namespaces and cgroups directly. Nested virt is only needed when running VMs inside VMs.

If VMware refuses to start with the warning, check for Hyper-V conflicts:

```powershell
# Run in PowerShell as Administrator
bcdedit /set hypervisorlaunchtype off
# Restart machine after running this
```

### Step 4 — Install Ubuntu

1. Power on the VM
2. Follow the Ubuntu installer — choose **Normal installation**
3. Choose **Erase disk and install Ubuntu** (safe — inside the VM only)
4. Complete setup and reboot into Ubuntu

---

## Part 2 — Install Docker Inside Ubuntu VM

Open a Terminal in Ubuntu (Ctrl+Alt+T).

### Step 5 — Update the system

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 6 — Install Docker Engine

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 7 — Add your user to the Docker group

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Step 8 — Verify Docker works

```bash
docker run hello-world
```

You should see `Hello from Docker!`

---

## Part 3 — Set Up the Kali MCP Server

### Step 9 — Clone the repository

```bash
sudo apt install -y git
git clone https://github.com/k3nn3dy-ai/kali-mcp.git
cd kali-mcp
```

### Step 10 — Build the Docker image

> This downloads the Kali base image and installs 35 security tools. Takes 10-20 minutes on first run.

```bash
docker compose build
```

### Step 11 — Start the container

```bash
docker compose up -d
```

Verify it is running:

```bash
docker ps
# Should show kali-mcp-server with status "Up" and port 0.0.0.0:8000->8000/tcp
```

Check the logs:

```bash
docker logs kali-mcp-server
# Should show MCP server running on port 8000
```

### Step 11b — Install missing tools inside the container

Some tools are not included in the base image. Install them now:

```bash
docker exec -it kali-mcp-server bash -c "
apt-get update -q &&
apt-get install -y dirb exploitdb wordlists &&
curl -o /usr/local/bin/testssl.sh https://raw.githubusercontent.com/drwetter/testssl.sh/3.2/testssl.sh &&
chmod +x /usr/local/bin/testssl.sh
"
```

Verify:

```bash
docker exec kali-mcp-server which searchsploit
docker exec kali-mcp-server ls /usr/share/wordlists/dirb/
docker exec kali-mcp-server which testssl.sh
```

---

## Part 4 — Configure Networking

### Step 12 — Get the VM's IP address

In the Ubuntu terminal:

```bash
hostname -I
# Returns something like 192.168.91.132
```

Write this IP down — you need it for the next step.

### Step 13 — Tighten the UFW firewall (Ubuntu)

```bash
sudo ufw allow 22/tcp
sudo ufw allow from 192.168.91.0/24 to any port 8000
sudo ufw enable
sudo ufw status
```

### Step 14 — Set up port proxy on Windows

Open **PowerShell as Administrator** on your Windows host:

```powershell
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8000 connectaddress=192.168.91.132 connectport=8000
```

Replace `192.168.91.132` with your actual VM IP from Step 12.

Verify the rule:

```powershell
netsh interface portproxy show all
# Should show: 127.0.0.1:8000 -> 192.168.x.x:8000
```

Test the connection in your Windows browser:

```
http://localhost:8000/sse
```

You should see an SSE stream response like:

```
event: endpoint
data: /messages/?session_id=...
: ping - 2026-...
```

---

## Part 5 — Configure Claude Desktop

### Step 15 — Install mcp-remote on Windows

```powershell
npm install -g mcp-remote
```

Verify:

```powershell
where.exe mcp-remote
# Should return a path like C:\Users\...\AppData\Roaming\npm\mcp-remote
```

### Step 16 — Edit Claude Desktop config

Find the config file at:

```
%APPDATA%\Claude\claude_desktop_config.json
```

Open in Notepad and add:

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

### Step 17 — Restart Claude Desktop

1. Find Claude in the system tray (bottom-right)
2. Right-click → **Quit**
3. Relaunch from Start menu

### Step 18 — Verify connection

1. Click the **+** button in the Claude Desktop chat input
2. Click **Connectors**
3. You should see **kali** listed with a blue toggle

Test it:

> "Can you run a quick nmap scan on 127.0.0.1?"

---

## Part 6 — Remote Access via Tailscale (Optional)

Access your lab from your phone anywhere in the world.

### Step 19 — Install Tailscale

1. **Windows:** https://tailscale.com/download/windows
2. **Ubuntu VM:**

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
# Authenticate via the URL shown in terminal
```

3. **Phone:** Download Tailscale from App Store or Play Store
4. Sign into the **same Tailscale account** on all three devices

### Step 20 — Enable SSH on Ubuntu

```bash
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

### Step 21 — Connect from phone

Install **Termius** (iOS/Android) and create a new host:

| Field | Value |
| --- | --- |
| Hostname | Ubuntu VM's Tailscale IP (100.x.x.x) |
| Username | your Ubuntu username |
| Password | your Ubuntu password |
| Port | 22 |

From Termius, enter the Kali container:

```bash
docker exec -it kali-mcp-server bash
```

You now have a full Kali shell on your phone.

---

## Part 7 — Discord Bot (Remote Recon via Slash Commands)

A secure Discord bot that lets you trigger recon tools remotely via slash commands. The bot talks to the MCP server through the proper HTTP/SSE API — not raw shell access — so only the 35 defined tools can be called.

### Security Design

| Protection | Detail |
| --- | --- |
| User ID whitelist | Only your Discord account can run any command |
| Server ID lock | Commands silently fail in any other server |
| Ephemeral responses | Only you can see output — invisible to others in the channel |
| Blocked tools | `run`, `payload_generate`, `reverse_shell`, `hydra_attack` never exposed |
| Audit logging | Every command logged with timestamp to `bot_audit.log` |
| MCP API only | Goes through the defined tool layer — no raw shell access |

### Step 22 — Create the Discord Bot

1. Go to https://discord.com/developers/applications
2. Click **New Application** → name it (e.g. `KaliBot`) → **Create**
3. Click **Bot** in the left sidebar
4. Click **Reset Token** → copy and save your token securely
5. Scroll to **Privileged Gateway Intents** → enable **Message Content Intent** → **Save Changes**
6. Click **OAuth2** → **URL Generator**
7. Under Scopes check: `bot` and `applications.commands`
8. Under Bot Permissions check: `Send Messages` and `Use Slash Commands`
9. Copy the generated URL → open in browser → invite bot to your **private server**

### Step 23 — Get Your Discord User ID and Server ID

**User ID:**
1. Open Discord → **Settings** → **Advanced** → enable **Developer Mode**
2. Right-click your username anywhere → **Copy User ID**

**Server ID:**
1. Right-click your private **server name** at the top left
2. Click **Copy Server ID**

Save both alongside your bot token.

### Step 24 — Create the Bot Files on Ubuntu VM

```bash
cd ~/kali-mcp

# Create the bot script
nano discord_kali_bot.py
# Paste the full contents of discord_kali_bot.py then Ctrl+X -> Y -> Enter

# Create the investigate/report module
nano investigate.py
# Paste the full contents of investigate.py then Ctrl+X -> Y -> Enter

# Create the environment file
nano .env
```

Inside `.env`:

```
DISCORD_TOKEN=your_bot_token_here
ALLOWED_USER_ID=your_discord_user_id_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here
```

Save with `Ctrl+X` → `Y` → Enter

### Step 25 — Protect .env from GitHub

```bash
echo ".env" >> ~/.gitignore
```

### Step 26 — Set Up Python Virtual Environment

```bash
# Install venv support
sudo apt install python3.12-venv -y

# Create virtual environment
python3 -m venv ~/kali-mcp/venv

# Activate it
source ~/kali-mcp/venv/bin/activate

# Install all dependencies
pip install discord.py httpx python-dotenv anthropic
```

> You will see `(venv)` at the start of your terminal prompt when the virtual environment is active.

### Step 27 — Test the Bot Manually

```bash
docker ps  # Make sure the Kali container is running first

source ~/kali-mcp/venv/bin/activate
python3 ~/kali-mcp/discord_kali_bot.py
```

You should see:

```
[+] Bot online as KaliBot#1234
[+] Authorized user ID: <your id>
[+] Audit log: ~/kali-mcp/bot_audit.log
```

Test in Discord:

```
/session_status
/dns_enum domain:google.com
```

If both respond correctly press `Ctrl+C` and move to Step 28.

### Step 28 — Install as a Background Service

```bash
nano ~/kali-mcp/discord-kali-bot.service
```

Paste the following — replace `YOUR_USERNAME` with your actual Ubuntu username:

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
ExecStart=/home/YOUR_USERNAME/kali-mcp/venv/bin/python3 /home/YOUR_USERNAME/kali-mcp/discord_kali_bot.py
Restart=on-failure
RestartSec=10
NoNewPrivileges=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
```

```bash
sudo cp ~/kali-mcp/discord-kali-bot.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable discord-kali-bot
sudo systemctl start discord-kali-bot
sudo systemctl status discord-kali-bot
```

You should see `Active: active (running)` in green.

### Step 29 — Verify Audit Logging

```bash
cat ~/kali-mcp/bot_audit.log
```

---

## Part 8 — AI Recon Agent

Two AI-powered commands that use the Anthropic API to automate and interpret your recon.

### /investigate — Autonomous Recon Agent

Tell it a target and it plans, runs, and interprets everything automatically.

```
/investigate target:example.com depth:standard
```

**What it does:**
1. Claude plans the recon strategy based on the target
2. Picks the first tool to run (usually dns_enum or port_scan)
3. Runs it through your MCP server
4. Reads the results and decides what to run next
5. Chains up to 8 tool calls automatically
6. Writes a full structured report at the end

**Depth options:**

| Depth | Tool calls | Best for |
| --- | --- | --- |
| `quick` | 3-4 | Fast initial look |
| `standard` | 5-6 | Normal recon |
| `thorough` | up to 8 | Deep investigation |

**Cost:** ~$0.05-0.15 per investigation

---

### /generate_report — Session Report Writer

Reads all scan output files from your active session and writes a complete bug bounty report.

```
/generate_report
```

**What it does:**
1. Finds your active session
2. Reads all scan output `.txt` files in that session
3. Sends everything to Claude
4. Claude writes a structured report based on the actual data
5. Report is posted back to Discord — only you can see it

**Report includes:**
- Executive summary
- Key findings with severity ratings (Critical/High/Medium/Low/Info)
- Attack surface map
- Recommended next steps
- Overall risk assessment

**Cost:** ~$0.03-0.10 per report

---

### Anthropic API Setup

1. Go to https://console.anthropic.com
2. Sign up and add $5 credit (lasts weeks of normal use)
3. Create an API key → copy it
4. Add to your `.env`: `ANTHROPIC_API_KEY=sk-ant-...`
5. Set a monthly spend limit under **Billing → Limits**

---

### Available Discord Slash Commands

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

## Security Checklist

| Item | Status |
| --- | --- |
| Port 8000 localhost-only on Windows | Configured in Step 14 |
| UFW firewall active on Ubuntu | Configured in Step 13 |
| Container isolated from Windows filesystem | Default — no volumes mounted to Windows |
| netsh portproxy scope limited to localhost | Configured in Step 14 |
| Tailscale encryption for remote access | WireGuard encrypted — no open internet ports |
| Memory Integrity (Windows) | Check via Core Isolation settings |
| Discord bot user ID whitelist | Hardcoded in `is_authorized()` |
| Discord bot server ID lock | Commands fail silently in all other servers |
| Ephemeral responses | Only you can see bot output in Discord |
| Discord bot token stored in .env | Never hardcoded — .env excluded from GitHub |
| Dangerous tools blocked from Discord | `run`, `payload_generate`, `reverse_shell`, `hydra_attack` |
| All Discord commands audit logged | Logged to `~/kali-mcp/bot_audit.log` |
| Discord server private | Only you — no other members |
| Discord account 2FA enabled | Enable in Discord Settings → Privacy & Safety |
| Anthropic API key stored in .env | Never hardcoded — .env excluded from GitHub |

> The container runs as root internally — required for tools like nmap that need raw socket access. This is standard for security lab setups and is contained within the Docker/VM isolation layers.

---

## Day-to-Day Usage

### Daily startup

```bash
cd ~/kali-mcp && docker compose up -d
sudo systemctl status discord-kali-bot
```

### Bug bounty session workflow

```
1. /session_create name:target-2026
2. /investigate target:target.com depth:standard
   OR run specific tools:
   /recon_auto, /port_scan, /web_audit, /ssl_analysis
3. /generate_report
4. Copy report and submit
```

### Daily shutdown

```bash
docker compose down
```

### Suspend VM when not in use

In VMware: **VM → Suspend**

### Verify everything is running

```bash
docker ps
tailscale status
hostname -I
sudo systemctl status discord-kali-bot
```

---

## Common Commands

### Docker management

```bash
docker compose up -d                      # Start Kali MCP server
docker compose down                       # Stop server
docker compose restart                    # Restart server
docker logs -f kali-mcp-server            # View live logs
docker exec -it kali-mcp-server bash      # Shell into Kali
docker stats kali-mcp-server              # Resource usage
docker compose up --build -d              # Rebuild after updates
```

### Discord bot management

```bash
sudo systemctl status discord-kali-bot    # Check bot status
sudo systemctl restart discord-kali-bot   # Restart bot
sudo systemctl stop discord-kali-bot      # Stop bot
sudo journalctl -u discord-kali-bot -n 50 # View bot logs
cat ~/kali-mcp/bot_audit.log              # View audit log
```

### Network (Windows PowerShell)

```powershell
netsh interface portproxy show all
netsh interface portproxy reset
Get-Content "$env:APPDATA\Claude\logs\main.log" -Tail 50
```

### Kali tools (inside container)

```bash
nmap -sV -T4 target.com
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt
nikto -h https://target.com
sqlmap -u 'https://target.com/page?id=1' --dbs
sslscan target.com
testssl.sh target.com
searchsploit apache 2.4.49
nmap -sV target.com > /app/sessions/myscan.txt
```

---

## Troubleshooting

### Claude Desktop shows "MCP server could not be loaded"

1. Use the **direct installer** version, not the Store version
2. Verify mcp-remote: `where.exe mcp-remote`
3. Check container: `docker ps`
4. Test SSE endpoint: `http://localhost:8000/sse`
5. Check Claude logs: `Get-Content "$env:APPDATA\Claude\logs\main.log" -Tail 50`

### Browser shows "connection refused" at localhost:8000

```powershell
netsh interface portproxy show all
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8000 connectaddress=192.168.91.132 connectport=8000
```

### VM IP changed after reboot

```bash
hostname -I   # get new IP
```

```powershell
netsh interface portproxy reset
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8000 connectaddress=<new-ip> connectport=8000
```

### Discord bot not responding

```bash
sudo systemctl status discord-kali-bot
sudo journalctl -u discord-kali-bot -n 50
sudo systemctl restart discord-kali-bot
```

### Discord bot says "Cannot reach MCP server"

```bash
docker ps
cd ~/kali-mcp && docker compose up -d
```

### /investigate or /generate_report says "credit balance too low"

1. Go to https://console.anthropic.com → **Billing**
2. Confirm payment is completed and balance is non-zero
3. If balance shows but still fails — delete and recreate your API key
4. Update `ANTHROPIC_API_KEY` in `.env`
5. `sudo systemctl restart discord-kali-bot`

### Slash commands not showing in Discord

Global sync can take up to an hour. To force instant sync, add to `on_ready` in `discord_kali_bot.py`:

```python
guild = discord.Object(id=YOUR_SERVER_ID)
tree.copy_global_to(guild=guild)
await tree.sync(guild=guild)
```

### Missing tools inside container

```bash
docker exec -it kali-mcp-server bash -c "
apt-get update -q &&
apt-get install -y dirb exploitdb wordlists &&
curl -o /usr/local/bin/testssl.sh https://raw.githubusercontent.com/drwetter/testssl.sh/3.2/testssl.sh &&
chmod +x /usr/local/bin/testssl.sh
"
```

### Discord bot service fails on boot

```bash
crontab -e
# Add:
@reboot cd /home/YOUR_USERNAME/kali-mcp && docker compose up -d
```

### Termius connection refused from phone

```bash
sudo systemctl status ssh
sudo systemctl start ssh
```

### Docker build fails

```bash
sudo apt update
docker compose build --no-cache
df -h
```

---

## Available Tools (35 total)

| Category | Tools |
| --- | --- |
| Port scanning | nmap (with presets) |
| DNS | dnsenum, dig, host |
| Web | nikto, gobuster, dirb, whatweb |
| SQL injection | sqlmap |
| Password cracking | john, hashcat |
| Brute force | hydra |
| SSL/TLS | sslscan, testssl.sh, openssl |
| Wireless | aircrack-ng |
| Exploitation | metasploit-framework, searchsploit |
| Recon | sublist3r, whois, subfinder, amass |

---

## Legal Notice

This setup is for **authorized security testing only**.

- Only scan systems you own or have **explicit written permission** to test
- Always check bug bounty program scope before running any tools
- Never scan or probe systems outside your authorized scope
- Unauthorized scanning is illegal in most jurisdictions

---

## Credits

- [kali-mcp](https://github.com/k3nn3dy-ai/kali-mcp) by k3nn3dy-ai — Kali Linux Docker MCP server
- [mcp-remote](https://www.npmjs.com/package/mcp-remote) — SSE to stdio bridge for Claude Desktop
- [Tailscale](https://tailscale.com) — Encrypted remote access
- [discord.py](https://discordpy.readthedocs.io) — Discord bot framework
- [Anthropic Claude](https://anthropic.com) — AI recon agent and report writer

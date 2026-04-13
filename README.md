<div align="center">

# 🤖 KaliBot — AI-Powered Bug Bounty Lab

**Kali MCP · Claude Desktop · Discord Recon Agent · Server Health Notifications**

*A complete home security lab that connects Claude Desktop to a Kali Linux Docker container running inside an Ubuntu VM on VMware — with a secure Discord bot, autonomous AI recon agent, and real-time server health monitoring built for bug bounty research and security learning.*

---

[![Platform](https://img.shields.io/badge/platform-Windows%20%2B%20VMware%20%2B%20Ubuntu%20%2B%20Docker-0d1117?style=for-the-badge&logo=vmware&logoColor=white)](.)
[![Claude](https://img.shields.io/badge/Claude-Desktop-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://claude.ai/download)
[![Kali](https://img.shields.io/badge/Kali-Linux-557C94?style=for-the-badge&logo=kalilinux&logoColor=white)](https://www.kali.org/)
[![Discord](https://img.shields.io/badge/Discord-Recon%20Agent-5865F2?style=for-the-badge&logo=discord&logoColor=white)](.)
[![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?style=for-the-badge&logo=python&logoColor=white)](.)
[![Docker](https://img.shields.io/badge/Docker-Containerised-2496ED?style=for-the-badge&logo=docker&logoColor=white)](.)
[![License](https://img.shields.io/badge/License-MIT-22c55e?style=for-the-badge)](LICENSE)
[![Ethics](https://img.shields.io/badge/Use-Authorised%20Testing%20Only-ef4444?style=for-the-badge)](.)

</div>

---

## 📌 Overview

KaliBot is a complete home security research lab that bridges **Claude Desktop** on Windows with a **fully containerised Kali Linux environment** running inside an Ubuntu VM on VMware. It gives you natural language control over 35 professional penetration testing tools, live Discord alerts for every recon event and server status change, and an autonomous AI agent that plans and executes full recon pipelines on your behalf.

> ⚠️ **Authorised use only.** This lab is designed for bug bounty programs you are enrolled in, CTF challenges, and systems you own or have explicit written permission to test.

---

## 🏗️ Architecture

```
Windows Host (Claude Desktop)
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

<table>
<tr>
<td width="50%" valign="top">

### 🔁 Claude Desktop MCP Integration
- Natural language → Kali tool execution
- 35 security tools exposed via MCP protocol
- Full tool output returned to Claude's context
- No CLI flags to memorise

### 🤖 Autonomous AI Recon Agent
- `/investigate` — plans, runs, and interprets recon automatically
- Chains up to 8 tool calls per session
- `/generate_report` — reads all scan files and writes a full bug bounty report
- Powered by Anthropic Claude API

### 🔔 Real-Time Health Notifications *(added v2)*
- `/health` endpoint on the MCP server
- Health monitor polls every 10 seconds
- Discord embeds on UP / DOWN / DEGRADED
- Auto-starts as a systemd service on boot

</td>
<td width="50%" valign="top">

### 🤖 Discord Recon Agent
- 24 slash commands for remote recon
- Ephemeral responses — only you see output
- User ID + server ID whitelist
- Dangerous tools blocked from Discord
- Full audit log of every command

### 🔐 Security-First Design
- UFW firewall restricts port 8000 to VM subnet
- Docker provides container isolation
- `.env` permissions locked to `600`
- No secrets hardcoded anywhere
- All credentials loaded from `.env` only

### 📱 Remote Access via Tailscale
- Access your lab from your phone anywhere
- WireGuard encrypted — no open internet ports
- Full Kali shell via Termius on iOS/Android

</td>
</tr>
</table>

---

## 📋 Prerequisites

| Requirement | Notes |
|---|---|
| Windows 10/11 64-bit | Host machine |
| VMware Workstation 17 Pro | For running Ubuntu VM |
| Ubuntu 24.04 LTS ISO | [Download here](https://ubuntu.com/download/desktop) |
| Claude Desktop (direct installer) | [Download here](https://claude.ai/download) |
| Node.js LTS | [Download here](https://nodejs.org) |
| Anthropic API Key | [Get one here](https://console.anthropic.com) — $5 credit lasts weeks |
| ~40GB free disk space | For VM + Docker image |
| 8GB+ RAM | Minimum for stable VM |

> **Important:** Use the direct Claude Desktop installer, not the Microsoft Store version. The Store version does not support remote MCP connections.

---

## 🗂️ Repository Structure

```
kali-mcp/
│
├── kali_mcp_server/
│   ├── server.py          # MCP server — SSE transport, /health endpoint, all routes
│   ├── tools.py           # All 35 tool implementations
│   ├── __main__.py
│   └── __init__.py
│
├── discord_kali_bot.py    # Discord slash command bot
├── investigate.py         # AI recon agent + report writer
├── health_monitor.py      # Server health watcher → Discord alerts  ← NEW
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

## 🚀 Setup Guide

### Part 1 — Create the Ubuntu VM in VMware

**Step 1 — Create a new VM**

1. Open VMware Workstation → **Create a New Virtual Machine**
2. Select **Typical** → Next
3. Select your Ubuntu 24.04 ISO → Next
4. Set your username and password → Next
5. Click **Customize Hardware** before finishing

**Step 2 — Configure VM hardware**

| Setting | Value |
|---|---|
| Memory | 8192 MB minimum |
| Processors | 4 cores |
| Network Adapter | NAT |
| Disk | 40GB minimum |

**Step 3 — VMware nested virtualization note**

If you see a warning about "Virtualize AMD-V/RVI" not being supported, click **Yes** to continue without it. Docker on native Linux does not require nested virtualization — it uses kernel namespaces and cgroups directly.

If VMware refuses to start due to Hyper-V conflicts:
```powershell
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

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

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

# Verify
docker exec kali-mcp-server which searchsploit
docker exec kali-mcp-server ls /usr/share/wordlists/dirb/
docker exec kali-mcp-server which testssl.sh
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
# Should return a path like C:\Users\...\AppData\Roaming\npm\mcp-remote
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

Test it by asking Claude: *"Can you run a quick nmap scan on 127.0.0.1?"*

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
|---|---|
| Hostname | Ubuntu VM's Tailscale IP (100.x.x.x) |
| Username | your Ubuntu username |
| Port | 22 |

From Termius, shell into Kali:
```bash
docker exec -it kali-mcp-server bash
```

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

```env
DISCORD_TOKEN=your_bot_token_here
ALLOWED_USER_ID=your_discord_user_id_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE
```

Lock permissions immediately:
```bash
chmod 600 ~/kali-mcp/.env
```

**Step 25 — Protect .env from Git**
```bash
echo ".env" >> ~/.gitignore
```

**Step 26 — Set up Python virtual environment**
```bash
sudo apt install python3.12-venv -y
python3 -m venv ~/kali-mcp/venv
source ~/kali-mcp/venv/bin/activate
pip install discord.py httpx python-dotenv anthropic requests
```

**Step 27 — Test the bot manually**
```bash
docker ps  # Confirm container is running first
source ~/kali-mcp/venv/bin/activate
python3 ~/kali-mcp/discord_kali_bot.py
```

Expected output:
```
[+] Bot online as KaliBot#1234
[+] Authorized user ID: <your id>
[+] Audit log: ~/kali-mcp/bot_audit.log
```

Test in Discord: `/session_status` and `/dns_enum domain:google.com`

**Step 28 — Install Discord bot as a background service**
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
sudo systemctl status discord-kali-bot
# Should show: Active: active (running)
```

**Step 29 — Verify audit logging**
```bash
cat ~/kali-mcp/bot_audit.log
```

---

### Part 8 — AI Recon Agent

**`/investigate` — Autonomous Recon Agent**

```
/investigate target:example.com depth:standard
```

What it does:
1. Claude plans the recon strategy based on the target
2. Picks the first tool (usually `dns_enum` or `port_scan`)
3. Runs it through your MCP server
4. Reads results and decides what to run next
5. Chains up to 8 tool calls automatically
6. Writes a full structured report at the end

| Depth | Tool calls | Best for |
|---|---|---|
| `quick` | 3–4 | Fast initial look |
| `standard` | 5–6 | Normal recon |
| `thorough` | up to 8 | Deep investigation |

Cost: ~$0.05–0.15 per investigation

---

**`/generate_report` — Session Report Writer**

```
/generate_report
```

Reads all scan output `.txt` files from your active session, sends them to Claude, and produces a structured bug bounty report including executive summary, severity-rated findings, attack surface map, and recommended next steps.

Cost: ~$0.03–0.10 per report

---

**Anthropic API Setup**

1. Go to https://console.anthropic.com → sign up
2. Add $5 credit (lasts weeks of normal use)
3. Create an API key → add to `.env` as `ANTHROPIC_API_KEY=sk-ant-...`
4. Set a monthly spend limit under **Billing → Limits**

---

### Part 9 — Server Health Notification System *(new)*

Real-time Discord alerts whenever your MCP server goes up, down, or becomes unreachable — with a health monitor that auto-starts on every boot.

**Step 30 — Add the `/health` endpoint to the MCP server**

Edit `~/kali-mcp/kali_mcp_server/server.py`. Inside `start_sse_server()`, add the `health_check` function directly above `handle_sse_connection`:

```python
async def health_check(request):
    """Health endpoint for the notification watcher."""
    from starlette.responses import JSONResponse
    return JSONResponse({"status": "healthy", "service": "kali-mcp"})
```

Then add it to the Starlette routes list:

```python
starlette_app = Starlette(
    debug=debug,
    routes=[
        Route("/health", endpoint=health_check),   # ← add this line
        Route("/sse", endpoint=handle_sse_connection),
        Mount("/messages/", app=sse_transport.handle_post_message),
    ],
)
```

> **Important:** Keep `host="0.0.0.0"` in `uvicorn.run()`. Inside Docker, binding to `127.0.0.1` makes the server unreachable from outside the container. Docker's port mapping and UFW handle external access control.

Rebuild the container to apply changes:
```bash
cd ~/kali-mcp
docker compose down
docker compose build
docker compose up -d

# Verify the endpoint works
curl http://localhost:8000/health
# Expected: {"status":"healthy","service":"kali-mcp"}
```

**Step 31 — Create a Discord webhook**

1. In your Discord server, right-click your alert channel → **Edit Channel**
2. **Integrations → Webhooks → New Webhook**
3. Name it `KaliBot Monitor` → **Copy Webhook URL**
4. Add to `~/kali-mcp/.env`:
```bash
echo 'DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_URL' >> ~/kali-mcp/.env
```

Check for duplicates and clean up:
```bash
grep -c "DISCORD_WEBHOOK_URL" ~/kali-mcp/.env  # Should return 1
```

**Step 32 — Create the health monitor script**
```bash
python3 << 'PYEOF'
content = '''#!/usr/bin/env python3
import os
import time
import requests
from datetime import datetime
from dotenv import load_dotenv

load_dotenv(os.path.expanduser("~/kali-mcp/.env"))

WEBHOOK_URL   = os.getenv("DISCORD_WEBHOOK_URL")
HEALTH_URL    = "http://localhost:8000/health"
POLL_INTERVAL = 10

def send_discord(status):
    if not WEBHOOK_URL:
        print("[Monitor] No DISCORD_WEBHOOK_URL in .env - skipping Discord alert")
        return
    colors = {"UP": 0x00FF00, "DOWN": 0xFF0000, "DEGRADED": 0xFFA500}
    payload = {
        "embeds": [{
            "title": f"KaliBot MCP - {status}",
            "description": f"Status changed at {datetime.now().strftime('%H:%M:%S')}",
            "color": colors.get(status, 0x888888),
        }]
    }
    try:
        requests.post(WEBHOOK_URL, json=payload, timeout=5)
        print(f"[Monitor] Discord alert sent: {status}")
    except Exception as e:
        print(f"[Monitor] Discord error: {e}")

def check_health():
    try:
        r = requests.get(HEALTH_URL, timeout=3)
        return "up" if r.status_code == 200 else "degraded"
    except requests.exceptions.ConnectionError:
        return "down"
    except Exception:
        return "degraded"

def run():
    last_status = None
    print(f"[Monitor] Watching {HEALTH_URL} every {POLL_INTERVAL}s")
    print(f"[Monitor] Discord webhook: {'configured' if WEBHOOK_URL else 'NOT SET'}")
    while True:
        current = check_health()
        if current != last_status:
            ts = datetime.now().strftime("%H:%M:%S")
            print(f"[Monitor] {ts} - status changed to {current.upper()}")
            send_discord(current.upper())
            last_status = current
        time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    run()
'''
with open('/home/' + os.environ['USER'] + '/kali-mcp/health_monitor.py', 'w') as f:
    f.write(content)
print("Done")
PYEOF
```

Install the `requests` dependency:
```bash
source ~/kali-mcp/venv/bin/activate
pip install requests
```

Test it manually first:
```bash
python3 ~/kali-mcp/health_monitor.py
# Expected output:
# [Monitor] Watching http://localhost:8000/health every 10s
# [Monitor] Discord webhook: configured
# [Monitor] 17:13:42 - status changed to UP
# [Monitor] Discord alert sent: UP
```

Check your Discord channel — you should see a green UP embed.

**Step 33 — Install as a systemd service**
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
sudo systemctl status kalibot-monitor
# Should show: Active: active (running)
```

**Step 34 — Verify full notification cycle**

In a second terminal, kill and revive the container:
```bash
docker compose down   # Watch for DOWN alert in Discord
sleep 5
docker compose up -d  # Watch for UP alert in Discord
```

Both alerts should fire automatically within 10 seconds.

---

## 💬 Discord Slash Commands

| Command | Description |
|---|---|
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
|---|---|
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

### Protections in place

| Item | Detail |
|---|---|
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
| Webhook content | Status alerts contain only status + timestamp — no IPs or scan data |
| Tailscale remote access | WireGuard encrypted — no open internet ports required |

> The container runs as root internally — required for tools like nmap that need raw socket access. This is standard for security lab setups and is contained within the Docker/VM isolation layers.

### Security checklist

| Item | Status |
|---|---|
| Port 8000 localhost-only on Windows | ✅ Step 14 |
| UFW firewall active on Ubuntu | ✅ Step 13 |
| Container isolated from host filesystem | ✅ Default Docker behaviour |
| `.env` permissions set to 600 | ✅ Step 24 |
| `.env` excluded from Git | ✅ Step 25 |
| Discord bot token stored in `.env` | ✅ Never hardcoded |
| Anthropic API key stored in `.env` | ✅ Never hardcoded |
| Discord webhook URL stored in `.env` | ✅ Step 31 |
| Dangerous tools blocked from Discord | ✅ `run`, `payload_generate`, `reverse_shell`, `hydra_attack` |
| All Discord commands audit logged | ✅ `~/kali-mcp/bot_audit.log` |
| Discord server private | ✅ Only you — no other members |
| Discord account 2FA enabled | Enable in Discord Settings → Privacy & Safety |
| Tailscale encryption for remote access | ✅ WireGuard encrypted |
| Memory Integrity (Windows) | Check via Core Isolation settings |

---

## 📅 Day-to-Day Usage

### Daily startup
```bash
cd ~/kali-mcp && docker compose up -d
sudo systemctl status discord-kali-bot
sudo systemctl status kalibot-monitor
```

### Bug bounty session workflow
```
1. /session_create name:target-2026
2. /investigate target:target.com depth:standard
   OR run specific tools: /recon_auto, /port_scan, /web_audit
3. /generate_report
4. Copy report and submit
```

### Daily shutdown
```bash
docker compose down
```

### Suspend VM when not in use
VMware: **VM → Suspend**

### Verify everything is running
```bash
docker ps
sudo systemctl status discord-kali-bot
sudo systemctl status kalibot-monitor
tailscale status
curl http://localhost:8000/health
```

---

## 🔧 Common Commands

### Docker management
```bash
docker compose up -d                    # Start Kali MCP server
docker compose down                     # Stop server
docker compose restart                  # Restart server
docker logs -f kali-mcp-server          # View live logs
docker exec -it kali-mcp-server bash    # Shell into Kali
docker stats kali-mcp-server            # Resource usage
docker compose build && docker compose up -d  # Rebuild after code changes
```

### Service management
```bash
sudo systemctl status discord-kali-bot    # Check bot status
sudo systemctl restart discord-kali-bot   # Restart bot
sudo systemctl stop discord-kali-bot      # Stop bot
sudo journalctl -u discord-kali-bot -n 50 # View bot logs

sudo systemctl status kalibot-monitor     # Check health monitor status
sudo systemctl restart kalibot-monitor    # Restart monitor
sudo journalctl -u kalibot-monitor -n 50  # View monitor logs

cat ~/kali-mcp/bot_audit.log              # View Discord audit log
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

## 🔧 Troubleshooting

<details>
<summary><b>Claude Desktop shows "MCP server could not be loaded"</b></summary>

1. Use the **direct installer** version — not the Microsoft Store version
2. Verify mcp-remote is installed: `where.exe mcp-remote`
3. Check the container is running: `docker ps`
4. Test SSE endpoint in browser: `http://localhost:8000/sse`
5. Check Claude logs: `Get-Content "$env:APPDATA\Claude\logs\main.log" -Tail 50`
</details>

<details>
<summary><b>Browser shows "connection refused" at localhost:8000</b></summary>

```powershell
netsh interface portproxy show all
# If rule is missing, re-add it:
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8000 connectaddress=192.168.91.132 connectport=8000
```
</details>

<details>
<summary><b>VM IP changed after reboot</b></summary>

```bash
hostname -I   # get new IP
```
```powershell
netsh interface portproxy reset
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8000 connectaddress=<new-ip> connectport=8000
```

To prevent this, assign a static IP inside Ubuntu via Netplan:
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
<summary><b>Discord bot not responding to slash commands</b></summary>

```bash
sudo systemctl status discord-kali-bot
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
<summary><b>Discord bot says "Cannot reach MCP server"</b></summary>

```bash
docker ps
cd ~/kali-mcp && docker compose up -d
```
</details>

<details>
<summary><b>Health monitor not sending Discord alerts</b></summary>

1. Check the webhook URL is in `.env`: `grep -c "DISCORD_WEBHOOK_URL" ~/kali-mcp/.env` — should return `1`
2. Check for duplicate entries and remove the placeholder: `sed -i '/DISCORD_WEBHOOK_URL=paste_your_url_here/d' ~/kali-mcp/.env`
3. Check monitor logs: `sudo journalctl -u kalibot-monitor -n 30`
4. Restart the service: `sudo systemctl restart kalibot-monitor`
</details>

<details>
<summary><b>/health endpoint returns "Not Found" after editing server.py</b></summary>

The server runs inside Docker — edits to `server.py` require a container rebuild to take effect:
```bash
cd ~/kali-mcp
docker compose down
docker compose build
docker compose up -d
curl http://localhost:8000/health
```
</details>

<details>
<summary><b>health_monitor.py throws "ModuleNotFoundError: No module named 'requests'"</b></summary>

```bash
source ~/kali-mcp/venv/bin/activate
pip install requests
```
</details>

<details>
<summary><b>/investigate or /generate_report says "credit balance too low"</b></summary>

1. Go to https://console.anthropic.com → **Billing**
2. Confirm payment completed and balance is non-zero
3. If balance shows but still fails — delete and recreate your API key
4. Update `ANTHROPIC_API_KEY` in `.env`
5. `sudo systemctl restart discord-kali-bot`
</details>

<details>
<summary><b>Missing tools inside container</b></summary>

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
<summary><b>Service fails on boot (discord-kali-bot or kalibot-monitor)</b></summary>

Check that Docker is fully started before the service tries to connect:
```bash
sudo journalctl -u discord-kali-bot -n 20
```

If it's failing because Docker isn't ready, add a delay:
```ini
[Service]
ExecStartPre=/bin/sleep 10
```

Alternatively, ensure the Docker container starts on boot:
```bash
docker update --restart unless-stopped kali-mcp-server
```
</details>

<details>
<summary><b>Termius connection refused from phone</b></summary>

```bash
sudo systemctl status ssh
sudo systemctl start ssh
```
</details>

<details>
<summary><b>Docker build fails</b></summary>

```bash
sudo apt update
docker compose build --no-cache
df -h   # Check available disk space — need at least 10GB free
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

- [kali-mcp](https://github.com/k3nn3dy-ai/kali-mcp) by k3nn3dy-ai — Kali Linux Docker MCP server
- [mcp-remote](https://www.npmjs.com/package/mcp-remote) — SSE to stdio bridge for Claude Desktop
- [Tailscale](https://tailscale.com) — Encrypted remote access
- [discord.py](https://discordpy.readthedocs.io) — Discord bot framework
- [Anthropic Claude](https://anthropic.com) — AI recon agent and report writer

---

<div align="center">

Built for the bug bounty community. Hunt legally. Hunt responsibly. 🔐

</div>

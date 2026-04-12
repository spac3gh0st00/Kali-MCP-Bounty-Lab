# Kali Linux Docker MCP Server — Windows + VMware + Claude Desktop

A complete home security lab setup that connects Claude Desktop to a Kali Linux Docker container running inside an Ubuntu VM on VMware. Built for bug bounty research and security learning.


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
```

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Windows 10/11 64-bit | Host machine |
| VMware Workstation 17 Pro | For running Ubuntu VM |
| Ubuntu 24.04 LTS ISO | [Download here](https://ubuntu.com/download/desktop) |
| Claude Desktop (direct installer) | [Download here](https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe) |
| Node.js LTS | [Download here](https://nodejs.org) |
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
|---|---|
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

> This downloads the Kali base image and installs 35 security tools. Takes 10–20 minutes on first run.

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
sudo ufw allow 22/tcp    # SSH
sudo ufw allow from 192.168.91.0/24 to any port 8000  # MCP — VM network only
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
# Should show: 127.0.0.1:8000 → 192.168.x.x:8000
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

`mcp-remote` is a bridge that connects Claude Desktop (which uses stdio) to the SSE-based Kali MCP server.

```powershell
npm install -g mcp-remote
```

Verify:

```powershell
where.exe mcp-remote
# Should return a path like C:\Users\...\AppData\Roaming\npm\mcp-remote
```

### Step 16 — Edit Claude Desktop config

> **Note:** Use the direct installer version of Claude Desktop. The Microsoft Store version does not support custom MCP servers.

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

You are connected. Test it:

> "Can you run a quick nmap scan on 127.0.0.1?"

---

## Part 6 — Remote Access via Tailscale (Optional)

Access your lab from your phone anywhere in the world.

### Step 19 — Install Tailscale

1. **Windows:** [https://tailscale.com/download/windows](https://tailscale.com/download/windows)
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
|---|---|
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
## Interactive Docker Cheat Sheet
[Open Cheat Sheet](https://spac3gh0st00.github.io/Kali-MCP-Server--Windows-VMware-Claude-Desktop/)

---
## Security Checklist

| Item | Status |
|---|---|
| Port 8000 localhost-only on Windows | Configured in Step 14 |
| UFW firewall active on Ubuntu | Configured in Step 13 |
| Container isolated from Windows filesystem | Default — no volumes mounted to Windows |
| netsh portproxy scope limited to localhost | Configured in Step 14 |
| Tailscale encryption for remote access | WireGuard encrypted — no open internet ports |
| Memory Integrity (Windows) | Check via Core Isolation settings |

> The container runs as root internally — required for tools like nmap that need raw socket access. This is standard for security lab setups and is contained within the Docker/VM isolation layers.

---

## Day-to-Day Usage

### Daily startup

```bash
# In Ubuntu terminal (or Termius remotely)
cd ~/kali-mcp && docker compose up -d
```

### Daily shutdown

```bash
# Stop container when done
docker compose down
```

### Suspend VM when not in use for days

In VMware: **VM → Suspend**

### Verify everything is running

```bash
# Ubuntu terminal
docker ps
tailscale status
hostname -I
```

```powershell
# Windows PowerShell
netsh interface portproxy show all
```

---

## Common Commands

### Docker management (run in Ubuntu)

```bash
docker compose up -d              # Start Kali MCP server
docker compose down               # Stop server
docker compose restart            # Restart server
docker logs -f kali-mcp-server    # View live logs
docker exec -it kali-mcp-server bash  # Shell into Kali
docker stats kali-mcp-server      # Resource usage
docker compose up --build -d      # Rebuild after updates
```

### Network (run in Windows PowerShell)

```powershell
netsh interface portproxy show all       # Check proxy rule
netsh interface portproxy reset          # Remove all proxy rules
Get-Content "$env:APPDATA\Claude\logs\main.log" -Tail 50  # Claude logs
```

### Kali security tools (run inside container)

```bash
# Recon
nmap -sV -T4 target.com                          # Service scan
nmap -sV -p- -T4 target.com                      # Full port scan
nmap --script vuln target.com                    # Vuln scripts
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt
gobuster dns -d target.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt
dnsenum --enum target.com
whois target.com

# Web scanning
nikto -h https://target.com
curl -sI https://target.com | grep -i 'x-frame\|content-security\|strict-transport'

# SQL injection
sqlmap -u 'https://target.com/page?id=1' --dbs
sqlmap -u 'https://target.com/login' --data='user=test&pass=test' --dbs

# SSL/TLS
sslscan target.com
nmap --script ssl-enum-ciphers -p 443 target.com

# Save output
nmap -sV target.com > /app/sessions/myscan.txt
ls /app/sessions/
```

---

## Troubleshooting

### Claude Desktop shows "MCP server could not be loaded"

1. Make sure you are using the **direct installer** version, not the Store version
2. Verify mcp-remote is installed: `where.exe mcp-remote`
3. Check that the container is running: `docker ps`
4. Test SSE endpoint: open `http://localhost:8000/sse` in browser
5. Check Claude logs: `Get-Content "$env:APPDATA\Claude\logs\main.log" -Tail 50`

### Browser shows "connection refused" at localhost:8000

```powershell
# Verify portproxy rule exists
netsh interface portproxy show all

# Re-add if missing
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8000 connectaddress=192.168.91.132 connectport=8000

# Confirm container is running in Ubuntu
docker ps
```

### VM IP changed after reboot

```bash
# Get new IP
hostname -I
```

Then update the portproxy rule on Windows:

```powershell
netsh interface portproxy reset
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8000 connectaddress=<new-ip> connectport=8000
```

### Termius connection refused from phone

```bash
# Check SSH is running
sudo systemctl status ssh
sudo systemctl start ssh
```

### Docker build fails

```bash
sudo apt update
docker compose build --no-cache
df -h  # Check available disk space
```

---

## Available Tools (35 total)

| Category | Tools |
|---|---|
| Port scanning | nmap (with presets) |
| DNS | dnsenum, dig, host |
| Web | nikto, gobuster, dirb, whatweb |
| SQL injection | sqlmap |
| Password cracking | john, hashcat |
| Brute force | hydra |
| SSL/TLS | sslscan, openssl |
| Wireless | aircrack-ng |
| Exploitation | metasploit-framework |
| Recon | sublist3r, whois |

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

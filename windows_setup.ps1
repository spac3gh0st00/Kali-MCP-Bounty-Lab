# =============================================================================
#  KaliBot — Windows Host Setup
#  https://github.com/spac3gh0st00/Kali-MCP-Bounty-Lab
#
#  Run in PowerShell as Administrator:
#    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#    .\windows_setup.ps1
# =============================================================================

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

function Write-Header { param($text)
    Write-Host "`n━━━ $text ━━━" -ForegroundColor Cyan
}
function Write-OK    { param($text) Write-Host "[✓] $text" -ForegroundColor Green  }
function Write-Info  { param($text) Write-Host "[*] $text" -ForegroundColor White  }
function Write-Warn  { param($text) Write-Host "[!] $text" -ForegroundColor Yellow }

# ── Step 1 — Get VM IP ────────────────────────────────────────────────────────
Write-Header "Step 1 — Ubuntu VM IP"
Write-Info "Run 'hostname -I' inside your Ubuntu VM and enter the IP below."
$vmIp = Read-Host "  Ubuntu VM IP address (e.g. 192.168.91.132)"
if (-not ($vmIp -match '^\d{1,3}(\.\d{1,3}){3}$')) {
    Write-Warn "IP looks odd — continuing anyway."
}

# ── Step 2 — Hyper-V conflict check ──────────────────────────────────────────
Write-Header "Step 2 — Hyper-V / hypervisor check"
$hvPolicy = (bcdedit /enum '{current}' | Select-String 'hypervisorlaunchtype').ToString()
if ($hvPolicy -match 'Auto') {
    Write-Warn "Hyper-V hypervisor is active. This may conflict with VMware."
    $disable = Read-Host "  Disable it now? VMware will work better. (y/N)"
    if ($disable -match '^[Yy]') {
        bcdedit /set hypervisorlaunchtype off | Out-Null
        Write-Warn "Hypervisor disabled. A restart is required before VMware will start."
    }
} else {
    Write-OK "Hypervisor not active — no conflict."
}

# ── Step 3 — netsh portproxy ──────────────────────────────────────────────────
Write-Header "Step 3 — netsh portproxy (localhost:8000 → VM:8000)"

# Remove any existing rule on port 8000 first
$existing = netsh interface portproxy show v4tov4 |
    Select-String '127.0.0.1\s+8000'
if ($existing) {
    Write-Info "Removing existing portproxy rule on port 8000…"
    netsh interface portproxy delete v4tov4 listenaddress=127.0.0.1 listenport=8000 | Out-Null
}

netsh interface portproxy add v4tov4 `
    listenaddress=127.0.0.1 listenport=8000 `
    connectaddress=$vmIp    connectport=8000 | Out-Null

Write-OK "portproxy rule added:"
netsh interface portproxy show v4tov4

# ── Step 4 — Windows Firewall ─────────────────────────────────────────────────
Write-Header "Step 4 — Windows Firewall loopback rule"
$ruleName = "KaliMCP-loopback-8000"
$existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if ($existingRule) {
    Write-Info "Firewall rule '$ruleName' already exists."
} else {
    New-NetFirewallRule `
        -DisplayName $ruleName `
        -Direction   Inbound `
        -Protocol    TCP `
        -LocalPort   8000 `
        -Action      Allow `
        -Profile     @("Private", "Domain") `
        | Out-Null
    Write-OK "Firewall rule '$ruleName' created."
}

# ── Step 5 — Node.js / mcp-remote check ──────────────────────────────────────
Write-Header "Step 5 — Node.js + mcp-remote"
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-OK "Node.js found: $(node --version)"
} else {
    Write-Warn "Node.js not found."
    Write-Warn "Download and install LTS from https://nodejs.org, then re-run this script."
}

if (Get-Command mcp-remote -ErrorAction SilentlyContinue) {
    Write-OK "mcp-remote already installed."
} else {
    Write-Info "Installing mcp-remote globally…"
    npm install -g mcp-remote
    # npm is an external command — check $LASTEXITCODE, not a try/catch
    if ($LASTEXITCODE -eq 0) {
        Write-OK "mcp-remote installed."
    } else {
        Write-Warn "npm install exited with code $LASTEXITCODE."
        Write-Warn "Install Node.js from https://nodejs.org, then run: npm install -g mcp-remote"
    }
}

# ── Step 6 — Claude Desktop config ────────────────────────────────────────────
Write-Header "Step 6 — Claude Desktop config"
$configDir  = "$env:APPDATA\Claude"
$configFile = "$configDir\claude_desktop_config.json"

if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir | Out-Null
}

$kaliEntry = [PSCustomObject]@{
    command = "mcp-remote"
    args    = @("http://localhost:8000/sse")
}

if (Test-Path $configFile) {
    Write-Warn "Claude Desktop config already exists."
    try {
        $existingJson = Get-Content $configFile -Raw | ConvertFrom-Json
    } catch {
        Write-Warn "  Existing config is not valid JSON — backing up and replacing."
        Copy-Item $configFile "$configFile.bak"
        $existingJson = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
    }

    # Ensure mcpServers key exists (config may be {} with no mcpServers at all)
    if (-not $existingJson.PSObject.Properties['mcpServers']) {
        $existingJson | Add-Member -MemberType NoteProperty -Name 'mcpServers' -Value ([PSCustomObject]@{})
    }

    if ($existingJson.mcpServers.PSObject.Properties['kali']) {
        Write-OK "  'kali' MCP entry already present — no changes made."
    } else {
        Write-Info "  Merging 'kali' into existing mcpServers (all other entries preserved)…"
        Copy-Item $configFile "$configFile.bak"
        $existingJson.mcpServers | Add-Member -MemberType NoteProperty -Name 'kali' -Value $kaliEntry
        $merged = $existingJson | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($configFile, $merged)
        Write-OK "  Config updated."
    }
} else {
    $newConfig = [PSCustomObject]@{
        mcpServers = [PSCustomObject]@{
            kali = $kaliEntry
        }
    }
    $newJson = $newConfig | ConvertTo-Json -Depth 10
    # WriteAllText writes BOM-less UTF-8; Set-Content -Encoding UTF8 adds a BOM in PS 5.1
    [System.IO.File]::WriteAllText($configFile, $newJson)
    Write-OK "Claude Desktop config written to $configFile"
}

# ── Step 7 — Connectivity test ────────────────────────────────────────────────
Write-Header "Step 7 — Connectivity test"
Write-Info "Testing http://localhost:8000/health …"
try {
    $resp = Invoke-WebRequest -Uri "http://localhost:8000/health" -TimeoutSec 5 -UseBasicParsing
    if ($resp.StatusCode -eq 200) {
        Write-OK "/health responded: $($resp.Content)"
    } else {
        Write-Warn "/health returned status $($resp.StatusCode)"
    }
} catch {
    Write-Warn "Could not reach http://localhost:8000/health"
    Write-Warn "Make sure the Ubuntu VM is running and the Docker container is up."
}

# ── Summary ────────────────────────────────────────────────────────────────────
Write-Header "Done"
Write-Host ""
Write-Host "  portproxy   : localhost:8000 → ${vmIp}:8000"
Write-Host "  Claude cfg  : $configFile"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Restart Claude Desktop (system tray → right-click → Quit, then relaunch)."
Write-Host "  2. Click [+] in Claude chat → Connectors → you should see 'kali' with a blue toggle."
Write-Host "  3. Ask Claude: 'Can you run nmap on 127.0.0.1?'"
Write-Host ""
Write-Host "⚠  Authorised testing only. Hunt legally, hunt responsibly." -ForegroundColor Yellow
Write-Host ""

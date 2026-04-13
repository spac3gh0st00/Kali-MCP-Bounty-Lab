# =============================================================================
#  KaliBot - Windows Host / VM Setup
#  https://github.com/spac3gh0st00/Kali-MCP-Bounty-Lab
#
#  Run in PowerShell as Administrator on a fresh Windows machine or VM:
#    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#    .\windows_setup.ps1
#
#  Handles everything automatically:
#    Node.js LTS, mcp-remote, Claude Desktop, netsh portproxy,
#    Windows Firewall rule, Claude Desktop MCP config
# =============================================================================

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

function Write-Header {
    param($text)
    Write-Host ""
    Write-Host "--- $text ---" -ForegroundColor Cyan
}
function Write-OK   { param($text) Write-Host "[OK] $text"   -ForegroundColor Green  }
function Write-Info { param($text) Write-Host "[*]  $text"   -ForegroundColor White  }
function Write-Warn { param($text) Write-Host "[!]  $text"   -ForegroundColor Yellow }

# Helper: refresh PATH in the current session after an install
function Update-SessionPath {
    $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    $userPath    = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $env:PATH    = "$machinePath;$userPath"
}

# Check if winget is available
$wingetAvailable = [bool](Get-Command winget -ErrorAction SilentlyContinue)

# =============================================================================
Write-Header "Step 1 - Node.js LTS"
# =============================================================================
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-OK "Node.js already installed: $(node --version)"
} else {
    Write-Info "Node.js not found - installing..."

    $nodeInstalled = $false

    # Try winget first (available on Windows 10 1809+ and all Windows 11)
    if ($wingetAvailable) {
        Write-Info "Trying winget..."
        winget install OpenJS.NodeJS.LTS --silent --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -eq 0) {
            Update-SessionPath
            $nodeInstalled = $true
            Write-OK "Node.js installed via winget."
        } else {
            Write-Warn "winget install failed (exit $LASTEXITCODE) - falling back to direct download."
        }
    }

    # Fall back: query nodejs.org for latest LTS and download the MSI
    if (-not $nodeInstalled) {
        try {
            Write-Info "Fetching latest LTS version from nodejs.org..."
            $releases = Invoke-RestMethod "https://nodejs.org/dist/index.json" -UseBasicParsing
            $lts      = $releases | Where-Object { $_.lts } | Select-Object -First 1
            $version  = $lts.version
            $msiUrl   = "https://nodejs.org/dist/$version/node-$version-x64.msi"
            $msiPath  = "$env:TEMP\node-lts.msi"

            Write-Info "Downloading Node.js $version..."
            Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath -UseBasicParsing
            Write-Info "Installing (this may take a minute)..."
            Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait
            Update-SessionPath
            Remove-Item $msiPath -Force -ErrorAction SilentlyContinue
            $nodeInstalled = $true
            Write-OK "Node.js $version installed."
        } catch {
            Write-Warn "Automatic Node.js install failed: $_"
            Write-Warn "Please install Node.js LTS manually from https://nodejs.org then re-run this script."
        }
    }
}

# =============================================================================
Write-Header "Step 2 - mcp-remote"
# =============================================================================
if (Get-Command mcp-remote -ErrorAction SilentlyContinue) {
    Write-OK "mcp-remote already installed."
} elseif (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Info "Installing mcp-remote globally..."
    npm install -g mcp-remote
    if ($LASTEXITCODE -eq 0) {
        Write-OK "mcp-remote installed."
    } else {
        Write-Warn "npm install exited with code $LASTEXITCODE."
        Write-Warn "Try manually: npm install -g mcp-remote"
    }
} else {
    Write-Warn "npm not found - Node.js may need a restart to appear in PATH."
    Write-Warn "After rebooting, run: npm install -g mcp-remote"
}

# =============================================================================
Write-Header "Step 3 - Claude Desktop"
# =============================================================================

# Detect existing install via registry
$claudeInstalled = Get-ItemProperty `
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "*Claude*" }

if ($claudeInstalled) {
    Write-OK "Claude Desktop already installed."
} else {
    Write-Info "Claude Desktop not found - installing..."

    $claudeDone = $false

    if ($wingetAvailable) {
        Write-Info "Trying winget..."
        winget install Anthropic.Claude --silent --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -eq 0) {
            $claudeDone = $true
            Write-OK "Claude Desktop installed via winget."
        } else {
            Write-Warn "winget install failed (exit $LASTEXITCODE) - falling back to browser download."
        }
    }

    if (-not $claudeDone) {
        Write-Warn "Opening https://claude.ai/download in your browser."
        Write-Warn "IMPORTANT: Use the DIRECT installer - NOT the Microsoft Store version."
        Write-Warn "The Store version does not support MCP connections."
        Start-Process "https://claude.ai/download"
        Read-Host "`nPress Enter once Claude Desktop is installed to continue"
    }
}

# =============================================================================
Write-Header "Step 4 - Ubuntu VM IP"
# =============================================================================
Write-Info "Run 'hostname -I' inside your Ubuntu VM and enter the IP below."
$vmIp = Read-Host "Ubuntu VM IP address (e.g. 192.168.91.132)"
if (-not ($vmIp -match '^\d{1,3}(\.\d{1,3}){3}$')) {
    Write-Warn "IP looks odd - continuing anyway."
}

# =============================================================================
Write-Header "Step 5 - Hyper-V / hypervisor check"
# =============================================================================
$hvPolicy = (bcdedit /enum '{current}' | Select-String 'hypervisorlaunchtype').ToString()
if ($hvPolicy -match 'Auto') {
    Write-Warn "Hyper-V hypervisor is active. This may conflict with VMware."
    $disable = Read-Host "Disable it now? VMware will work better. (y/N)"
    if ($disable -match '^[Yy]') {
        bcdedit /set hypervisorlaunchtype off | Out-Null
        Write-Warn "Hypervisor disabled. A restart is required before VMware will start."
    }
} else {
    Write-OK "Hypervisor not active - no conflict."
}

# =============================================================================
Write-Header "Step 6 - netsh portproxy (localhost:8000 -> VM:8000)"
# =============================================================================

# Remove any existing rule on port 8000 first
$existing = netsh interface portproxy show v4tov4 |
    Select-String '127.0.0.1\s+8000'
if ($existing) {
    Write-Info "Removing existing portproxy rule on port 8000..."
    netsh interface portproxy delete v4tov4 listenaddress=127.0.0.1 listenport=8000 | Out-Null
}

netsh interface portproxy add v4tov4 `
    listenaddress=127.0.0.1 listenport=8000 `
    connectaddress=$vmIp    connectport=8000 | Out-Null

Write-OK "portproxy rule added:"
netsh interface portproxy show v4tov4

# =============================================================================
Write-Header "Step 7 - Windows Firewall loopback rule"
# =============================================================================
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

# =============================================================================
Write-Header "Step 8 - Claude Desktop MCP config"
# =============================================================================
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
        Write-Warn "Existing config is not valid JSON - backing up and replacing."
        Copy-Item $configFile "$configFile.bak"
        $existingJson = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
    }

    # Ensure mcpServers key exists
    if (-not $existingJson.PSObject.Properties['mcpServers']) {
        $existingJson | Add-Member -MemberType NoteProperty -Name 'mcpServers' -Value ([PSCustomObject]@{})
    }

    if ($existingJson.mcpServers.PSObject.Properties['kali']) {
        Write-OK "'kali' MCP entry already present - no changes made."
    } else {
        Write-Info "Merging 'kali' into existing mcpServers (all other entries preserved)..."
        Copy-Item $configFile "$configFile.bak"
        $existingJson.mcpServers | Add-Member -MemberType NoteProperty -Name 'kali' -Value $kaliEntry
        $merged = $existingJson | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($configFile, $merged)
        Write-OK "Config updated."
    }
} else {
    $newConfig = [PSCustomObject]@{
        mcpServers = [PSCustomObject]@{
            kali = $kaliEntry
        }
    }
    $newJson = $newConfig | ConvertTo-Json -Depth 10
    # WriteAllText writes BOM-less UTF-8 (Set-Content -Encoding UTF8 adds a BOM in PS 5.1)
    [System.IO.File]::WriteAllText($configFile, $newJson)
    Write-OK "Claude Desktop config written to $configFile"
}

# =============================================================================
Write-Header "Step 9 - Connectivity test"
# =============================================================================
Write-Info "Testing http://localhost:8000/health ..."
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

# =============================================================================
Write-Header "Done"
# =============================================================================
Write-Host ""
Write-Host "  Node.js   : $(if (Get-Command node -ErrorAction SilentlyContinue) { node --version } else { 'not in PATH - may need a restart' })"
Write-Host "  portproxy : localhost:8000 -> ${vmIp}:8000"
Write-Host "  Claude cfg: $configFile"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Restart Claude Desktop (system tray -> right-click -> Quit, then relaunch)."
Write-Host "  2. Click [+] in Claude chat -> Connectors -> you should see 'kali' with a blue toggle."
Write-Host "  3. Ask Claude: 'Can you run nmap on 127.0.0.1?'"
Write-Host ""
Write-Host "[!] Authorised testing only. Hunt legally, hunt responsibly." -ForegroundColor Yellow
Write-Host ""

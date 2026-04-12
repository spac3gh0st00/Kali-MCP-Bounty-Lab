<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Kali MCP — Bug Bounty Cheat Sheet</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&family=Inter:wght@400;500;600&display=swap');

  :root {
    --bg: #0d0f14;
    --bg2: #13161d;
    --bg3: #1a1d26;
    --bg4: #1f2330;
    --border: rgba(255,255,255,0.06);
    --border2: rgba(255,255,255,0.12);
    --text: #e2e8f0;
    --text2: #8892a4;
    --text3: #4a5568;
    --green: #00ff88;
    --green2: #00cc6a;
    --green-dim: rgba(0,255,136,0.08);
    --green-dim2: rgba(0,255,136,0.15);
    --cyan: #00d4ff;
    --cyan-dim: rgba(0,212,255,0.08);
    --purple: #a855f7;
    --purple-dim: rgba(168,85,247,0.08);
    --amber: #f59e0b;
    --amber-dim: rgba(245,158,11,0.08);
    --red: #ef4444;
    --red-dim: rgba(239,68,68,0.08);
    --pink: #ec4899;
    --mono: 'JetBrains Mono', ui-monospace, monospace;
    --sans: 'Inter', system-ui, sans-serif;
    --radius: 8px;
    --radius-lg: 12px;
  }

  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: var(--sans);
    background: var(--bg);
    color: var(--text);
    min-height: 100vh;
    padding: 0;
  }

  /* Header */
  .header {
    background: var(--bg2);
    border-bottom: 1px solid var(--border2);
    padding: 2rem 2rem 1.5rem;
    position: relative;
    overflow: hidden;
  }

  .header::before {
    content: '';
    position: absolute;
    top: -60px; left: -60px;
    width: 300px; height: 300px;
    background: radial-gradient(circle, rgba(0,255,136,0.06) 0%, transparent 70%);
    pointer-events: none;
  }

  .header::after {
    content: '';
    position: absolute;
    bottom: -80px; right: -40px;
    width: 250px; height: 250px;
    background: radial-gradient(circle, rgba(0,212,255,0.05) 0%, transparent 70%);
    pointer-events: none;
  }

  .header-inner { max-width: 900px; margin: 0 auto; position: relative; }

  .badge {
    display: inline-flex; align-items: center; gap: 6px;
    background: var(--green-dim2);
    border: 1px solid rgba(0,255,136,0.25);
    color: var(--green);
    font-size: 11px; font-weight: 500;
    padding: 3px 10px; border-radius: 99px;
    font-family: var(--mono);
    margin-bottom: 12px;
    letter-spacing: 0.05em;
  }

  .badge-dot {
    width: 6px; height: 6px;
    background: var(--green);
    border-radius: 50%;
    animation: pulse 2s infinite;
  }

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.3; }
  }

  h1 {
    font-size: 26px; font-weight: 600;
    color: var(--text);
    margin-bottom: 6px;
    letter-spacing: -0.02em;
  }

  h1 span { color: var(--green); }

  .subtitle {
    font-size: 13px; color: var(--text2);
    font-family: var(--mono);
    margin-bottom: 1.25rem;
  }

  .subtitle code {
    color: var(--cyan);
    background: var(--cyan-dim);
    padding: 2px 6px; border-radius: 4px;
    font-size: 12px;
  }

  .stats {
    display: flex; gap: 1.5rem; flex-wrap: wrap;
  }

  .stat {
    display: flex; align-items: center; gap: 6px;
    font-size: 12px; color: var(--text2);
  }

  .stat-num { color: var(--green); font-weight: 600; font-family: var(--mono); }

  /* Main content */
  .main { max-width: 900px; margin: 0 auto; padding: 1.5rem 2rem 3rem; }

  /* Search */
  .search-wrap { position: relative; margin-bottom: 1.25rem; }

  .search-icon {
    position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
    color: var(--text3); font-size: 14px; pointer-events: none;
  }

  .search-bar {
    width: 100%;
    padding: 10px 12px 10px 36px;
    font-size: 13px;
    border: 1px solid var(--border2);
    border-radius: var(--radius);
    background: var(--bg2);
    color: var(--text);
    font-family: var(--mono);
    outline: none;
    transition: border-color 0.2s;
  }

  .search-bar::placeholder { color: var(--text3); }
  .search-bar:focus { border-color: rgba(0,255,136,0.4); }

  /* Tabs */
  .tabs { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 1.5rem; }

  .tab {
    padding: 5px 14px;
    font-size: 12px; font-weight: 500;
    border: 1px solid var(--border2);
    border-radius: 99px;
    cursor: pointer;
    background: var(--bg2);
    color: var(--text2);
    font-family: var(--sans);
    transition: all 0.15s;
    letter-spacing: 0.01em;
  }

  .tab:hover { border-color: var(--border2); color: var(--text); }

  .tab.active {
    background: var(--green-dim2);
    color: var(--green);
    border-color: rgba(0,255,136,0.3);
  }

  /* Category colors */
  .tab[data-cat="startup"].active { background: var(--cyan-dim); color: var(--cyan); border-color: rgba(0,212,255,0.3); }
  .tab[data-cat="recon"].active { background: var(--purple-dim); color: var(--purple); border-color: rgba(168,85,247,0.3); }
  .tab[data-cat="nmap"].active { background: var(--green-dim2); color: var(--green); border-color: rgba(0,255,136,0.3); }
  .tab[data-cat="web"].active { background: var(--cyan-dim); color: var(--cyan); border-color: rgba(0,212,255,0.3); }
  .tab[data-cat="sql"].active { background: var(--red-dim); color: var(--red); border-color: rgba(239,68,68,0.3); }
  .tab[data-cat="ssl"].active { background: var(--amber-dim); color: var(--amber); border-color: rgba(245,158,11,0.3); }
  .tab[data-cat="sessions"].active { background: var(--purple-dim); color: var(--purple); border-color: rgba(168,85,247,0.3); }

  /* Sections */
  .section { margin-bottom: 2rem; }

  .section-header {
    display: flex; align-items: center; gap: 8px;
    margin-bottom: 10px;
  }

  .section-dot {
    width: 8px; height: 8px; border-radius: 50%;
    flex-shrink: 0;
  }

  .section-title {
    font-size: 11px; font-weight: 600;
    letter-spacing: 0.1em; text-transform: uppercase;
    font-family: var(--sans);
  }

  .section-count {
    font-size: 10px; font-family: var(--mono);
    padding: 1px 6px; border-radius: 99px;
    margin-left: auto;
  }

  /* Color themes per section */
  .sec-startup .section-dot { background: var(--cyan); }
  .sec-startup .section-title { color: var(--cyan); }
  .sec-startup .section-count { background: var(--cyan-dim); color: var(--cyan); }

  .sec-recon .section-dot { background: var(--purple); }
  .sec-recon .section-title { color: var(--purple); }
  .sec-recon .section-count { background: var(--purple-dim); color: var(--purple); }

  .sec-nmap .section-dot { background: var(--green); }
  .sec-nmap .section-title { color: var(--green); }
  .sec-nmap .section-count { background: var(--green-dim2); color: var(--green); }

  .sec-web .section-dot { background: var(--cyan); }
  .sec-web .section-title { color: var(--cyan); }
  .sec-web .section-count { background: var(--cyan-dim); color: var(--cyan); }

  .sec-sql .section-dot { background: var(--red); }
  .sec-sql .section-title { color: var(--red); }
  .sec-sql .section-count { background: var(--red-dim); color: var(--red); }

  .sec-ssl .section-dot { background: var(--amber); }
  .sec-ssl .section-title { color: var(--amber); }
  .sec-ssl .section-count { background: var(--amber-dim); color: var(--amber); }

  .sec-sessions .section-dot { background: var(--purple); }
  .sec-sessions .section-title { color: var(--purple); }
  .sec-sessions .section-count { background: var(--purple-dim); color: var(--purple); }

  /* Command cards */
  .cmd-grid { display: grid; grid-template-columns: 1fr; gap: 6px; }

  .cmd-card {
    background: var(--bg2);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 10px 14px;
    cursor: pointer;
    transition: border-color 0.15s, background 0.15s;
    position: relative;
  }

  .cmd-card:hover { border-color: var(--border2); background: var(--bg3); }

  .cmd-card.copied {
    border-color: rgba(0,255,136,0.4);
    background: var(--green-dim);
  }

  .cmd-top { display: flex; align-items: flex-start; justify-content: space-between; gap: 8px; }

  .cmd-label {
    font-size: 11px; color: var(--text2);
    font-family: var(--sans);
    margin-bottom: 5px;
  }

  .cmd-code {
    font-size: 12px; color: var(--text);
    font-family: var(--mono);
    word-break: break-all;
    line-height: 1.5;
  }

  .cmd-note {
    font-size: 11px; color: var(--text3);
    font-family: var(--sans);
    margin-top: 5px;
    line-height: 1.4;
  }

  .copy-btn {
    flex-shrink: 0;
    font-size: 10px; font-family: var(--mono);
    color: var(--text3);
    background: var(--bg4);
    border: 1px solid var(--border);
    border-radius: 4px;
    padding: 2px 8px;
    margin-top: 1px;
    white-space: nowrap;
    transition: all 0.15s;
  }

  .cmd-card:hover .copy-btn { color: var(--green); border-color: rgba(0,255,136,0.3); }
  .cmd-card.copied .copy-btn { color: var(--green); border-color: rgba(0,255,136,0.4); content: "copied"; }

  .empty {
    font-size: 13px; color: var(--text2);
    font-family: var(--sans);
    padding: 2rem 0; text-align: center;
  }

  /* Footer */
  .footer {
    max-width: 900px; margin: 0 auto;
    padding: 1rem 2rem 2rem;
    border-top: 1px solid var(--border);
    display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px;
  }

  .footer-text { font-size: 11px; color: var(--text3); font-family: var(--mono); }
  .footer-warn { font-size: 11px; color: rgba(245,158,11,0.6); font-family: var(--sans); }

  /* Scrollbar */
  ::-webkit-scrollbar { width: 6px; }
  ::-webkit-scrollbar-track { background: var(--bg); }
  ::-webkit-scrollbar-thumb { background: var(--bg4); border-radius: 3px; }
  ::-webkit-scrollbar-thumb:hover { background: var(--border2); }
</style>
</head>
<body>

<div class="header">
  <div class="header-inner">
    <div class="badge"><span class="badge-dot"></span>LIVE — kali-mcp-server</div>
    <h1>Kali MCP <span>Cheat Sheet</span></h1>
    <p class="subtitle">Run inside container: <code>docker exec -it kali-mcp-server bash</code></p>
    <div class="stats">
      <div class="stat"><span class="stat-num" id="total-count">0</span> commands</div>
      <div class="stat"><span class="stat-num">7</span> categories</div>
      <div class="stat"><span class="stat-num">35</span> Kali tools</div>
    </div>
  </div>
</div>

<div class="main">
  <div class="search-wrap">
    <span class="search-icon">⌕</span>
    <input class="search-bar" id="search" placeholder="Search commands, tools, flags..." oninput="render()" />
  </div>
  <div class="tabs" id="tabs"></div>
  <div id="content"></div>
</div>

<div class="footer">
  <span class="footer-text">spac3gh0st00 / kali-mcp-setup</span>
  <span class="footer-warn">For authorized security testing only</span>
</div>

<script>
const cats = {
  startup: {
    label: "Lab Startup", color: "cyan",
    cmds: [
      { label: "Enter Kali container", code: "docker exec -it kali-mcp-server bash", note: "Run in Termius after SSH into Ubuntu VM" },
      { label: "Start Kali MCP server", code: "cd ~/kali-mcp && docker compose up -d", note: "" },
      { label: "Stop Kali MCP server", code: "docker compose down", note: "" },
      { label: "Check container status", code: "docker ps", note: "" },
      { label: "View live logs", code: "docker logs -f kali-mcp-server", note: "" },
      { label: "Check Tailscale status", code: "tailscale status", note: "Run on Ubuntu VM" },
      { label: "Get VM IP address", code: "hostname -I", note: "Check this if IP changes after reboot" },
      { label: "Rebuild container", code: "docker compose up --build -d", note: "Use after pulling updates" },
    ]
  },
  recon: {
    label: "Recon", color: "purple",
    cmds: [
      { label: "DNS enumeration", code: "dnsenum --enum target.com", note: "Subdomains, MX, NS, zone transfer attempts" },
      { label: "Subdomain brute force", code: "gobuster dns -d target.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt", note: "" },
      { label: "Whois lookup", code: "whois target.com", note: "Registration info, nameservers, contact details" },
      { label: "Passive subdomain discovery", code: "sublist3r -d target.com -o subs.txt", note: "Uses public sources — no direct contact with target" },
      { label: "Certificate transparency", code: "curl -s 'https://crt.sh/?q=%.target.com&output=json' | jq '.[].name_value'", note: "Finds subdomains via SSL cert history" },
      { label: "Reverse DNS lookup", code: "dig -x 192.168.1.1", note: "" },
      { label: "Find all DNS records", code: "dig any target.com", note: "" },
    ]
  },
  nmap: {
    label: "Nmap", color: "green",
    cmds: [
      { label: "Quick service scan", code: "nmap -sV -T4 target.com", note: "Top 1000 ports with version detection" },
      { label: "Full port scan", code: "nmap -sV -p- -T4 target.com", note: "All 65535 ports — slow but thorough" },
      { label: "Aggressive scan", code: "nmap -A -T4 target.com", note: "OS detection, versions, scripts, traceroute" },
      { label: "UDP scan", code: "nmap -sU -T4 --top-ports 100 target.com", note: "Finds DNS, SNMP, TFTP services" },
      { label: "Vulnerability scripts", code: "nmap --script vuln target.com", note: "Runs built-in CVE and vuln detection scripts" },
      { label: "Save scan to file", code: "nmap -sV target.com -oN /app/sessions/scan.txt", note: "Persists output for reporting" },
      { label: "Check SSL ciphers", code: "nmap --script ssl-enum-ciphers -p 443 target.com", note: "" },
      { label: "Heartbleed check", code: "nmap --script ssl-heartbleed target.com", note: "" },
      { label: "HTTP methods check", code: "nmap --script http-methods target.com", note: "Finds PUT, DELETE, TRACE etc" },
    ]
  },
  web: {
    label: "Web Scanning", color: "cyan",
    cmds: [
      { label: "Directory brute force", code: "gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt", note: "" },
      { label: "Dir scan with extensions", code: "gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt -x php,html,js,txt,bak", note: "" },
      { label: "Nikto web vulnerability scan", code: "nikto -h https://target.com", note: "Checks misconfigs, outdated software, dangerous files" },
      { label: "Find exposed JS files", code: "gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt -x js", note: "Look for API keys and secrets" },
      { label: "Check security headers", code: "curl -sI https://target.com | grep -i 'x-frame\\|content-security\\|strict-transport\\|x-content\\|permissions'", note: "" },
      { label: "Follow redirect chain", code: "curl -sIL https://target.com", note: "Shows all redirects to final destination" },
      { label: "Spider site for links", code: "wget --spider -r -nd -nv https://target.com 2>&1 | grep '^--' | awk '{ print $3 }'", note: "" },
      { label: "Check robots.txt", code: "curl -s https://target.com/robots.txt", note: "Often reveals hidden paths" },
    ]
  },
  sql: {
    label: "SQLMap", color: "red",
    cmds: [
      { label: "Test GET parameter", code: "sqlmap -u 'https://target.com/page?id=1' --dbs", note: "Enumerate databases if vulnerable" },
      { label: "Test POST request", code: "sqlmap -u 'https://target.com/login' --data='user=test&pass=test' --dbs", note: "" },
      { label: "Authenticated with cookie", code: "sqlmap -u 'https://target.com/page?id=1' --cookie='session=abc123' --dbs", note: "" },
      { label: "List tables in database", code: "sqlmap -u 'https://target.com/page?id=1' -D dbname --tables", note: "" },
      { label: "Dump table contents", code: "sqlmap -u 'https://target.com/page?id=1' -D dbname -T users --dump", note: "" },
      { label: "Risk and level tuning", code: "sqlmap -u 'https://target.com/page?id=1' --level=3 --risk=2 --dbs", note: "Higher = more tests, more noise" },
    ]
  },
  ssl: {
    label: "SSL / TLS", color: "amber",
    cmds: [
      { label: "Full SSL vulnerability scan", code: "sslscan target.com", note: "Weak ciphers, BEAST, POODLE, CRIME, DROWN" },
      { label: "Certificate details", code: "openssl s_client -connect target.com:443 </dev/null 2>/dev/null | openssl x509 -noout -text", note: "" },
      { label: "Check expiry date", code: "echo | openssl s_client -connect target.com:443 2>/dev/null | openssl x509 -noout -dates", note: "" },
      { label: "Check cipher suites", code: "nmap --script ssl-enum-ciphers -p 443 target.com", note: "" },
      { label: "Test for Heartbleed", code: "nmap --script ssl-heartbleed -p 443 target.com", note: "CVE-2014-0160" },
    ]
  },
  sessions: {
    label: "Sessions & Output", color: "purple",
    cmds: [
      { label: "List saved sessions", code: "ls /app/sessions/", note: "Persists across container restarts" },
      { label: "Save nmap output", code: "nmap -sV target.com -oN /app/sessions/portscan.txt", note: "" },
      { label: "Save gobuster output", code: "gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt -o /app/sessions/dirs.txt", note: "" },
      { label: "View saved file", code: "cat /app/sessions/portscan.txt", note: "" },
      { label: "Create session folder", code: "mkdir -p /app/sessions/target-name", note: "Organize by target" },
    ]
  }
};

const catKeys = Object.keys(cats);
let active = "all";
let copyTimeouts = {};

function totalCmds() {
  return catKeys.reduce((acc, k) => acc + cats[k].cmds.length, 0);
}

document.getElementById('total-count').textContent = totalCmds();

function render() {
  const q = document.getElementById("search").value.toLowerCase();
  const content = document.getElementById("content");
  const tabs = document.getElementById("tabs");

  tabs.innerHTML = `<div class="tab ${active==='all'?'active':''}" onclick="setTab('all')">All</div>` +
    catKeys.map(k =>
      `<div class="tab ${active===k?'active':''}" data-cat="${k}" onclick="setTab('${k}')">${cats[k].label}</div>`
    ).join('');

  let html = '';
  const toShow = active === 'all' ? catKeys : [active];

  toShow.forEach(k => {
    const sec = cats[k];
    const filtered = sec.cmds.filter(c =>
      !q || c.label.toLowerCase().includes(q) || c.code.toLowerCase().includes(q) || (c.note && c.note.toLowerCase().includes(q))
    );
    if (!filtered.length) return;

    html += `<div class="section sec-${k}">
      <div class="section-header">
        <div class="section-dot"></div>
        <div class="section-title">${sec.label}</div>
        <div class="section-count">${filtered.length}</div>
      </div>
      <div class="cmd-grid">`;

    filtered.forEach((c, i) => {
      const id = `${k}-${i}`;
      const esc = c.code.replace(/\\/g,'\\\\').replace(/'/g,"\\'").replace(/"/g,'&quot;');
      html += `<div class="cmd-card" id="${id}" onclick="copy('${id}','${esc}')">
        <div class="cmd-top">
          <div>
            <div class="cmd-label">${c.label}</div>
            <div class="cmd-code">${c.code}</div>
            ${c.note ? `<div class="cmd-note">${c.note}</div>` : ''}
          </div>
          <div class="copy-btn" id="btn-${id}">copy</div>
        </div>
      </div>`;
    });

    html += `</div></div>`;
  });

  content.innerHTML = html || '<div class="empty">No commands match your search.</div>';
}

function setTab(k) { active = k; render(); }

function copy(id, code) {
  const decoded = code.replace(/&quot;/g, '"');
  navigator.clipboard.writeText(decoded).catch(() => {});
  const card = document.getElementById(id);
  const btn = document.getElementById('btn-' + id);
  card.classList.add('copied');
  if (btn) btn.textContent = 'copied!';
  clearTimeout(copyTimeouts[id]);
  copyTimeouts[id] = setTimeout(() => {
    card.classList.remove('copied');
    if (btn) btn.textContent = 'copy';
  }, 1500);
}

render();
</script>
</body>
</html>

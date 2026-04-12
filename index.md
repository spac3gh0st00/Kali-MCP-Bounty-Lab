<style>
  @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&display=swap');
  #kali-root { --bg:#0d0f14;--bg2:#13161d;--bg3:#1a1d26;--bg4:#1f2330;--bdr:rgba(255,255,255,0.06);--bdr2:rgba(255,255,255,0.12);--tx:#e2e8f0;--tx2:#8892a4;--tx3:#4a5568;--gr:#00ff88;--gr2:rgba(0,255,136,0.15);--cy:#00d4ff;--cy2:rgba(0,212,255,0.08);--pu:#a855f7;--pu2:rgba(168,85,247,0.08);--am:#f59e0b;--am2:rgba(245,158,11,0.08);--rd:#ef4444;--rd2:rgba(239,68,68,0.08);--mono:'JetBrains Mono',ui-monospace,monospace;font-family:var(--mono);background:var(--bg);color:var(--tx);border-radius:12px;overflow:hidden;min-height:400px;}
  #kali-root *{box-sizing:border-box;margin:0;padding:0;}
  .kh{background:var(--bg2);border-bottom:1px solid var(--bdr2);padding:1.25rem 1.5rem 1rem;}
  .kbadge{display:inline-flex;align-items:center;gap:6px;background:rgba(0,255,136,0.12);border:1px solid rgba(0,255,136,0.25);color:var(--gr);font-size:10px;font-weight:500;padding:3px 10px;border-radius:99px;margin-bottom:10px;letter-spacing:.05em;}
  .kbdot{width:6px;height:6px;background:var(--gr);border-radius:50%;animation:kpulse 2s infinite;}
  @keyframes kpulse{0%,100%{opacity:1}50%{opacity:.3}}
  .kh h1{font-size:22px;font-weight:600;color:var(--tx);margin-bottom:4px;letter-spacing:-.02em;}
  .kh h1 span{color:var(--gr);}
  .ksub{font-size:11px;color:var(--tx2);margin-bottom:10px;}
  .ksub code{color:var(--cy);background:var(--cy2);padding:2px 6px;border-radius:4px;font-size:11px;}
  .kstats{display:flex;gap:1.25rem;flex-wrap:wrap;}
  .kstat{font-size:11px;color:var(--tx2);}
  .kstat b{color:var(--gr);font-weight:600;}
  .kmain{padding:1rem 1.5rem 2rem;}
  .ksearch-wrap{position:relative;margin-bottom:1rem;}
  .ksearch-icon{position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--tx3);font-size:13px;pointer-events:none;}
  .ksearch{width:100%;padding:9px 10px 9px 32px;font-size:12px;border:1px solid var(--bdr2);border-radius:8px;background:var(--bg2);color:var(--tx);font-family:var(--mono);outline:none;transition:border-color .2s;}
  .ksearch::placeholder{color:var(--tx3);}
  .ksearch:focus{border-color:rgba(0,255,136,.4);}
  .ktabs{display:flex;flex-wrap:wrap;gap:5px;margin-bottom:1.25rem;}
  .ktab{padding:4px 12px;font-size:11px;font-weight:500;border:1px solid var(--bdr2);border-radius:99px;cursor:pointer;background:var(--bg2);color:var(--tx2);transition:all .15s;}
  .ktab:hover{color:var(--tx);}
  .ktab.all.on{background:rgba(0,255,136,.12);color:var(--gr);border-color:rgba(0,255,136,.3);}
  .ktab.startup.on{background:var(--cy2);color:var(--cy);border-color:rgba(0,212,255,.3);}
  .ktab.recon.on,.ktab.sessions.on{background:var(--pu2);color:var(--pu);border-color:rgba(168,85,247,.3);}
  .ktab.nmap.on{background:rgba(0,255,136,.12);color:var(--gr);border-color:rgba(0,255,136,.3);}
  .ktab.web.on{background:var(--cy2);color:var(--cy);border-color:rgba(0,212,255,.3);}
  .ktab.sql.on{background:var(--rd2);color:var(--rd);border-color:rgba(239,68,68,.3);}
  .ktab.ssl.on{background:var(--am2);color:var(--am);border-color:rgba(245,158,11,.3);}
  .ksec{margin-bottom:1.75rem;}
  .ksec-hd{display:flex;align-items:center;gap:7px;margin-bottom:8px;}
  .ksec-dot{width:7px;height:7px;border-radius:50%;flex-shrink:0;}
  .ksec-title{font-size:10px;font-weight:600;letter-spacing:.1em;text-transform:uppercase;}
  .ksec-cnt{font-size:10px;padding:1px 6px;border-radius:99px;margin-left:auto;}
  .startup .ksec-dot,.startup .ksec-title{background:var(--cy);color:var(--cy);}
  .startup .ksec-cnt{background:var(--cy2);color:var(--cy);}
  .recon .ksec-dot,.recon .ksec-title,.sessions .ksec-dot,.sessions .ksec-title{background:var(--pu);color:var(--pu);}
  .recon .ksec-cnt,.sessions .ksec-cnt{background:var(--pu2);color:var(--pu);}
  .nmap .ksec-dot,.nmap .ksec-title{background:var(--gr);color:var(--gr);}
  .nmap .ksec-cnt{background:var(--gr2);color:var(--gr);}
  .web .ksec-dot,.web .ksec-title{background:var(--cy);color:var(--cy);}
  .web .ksec-cnt{background:var(--cy2);color:var(--cy);}
  .sql .ksec-dot,.sql .ksec-title{background:var(--rd);color:var(--rd);}
  .sql .ksec-cnt{background:var(--rd2);color:var(--rd);}
  .ssl .ksec-dot,.ssl .ksec-title{background:var(--am);color:var(--am);}
  .ssl .ksec-cnt{background:var(--am2);color:var(--am);}
  .kcard{background:var(--bg2);border:1px solid var(--bdr);border-radius:8px;padding:9px 12px;cursor:pointer;transition:border-color .15s,background .15s;display:flex;align-items:flex-start;justify-content:space-between;gap:8px;margin-bottom:5px;}
  .kcard:hover{border-color:var(--bdr2);background:var(--bg3);}
  .kcard.ok{border-color:rgba(0,255,136,.4);background:rgba(0,255,136,.06);}
  .klabel{font-size:10px;color:var(--tx2);margin-bottom:4px;}
  .kcode{font-size:11px;color:var(--tx);word-break:break-all;line-height:1.5;}
  .knote{font-size:10px;color:var(--tx3);margin-top:4px;line-height:1.4;font-family:var(--mono);}
  .kcopy{flex-shrink:0;font-size:10px;color:var(--tx3);background:var(--bg4);border:1px solid var(--bdr);border-radius:4px;padding:2px 8px;margin-top:2px;white-space:nowrap;transition:all .15s;cursor:pointer;}
  .kcard:hover .kcopy{color:var(--gr);border-color:rgba(0,255,136,.3);}
  .kempty{font-size:12px;color:var(--tx2);padding:2rem 0;text-align:center;}
  .kfoot{padding:.75rem 1.5rem 1rem;border-top:1px solid var(--bdr);display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px;}
  .kfoot-l{font-size:10px;color:var(--tx3);}
  .kfoot-r{font-size:10px;color:rgba(245,158,11,.6);}
</style>

<div id="kali-root">
<h2 class="sr-only" style="position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0,0,0,0);">Kali MCP cheat sheet — searchable command reference for bug bounty and security lab workflows</h2>
<div class="kh">
  <div class="kbadge"><span class="kbdot"></span>LIVE — kali-mcp-server</div>
  <h1>Kali MCP <span>Cheat Sheet</span></h1>
  <p class="ksub">Run inside container: <code>docker exec -it kali-mcp-server bash</code></p>
  <div class="kstats">
    <div class="kstat"><b id="total">0</b> commands</div>
    <div class="kstat"><b>7</b> categories</div>
    <div class="kstat"><b>35</b> Kali tools</div>
  </div>
</div>
<div class="kmain">
  <div class="ksearch-wrap">
    <span class="ksearch-icon">⌕</span>
    <input class="ksearch" id="q" placeholder="Search commands, tools, flags..." />
  </div>
  <div class="ktabs" id="tabs"></div>
  <div id="content"></div>
</div>
<div class="kfoot">
  <span class="kfoot-l">spac3gh0st00 / kali-mcp-setup</span>
  <span class="kfoot-r">For authorized security testing only</span>
</div>
</div>

<script>
const D={
  startup:{label:"Lab Startup",cmds:[
    {label:"Enter Kali container",code:"docker exec -it kali-mcp-server bash",note:"Run in Termius after SSH into Ubuntu VM"},
    {label:"Start Kali MCP server",code:"cd ~/kali-mcp && docker compose up -d"},
    {label:"Stop Kali MCP server",code:"docker compose down"},
    {label:"Check container status",code:"docker ps"},
    {label:"View live logs",code:"docker logs -f kali-mcp-server"},
    {label:"Check Tailscale status",code:"tailscale status",note:"Run on Ubuntu VM"},
    {label:"Get VM IP address",code:"hostname -I",note:"Check this if IP changes after reboot"},
    {label:"Rebuild container",code:"docker compose up --build -d",note:"Use after pulling updates"},
  ]},
  recon:{label:"Recon",cmds:[
    {label:"DNS enumeration",code:"dnsenum --enum target.com",note:"Subdomains, MX, NS, zone transfer attempts"},
    {label:"Subdomain brute force",code:"gobuster dns -d target.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt"},
    {label:"Whois lookup",code:"whois target.com",note:"Registration info, nameservers, contact details"},
    {label:"Passive subdomain discovery",code:"sublist3r -d target.com -o subs.txt",note:"Uses public sources — no direct contact with target"},
    {label:"Certificate transparency",code:"curl -s 'https://crt.sh/?q=%.target.com&output=json' | jq '.[].name_value'",note:"Finds subdomains via SSL cert history"},
    {label:"Reverse DNS lookup",code:"dig -x 192.168.1.1"},
    {label:"Find all DNS records",code:"dig any target.com"},
  ]},
  nmap:{label:"Nmap",cmds:[
    {label:"Quick service scan",code:"nmap -sV -T4 target.com",note:"Top 1000 ports with version detection"},
    {label:"Full port scan",code:"nmap -sV -p- -T4 target.com",note:"All 65535 ports — slow but thorough"},
    {label:"Aggressive scan",code:"nmap -A -T4 target.com",note:"OS detection, versions, scripts, traceroute"},
    {label:"UDP scan",code:"nmap -sU -T4 --top-ports 100 target.com",note:"Finds DNS, SNMP, TFTP services"},
    {label:"Vulnerability scripts",code:"nmap --script vuln target.com",note:"Runs built-in CVE and vuln detection scripts"},
    {label:"Save scan to file",code:"nmap -sV target.com -oN /app/sessions/scan.txt",note:"Persists output for reporting"},
    {label:"Check SSL ciphers",code:"nmap --script ssl-enum-ciphers -p 443 target.com"},
    {label:"Heartbleed check",code:"nmap --script ssl-heartbleed target.com"},
    {label:"HTTP methods check",code:"nmap --script http-methods target.com",note:"Finds PUT, DELETE, TRACE etc"},
  ]},
  web:{label:"Web Scanning",cmds:[
    {label:"Directory brute force",code:"gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt"},
    {label:"Dir scan with extensions",code:"gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt -x php,html,js,txt,bak"},
    {label:"Nikto web vulnerability scan",code:"nikto -h https://target.com",note:"Checks misconfigs, outdated software, dangerous files"},
    {label:"Find exposed JS files",code:"gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt -x js",note:"Look for API keys and secrets"},
    {label:"Check security headers",code:"curl -sI https://target.com | grep -i 'x-frame\\|content-security\\|strict-transport\\|x-content\\|permissions'"},
    {label:"Follow redirect chain",code:"curl -sIL https://target.com",note:"Shows all redirects to final destination"},
    {label:"Spider site for links",code:"wget --spider -r -nd -nv https://target.com 2>&1 | grep '^--' | awk '{ print $3 }'"},
    {label:"Check robots.txt",code:"curl -s https://target.com/robots.txt",note:"Often reveals hidden paths"},
  ]},
  sql:{label:"SQLMap",cmds:[
    {label:"Test GET parameter",code:"sqlmap -u 'https://target.com/page?id=1' --dbs",note:"Enumerate databases if vulnerable"},
    {label:"Test POST request",code:"sqlmap -u 'https://target.com/login' --data='user=test&pass=test' --dbs"},
    {label:"Authenticated with cookie",code:"sqlmap -u 'https://target.com/page?id=1' --cookie='session=abc123' --dbs"},
    {label:"List tables in database",code:"sqlmap -u 'https://target.com/page?id=1' -D dbname --tables"},
    {label:"Dump table contents",code:"sqlmap -u 'https://target.com/page?id=1' -D dbname -T users --dump"},
    {label:"Risk and level tuning",code:"sqlmap -u 'https://target.com/page?id=1' --level=3 --risk=2 --dbs",note:"Higher = more tests, more noise"},
  ]},
  ssl:{label:"SSL / TLS",cmds:[
    {label:"Full SSL vulnerability scan",code:"sslscan target.com",note:"Weak ciphers, BEAST, POODLE, CRIME, DROWN"},
    {label:"Certificate details",code:"openssl s_client -connect target.com:443 </dev/null 2>/dev/null | openssl x509 -noout -text"},
    {label:"Check expiry date",code:"echo | openssl s_client -connect target.com:443 2>/dev/null | openssl x509 -noout -dates"},
    {label:"Check cipher suites",code:"nmap --script ssl-enum-ciphers -p 443 target.com"},
    {label:"Test for Heartbleed",code:"nmap --script ssl-heartbleed -p 443 target.com",note:"CVE-2014-0160"},
  ]},
  sessions:{label:"Sessions & Output",cmds:[
    {label:"List saved sessions",code:"ls /app/sessions/",note:"Persists across container restarts"},
    {label:"Save nmap output",code:"nmap -sV target.com -oN /app/sessions/portscan.txt"},
    {label:"Save gobuster output",code:"gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt -o /app/sessions/dirs.txt"},
    {label:"View saved file",code:"cat /app/sessions/portscan.txt"},
    {label:"Create session folder",code:"mkdir -p /app/sessions/target-name",note:"Organize by target"},
  ]},
};

const keys=Object.keys(D);
let active='all';
const timers={};

document.getElementById('total').textContent=keys.reduce((a,k)=>a+D[k].cmds.length,0);

function render(){
  const q=document.getElementById('q').value.toLowerCase();
  const tabs=document.getElementById('tabs');
  const content=document.getElementById('content');

  tabs.innerHTML=`<div class="ktab all ${active==='all'?'on':''}" data-k="all">All</div>`+
    keys.map(k=>`<div class="ktab ${k} ${active===k?'on':''}" data-k="${k}">${D[k].label}</div>`).join('');

  tabs.querySelectorAll('.ktab').forEach(t=>t.addEventListener('click',()=>{active=t.dataset.k;render();}));

  const show=active==='all'?keys:[active];
  let html='';

  show.forEach(k=>{
    const sec=D[k];
    const filtered=sec.cmds.filter(c=>!q||c.label.toLowerCase().includes(q)||c.code.toLowerCase().includes(q)||(c.note&&c.note.toLowerCase().includes(q)));
    if(!filtered.length)return;
    html+=`<div class="ksec ${k}"><div class="ksec-hd"><div class="ksec-dot"></div><div class="ksec-title">${sec.label}</div><div class="ksec-cnt">${filtered.length}</div></div>`;
    filtered.forEach((c,i)=>{
      const id=`${k}-${i}`;
      const esc=c.code.replace(/\\/g,'\\\\').replace(/'/g,"\\'").replace(/`/g,'\\`');
      html+=`<div class="kcard" id="${id}" data-code="${c.code.replace(/"/g,'&quot;')}">
        <div style="flex:1;min-width:0;">
          <div class="klabel">${c.label}</div>
          <div class="kcode">${c.code}</div>
          ${c.note?`<div class="knote">${c.note}</div>`:''}
        </div>
        <div class="kcopy" id="btn-${id}">copy</div>
      </div>`;
    });
    html+='</div>';
  });

  content.innerHTML=html||'<div class="kempty">No commands match your search.</div>';

  content.querySelectorAll('.kcard').forEach(card=>{
    card.addEventListener('click',()=>{
      const code=card.dataset.code.replace(/&quot;/g,'"');
      const id=card.id;
      const btn=document.getElementById('btn-'+id);
      navigator.clipboard.writeText(code).catch(()=>{});
      card.classList.add('ok');
      if(btn)btn.textContent='copied!';
      clearTimeout(timers[id]);
      timers[id]=setTimeout(()=>{card.classList.remove('ok');if(btn)btn.textContent='copy';},1500);
    });
  });
}

document.getElementById('q').addEventListener('input',render);
render();
</script>

param(
    [string]$Port = ""
)

Write-Host "== Codex Connectivity Diagnostic: Windows PowerShell =="
Write-Host "This script prints proxy, loopback, DNS, and optional callback-port diagnostics."
Write-Host "Do not paste tokens, cookies, OAuth codes, or full sensitive callback URLs into issue reports."
Write-Host ""

Write-Host "== System =="
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer | Format-List
Get-Date
Write-Host ""

Write-Host "== Proxy environment =="
Get-ChildItem Env:*proxy* -ErrorAction SilentlyContinue
Write-Host ""

Write-Host "== WinHTTP proxy =="
netsh winhttp show proxy
Write-Host ""

Write-Host "== NO_PROXY check =="
Write-Host "NO_PROXY=$env:NO_PROXY"
Write-Host "Recommended loopback bypass: localhost,127.0.0.1,::1"
Write-Host ""

if ($Port -ne "") {
    Write-Host "== Callback port check: $Port =="
    netstat -ano | findstr ":$Port"
    Write-Host ""
    Write-Host "Testing http://127.0.0.1:$Port/"
    try {
        curl.exe -v --max-time 5 "http://127.0.0.1:$Port/" 2>&1 | Select-Object -First 80
    } catch {
        Write-Host $_
    }
    Write-Host ""
} else {
    Write-Host "== Callback port check skipped =="
    Write-Host "Pass a port, for example: .\diagnose_codex_connectivity.ps1 -Port 1455"
    Write-Host ""
}

Write-Host "== DNS check =="
nslookup api.openai.com
Write-Host ""

Write-Host "== HTTPS reachability check =="
try {
    curl.exe -I --connect-timeout 10 https://api.openai.com 2>&1 | Select-Object -First 80
} catch {
    Write-Host $_
}

Write-Host ""
Write-Host "== Done =="

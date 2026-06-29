param(
    [string]$Port = "",
    [string]$TargetDomain = "api.openai.com"
)

$CandidatePorts = @(7890, 7891, 7897, 1080, 10808, 10809, 20170, 2080, 8080, 8888, 9090)

Write-Host "== Codex / AI CLI Proxy Assist: Windows PowerShell =="
Write-Host "This script discovers system-visible local proxy candidates and prints temporary retry commands."
Write-Host "It only uses system-visible settings and localhost ports. It does not read VPN credentials or private VPN configs."
Write-Host "Do not paste tokens, cookies, OAuth codes, or full sensitive callback URLs into issue reports."
Write-Host ""

Write-Host "== System =="
try {
    Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer | Format-List
} catch {
    Write-Host "Get-ComputerInfo unavailable."
}
Get-Date
Write-Host ""

Write-Host "== Target domain =="
Write-Host $TargetDomain
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

Write-Host "== Local proxy candidate ports =="
foreach ($p in $CandidatePorts) {
    $listening = netstat -ano | findstr ":$p"
    if ($listening) {
        Write-Host "candidate listening: 127.0.0.1:$p"
    }
}
Write-Host ""

Write-Host "== Proxy candidate reachability test =="
foreach ($p in $CandidatePorts) {
    $listening = netstat -ano | findstr ":$p"
    if ($listening) {
        Write-Host "-- Testing HTTP proxy candidate 127.0.0.1:$p -> https://$TargetDomain"
        try {
            curl.exe -I --proxy "http://127.0.0.1:$p" --connect-timeout 8 "https://$TargetDomain" 1>$null 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "WORKING_HTTP_PROXY=http://127.0.0.1:$p"
                Write-Host "Temporary retry example:"
                Write-Host "`$env:HTTPS_PROXY='http://127.0.0.1:$p'; `$env:HTTP_PROXY='http://127.0.0.1:$p'; `$env:NO_PROXY='localhost,127.0.0.1,::1'; <FAILED_COMMAND>"
            }
        } catch {}

        Write-Host "-- Testing SOCKS proxy candidate 127.0.0.1:$p -> https://$TargetDomain"
        try {
            curl.exe -I --proxy "socks5h://127.0.0.1:$p" --connect-timeout 8 "https://$TargetDomain" 1>$null 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "WORKING_SOCKS_PROXY=socks5h://127.0.0.1:$p"
                Write-Host "Temporary retry example:"
                Write-Host "`$env:ALL_PROXY='socks5://127.0.0.1:$p'; `$env:NO_PROXY='localhost,127.0.0.1,::1'; <FAILED_COMMAND>"
            }
        } catch {}
    }
}
Write-Host ""

if ($Port -ne "") {
    Write-Host "== Optional callback port support: $Port =="
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
    Write-Host "== Optional callback port support skipped =="
    Write-Host "Pass callback port and target domain, for example:"
    Write-Host ".\proxy_assist.ps1 -Port 1455 -TargetDomain api.openai.com"
    Write-Host ""
}

Write-Host "== Target-domain fallback check =="
nslookup $TargetDomain
Write-Host ""

try {
    curl.exe -I --connect-timeout 10 "https://$TargetDomain" 2>&1 | Select-Object -First 80
} catch {
    Write-Host $_
}

Write-Host ""
Write-Host "== Done =="

---
name: codex-connectivity-troubleshooter
description: Troubleshoot Codex and developer-tool startup, login, browser callback, localhost port, proxy, DNS, TLS, firewall, and cross-region or restricted-network issues. Use when Codex, an IDE extension, CLI, desktop app, browser login, OAuth callback, local development service, API endpoint, or region-specific developer service cannot start, cannot authenticate, times out, opens the wrong local port, or fails behind a proxy/VPN/TUN/campus/company network. Applies to users in any region, including mainland China users accessing overseas services and overseas users accessing China-hosted services. Respond in Chinese, English, or Japanese according to the user's language.
---

# Codex Connectivity Troubleshooter Skill

## 0. Scope / 范围 / 範囲

This skill helps diagnose and fix startup, login, OAuth callback, local port, proxy, DNS, TLS, firewall, cross-region routing, and restricted-network problems affecting Codex or adjacent developer tools.

This skill is not limited to one country or direction of access. It covers cases such as:

- Mainland China users accessing overseas developer services.
- Overseas users accessing China-hosted developer services.
- Users on campus, company, hotel, public Wi-Fi, proxy, VPN, TUN, or split-tunnel networks.
- Users whose browser, terminal, IDE, and desktop app do not share the same network path.

本 Skill 用于排查 Codex 或相关开发工具在跨地区网络、受限网络、校园网、公司网、代理/VPN/TUN 环境下出现的启动、登录、OAuth 回调、本地端口、代理、DNS、TLS、系统防火墙等问题。

本 Skill 不只面向中国用户，也不只处理“中国访问海外服务”的问题。它同样适用于海外用户访问中国服务、不同地区之间访问失败、浏览器能访问但终端/IDE/Codex 不能访问等情况。

この Skill は、Codex または関連開発ツールの起動、ログイン、OAuth コールバック、localhost ポート、プロキシ、DNS、TLS、ファイアウォール、地域間アクセス、制限付きネットワークの問題を診断するために使う。

対象は特定の国に限定しない。中国本土から海外サービスへアクセスする場合、海外から中国向けサービスへアクセスする場合、大学・企業・ホテル・公共 Wi-Fi・プロキシ・VPN・TUN・split tunnel 環境で発生する問題も対象とする。

Use this skill when the user reports problems such as:

- Codex cannot log in, browser login opens but does not return to the app.
- Login fails because the callback port is wrong, blocked, occupied, or routed through a proxy.
- CLI/desktop/IDE extension starts but cannot connect to the service.
- Requests time out only on a particular country/region, campus network, company network, or proxy path.
- A user in one region cannot access a service hosted in another region.
- Proxy/VPN works in browser but not in terminal, IDE, or Codex.
- `localhost`, `127.0.0.1`, or `::1` behaves inconsistently.
- OpenAI/GitHub authentication fails, token refresh fails, or TLS/DNS errors appear.

---

## 1. Operating Rules / 操作规则 / 運用ルール

### 1.1 First response rule

When this skill is triggered, do **not** immediately reinstall everything. Start with a short diagnosis plan:

1. Identify the client: Codex web, Codex desktop, CLI, VS Code/JetBrains/Xcode extension, browser, or another app.
2. Identify the target service: OpenAI/Codex, GitHub, a China-hosted service, an overseas API, a private company endpoint, or another domain.
3. Identify the failure point: app launch, browser login, OAuth callback, local port, proxy, DNS, TLS, GitHub auth, OpenAI auth, target-domain routing, firewall, or system keychain.
4. Ask for only the minimum missing data if needed: OS, exact error text, callback URL/port, target domain, proxy mode, and whether browser access works.
5. Give commands for the user's OS.
6. Redact secrets before asking for logs.

中文：不要一开始就让用户重装。先判断“客户端类型”“目标服务/目标域名”和“失败位置”。只要必要信息，不要让用户贴 token、cookie、完整 refresh token 或带 OAuth 参数的完整 URL。

日本語：最初から再インストールを案内しない。まずクライアント種別、対象サービス/対象ドメイン、失敗箇所を切り分ける。ログを求める場合は必ずシークレットを伏せる。

### 1.2 Security rule

Never ask the user to paste secrets. Treat these as sensitive:

- OpenAI session tokens, refresh tokens, API keys
- GitHub tokens, OAuth codes, cookies
- Proxy usernames/passwords
- Private company tokens or internal service credentials
- Full browser callback URLs when they contain `code=`, `state=`, `token=`, or `session=`

Ask the user to replace values with:

```text
<REDACTED_TOKEN>
<REDACTED_CODE>
<REDACTED_COOKIE>
<REDACTED_INTERNAL_DOMAIN_IF_NEEDED>
```

### 1.3 Legality and policy rule

Do not provide instructions for bypassing local law, employer policy, campus policy, or platform terms. Keep guidance limited to legitimate network configuration, proxy consistency, local loopback routing, diagnostics, DNS/TLS analysis, official client settings, and organization-approved access methods.

中文：只处理合法合规的网络配置、代理一致性、本地回调端口、DNS/TLS/防火墙诊断。不要指导规避法律、组织政策、校园政策或平台规则。

日本語：法律、組織ポリシー、大学ネットワーク規則、プラットフォーム規約の回避を目的とした手順は提供しない。正当なネットワーク設定と診断に限定する。

---

## 2. Required Diagnosis Template / 必要诊断模板 / 必須診断テンプレート

When the user gives insufficient information, request this compact template:

```text
1. OS: macOS / Windows / Linux, version:
2. Client: Codex desktop / Codex CLI / VS Code extension / browser / other:
3. Target service/domain: OpenAI/Codex / GitHub / China-hosted service / overseas API / company endpoint / other:
4. User region and network type: home / campus / company / public Wi-Fi / proxy / VPN / TUN / split tunnel:
5. Error stage: start / browser login / callback / request timeout / DNS / TLS / GitHub auth / other:
6. Exact error text or screenshot:
7. Callback URL or port, with code/token redacted:
8. Proxy/VPN mode: none / system proxy / TUN / browser-only / company/campus network:
9. Does the target domain open in the browser: yes/no:
10. Does terminal traffic use the same proxy or route as the browser: yes/no/unknown:
```

If the user already gave enough information, do not ask again. Proceed with a best-effort fix.

---

## 3. Core Decision Tree / 核心排查路径 / 中核判断フロー

### Step A — Determine whether this is a local callback/port problem

Symptoms:

- Browser login succeeds, but Codex/CLI/IDE still says not logged in.
- Error mentions `localhost`, `127.0.0.1`, `::1`, callback, redirect URI, or a port.
- The browser opens a URL like `http://127.0.0.1:PORT/...` but the app never receives it.
- User recently changed port/proxy and login broke.

Actions:

**macOS / Linux**

```bash
# Replace PORT with the callback port shown in the browser URL.
lsof -nP -iTCP:PORT -sTCP:LISTEN
curl -v http://127.0.0.1:PORT/ 2>&1 | head -40
```

**Windows PowerShell**

```powershell
# Replace PORT with the callback port shown in the browser URL.
netstat -ano | findstr :PORT
Get-Process -Id <PID>
```

Fix rules:

- If the port is occupied by another process, close that process or change the client callback port through official settings.
- If the callback URL uses `localhost` but IPv6 breaks, try `127.0.0.1` if the client supports it.
- If the proxy/VPN/TUN captures localhost traffic, add loopback exclusions: `localhost`, `127.0.0.1`, `::1`.
- Do not invent undocumented flags. Check `--help`, official settings, or existing config before changing hidden options.

中文重点：登录失败但浏览器显示成功，通常优先查“本地回调端口”和“localhost 被代理/TUN 接管”。这与用户在哪个国家无关。

日本語要点：ブラウザ上では成功しているのにアプリ側が未ログインの場合、まずローカルコールバックポートと loopback のプロキシ除外を確認する。これはユーザーの国に依存しない。

### Step B — Determine whether terminal/IDE traffic uses a different proxy or route from the browser

Symptoms:

- Browser can open the target site, but CLI/IDE/Codex fails.
- `curl` times out while browser works.
- Proxy is browser-only, not system-wide.
- A service works from one region/network but fails from another.

Check:

**macOS / Linux**

```bash
env | grep -i proxy
printf 'NO_PROXY=%s\n' "$NO_PROXY"
# Replace TARGET_DOMAIN with the actual service domain, for example api.openai.com.
curl -I https://TARGET_DOMAIN --connect-timeout 10
```

**Windows PowerShell**

```powershell
Get-ChildItem Env:*proxy*
netsh winhttp show proxy
# Replace TARGET_DOMAIN with the actual service domain, for example api.openai.com.
curl.exe -I https://TARGET_DOMAIN --connect-timeout 10
```

Fix rules:

- If terminal has no proxy but browser does, configure terminal/IDE/Codex to use the same legitimate proxy or organization-approved route.
- If terminal has proxy but localhost login fails, ensure `NO_PROXY` includes loopback hosts.
- If the target service is region-specific, test the actual target domain instead of assuming every issue is related to OpenAI or GitHub.
- Use temporary environment variables first. Do not permanently modify shell profiles until the fix is confirmed.

Recommended temporary variables:

**macOS / Linux**

```bash
export HTTPS_PROXY=http://127.0.0.1:7890
export HTTP_PROXY=http://127.0.0.1:7890
export ALL_PROXY=socks5://127.0.0.1:7890
export NO_PROXY=localhost,127.0.0.1,::1
```

**Windows PowerShell**

```powershell
$env:HTTPS_PROXY="http://127.0.0.1:7890"
$env:HTTP_PROXY="http://127.0.0.1:7890"
$env:ALL_PROXY="socks5://127.0.0.1:7890"
$env:NO_PROXY="localhost,127.0.0.1,::1"
```

Replace `7890` with the user's actual local proxy port. Do not assume the port.

### Step C — DNS, TLS, time, certificate, and IPv6 checks

Symptoms:

- `ENOTFOUND`, `ECONNRESET`, `ETIMEDOUT`, `CERT_*`, `SSL`, `TLS`, `certificate verify failed`.
- Works on mobile hotspot but fails on campus/company/public Wi-Fi.
- Works in one country/region but not another.
- A China-hosted service fails overseas, or an overseas service fails from China or another restricted route.

Check:

```bash
# Replace TARGET_DOMAIN with the real target domain.
nslookup TARGET_DOMAIN
curl -Iv https://TARGET_DOMAIN --connect-timeout 10
```

Windows:

```powershell
nslookup TARGET_DOMAIN
curl.exe -Iv https://TARGET_DOMAIN --connect-timeout 10
```

For Codex/OpenAI-specific cases, `TARGET_DOMAIN` may be `api.openai.com`, `chatgpt.com`, or the official domain shown by the client. For China-hosted or company services, use the actual target domain provided by the user.

Fix rules:

- Verify system time and timezone first.
- If company/campus TLS inspection is used, explain that the user may need organization-approved certificates or network admin support.
- If IPv6 is unstable, test IPv4 explicitly where supported; do not permanently disable IPv6 unless the user understands the tradeoff.
- If DNS answers differ by region, compare browser, terminal, and network path before changing DNS globally.

### Step D — Browser and OAuth state checks

Symptoms:

- Wrong browser opens.
- Browser login succeeds but app is not authorized.
- Callback opens in a browser profile that does not match the app session.
- User can access the target service in one browser profile but not in another.

Actions:

- Try default browser first.
- Try copying the login URL into a browser profile where the user is actually logged in.
- Disable extensions that intercept redirects only for testing.
- Clear only the relevant client/auth cache using official or documented instructions.
- Separate OpenAI authentication failure from GitHub repository permission failure.
- Separate local callback problems from target-domain reachability problems.

---

## 4. Response Patterns / 回答模板 / 返答テンプレート

### Chinese starter

```text
这个问题不要先重装。先判断它是本地回调端口问题，还是目标服务的跨地区网络可达性问题。你这个现象如果是“浏览器显示登录成功但 Codex 仍未登录”，优先查本地端口和 NO_PROXY；如果是“某个地区能访问、另一个地区不能访问”，优先查目标域名、DNS、TLS 和代理路径。
```

### English starter

```text
Do not reinstall first. First separate a localhost callback problem from a cross-region reachability problem. If the browser says login succeeded but Codex remains unauthenticated, check the local callback port and NO_PROXY. If one region can reach the service and another cannot, check the target domain, DNS, TLS, and proxy route.
```

### Japanese starter

```text
最初に再インストールする必要はありません。まず localhost コールバック問題なのか、地域間アクセスの到達性問題なのかを分けます。ブラウザ上ではログイン成功なのに Codex 側が未ログインなら、ローカルポートと NO_PROXY を確認します。ある地域ではアクセスできて別の地域では失敗する場合は、対象ドメイン、DNS、TLS、プロキシ経路を確認します。
```

---

## 5. Safe Remediation Checklist / 安全修复清单 / 安全な修正チェックリスト

Before changing anything persistent:

- Record current proxy settings.
- Identify the actual target domain and target region.
- Use temporary shell variables first.
- Keep `NO_PROXY=localhost,127.0.0.1,::1` when local callbacks are involved.
- Avoid logging full URLs with OAuth code/state/token.
- Prefer official settings UI or documented config over hidden flags.
- Restart the app after changing proxy/port settings.
- Test browser, terminal, and app separately.
- Test the same target domain from the same network path before drawing region-level conclusions.

After fixing:

- Remove temporary debug variables if not needed.
- Do not leave tokens in terminal history or issue comments.
- Summarize what changed: port, proxy mode, NO_PROXY, DNS, certificate, browser profile, or target-domain route.

---

## 6. Common Error Mapping / 常见错误对应 / よくあるエラー対応

| Error / Symptom | Most likely cause | First check |
|---|---|---|
| Browser says login succeeded, app still unauthenticated | Local callback port mismatch | `lsof` / `netstat` on callback port |
| `ECONNREFUSED 127.0.0.1:PORT` | Nothing listening on callback port | Restart client; check port |
| `EADDRINUSE` | Port occupied | Find and stop occupying process |
| Browser works, terminal times out | Browser-only proxy or route mismatch | `env | grep -i proxy` / PowerShell env |
| Login page opens but callback hangs | Proxy/TUN captures loopback | Add `NO_PROXY` loopback entries |
| `CERTIFICATE_VERIFY_FAILED` | TLS interception or CA problem | Check system certs / organization CA |
| `ENOTFOUND` | DNS failure or region-specific DNS answer | `nslookup TARGET_DOMAIN` |
| Works on hotspot but not campus/company network | Network policy/proxy/TLS inspection | Ask network admin or use approved route |
| Works in one country/region but not another | Cross-region routing, DNS, CDN, firewall, or service availability issue | Test actual target domain from browser and terminal |
| GitHub repo unavailable | GitHub App or repo permission | Check GitHub authorization separately |
| China-hosted service fails overseas | Target-domain DNS/CDN/region policy/routing issue | Test target domain, TLS, and browser/terminal route |
| Overseas service fails from China or another restricted route | DNS/TLS/proxy/routing mismatch or service availability issue | Test target domain and legitimate proxy/route configuration |

---

## 7. What Not To Do / 不要做什么 / やってはいけないこと

- Do not tell the user to paste tokens, cookies, OAuth codes, or full sensitive URLs.
- Do not recommend random third-party Codex packages, login helpers, cracked clients, or credential-forwarding tools.
- Do not assume every connectivity issue is China-specific.
- Do not assume every cross-region issue requires a VPN. Diagnose browser/terminal/proxy/loopback/DNS/TLS first.
- Do not permanently disable firewall, SIP, Gatekeeper, antivirus, IPv6, or certificate verification as a first fix.
- Do not edit shell startup files until a temporary fix has worked.
- Do not confuse OpenAI login failure with GitHub repository permission failure.
- Do not confuse local OAuth callback failure with target-domain reachability failure.

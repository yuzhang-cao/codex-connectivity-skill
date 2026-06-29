---
name: codex-connectivity-troubleshooter
description: Troubleshoot Codex and developer-tool startup, login, browser callback, localhost port, proxy, DNS, TLS, firewall, and cross-region or restricted-network issues. Use when Codex, an AI CLI, IDE extension, desktop app, browser login, OAuth callback, local development service, API endpoint, or region-specific developer service cannot start, cannot authenticate, times out, opens the wrong local port, or fails behind a proxy/VPN/TUN/campus/company network. When a CLI task fails because browser access works but terminal access fails, discover safe local proxy candidates from system proxy settings, environment variables, and localhost listening ports, then retry the same task with temporary proxy environment variables and loopback NO_PROXY. Applies to users in any region, including mainland China users accessing overseas services and overseas users accessing China-hosted services. Respond in Chinese, English, or Japanese according to the user's language.
---

# Codex Connectivity Troubleshooter Skill

## 0. Core Intent / 核心目标 / 目的

This Skill is for Codex and other AI CLI or developer tools when a task fails because of regional routing, proxy, VPN, TUN, DNS, TLS, firewall, local callback, or browser-vs-terminal network mismatch.

The intended automation pattern is:

1. Detect that the browser can reach the service but the CLI/app cannot.
2. Discover safe proxy candidates from system-visible sources.
3. Select the most likely local proxy endpoint, usually `127.0.0.1:<port>` or `localhost:<port>`.
4. Set temporary `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`, and `NO_PROXY` values.
5. Retry the exact failed task or command once through that proxy path.
6. If it still fails, continue diagnosis instead of repeatedly retrying.

中文：本 Skill 的核心不是简单告诉用户“改代理”，而是在 Codex 或其他 AI CLI 失败时，自动检查浏览器/系统代理端口，临时设置代理环境变量，然后用同一条失败任务重新执行一次。

日本語：この Skill の目的は、Codex や AI CLI が地域・プロキシ・VPN・TUN・DNS/TLS 問題で失敗した場合、システムから見えるプロキシ候補を検出し、一時的なプロキシ環境変数を設定して同じタスクを一度再実行することである。

---

## 1. Scope / 范围 / 範囲

This Skill is not limited to one country or one access direction. It covers:

- Mainland China users accessing overseas developer services.
- Overseas users accessing China-hosted developer services.
- Users on campus, company, hotel, public Wi-Fi, proxy, VPN, TUN, split-tunnel, or firewall-restricted networks.
- Users whose browser, terminal, IDE, and desktop app do not share the same network path.
- AI CLI tools that fail while the same target works in a browser.

本 Skill 不只面向中国用户，也不只处理“中国访问海外服务”的问题。它同样适用于海外用户访问中国服务、不同地区之间访问失败、浏览器能访问但终端/IDE/Codex 不能访问等情况。

対象は特定の国に限定しない。中国本土から海外サービスへアクセスする場合、海外から中国向けサービスへアクセスする場合、大学・企業・ホテル・公共 Wi-Fi・プロキシ・VPN・TUN・split tunnel 環境で発生する問題も対象とする。

Use this Skill when the user reports:

- Codex or an AI CLI cannot log in or start.
- Browser login succeeds, but the CLI/app still says unauthenticated.
- The callback URL opens on `localhost`, `127.0.0.1`, or `::1`, but the app never receives it.
- Browser access works but terminal, IDE, or Codex access times out.
- A service works in one region/network but not another.
- A China-hosted service fails overseas, or an overseas service fails from China or another restricted route.
- Proxy/VPN works in the browser but not in terminal, IDE, or Codex.
- DNS/TLS errors appear: `ENOTFOUND`, `ETIMEDOUT`, `ECONNRESET`, `CERT_*`, `certificate verify failed`.

---

## 2. Safety and Permission Rules / 安全与权限规则 / 安全ルール

### 2.1 Do not extract secrets

Never ask for or extract:

- OpenAI session tokens, refresh tokens, API keys.
- GitHub tokens, OAuth codes, cookies.
- Proxy usernames/passwords.
- VPN credentials or private VPN configuration files.
- Company internal tokens or private service credentials.
- Full callback URLs containing `code=`, `state=`, `token=`, or `session=`.

Redact values as:

```text
<REDACTED_TOKEN>
<REDACTED_CODE>
<REDACTED_COOKIE>
<REDACTED_INTERNAL_DOMAIN_IF_NEEDED>
```

### 2.2 Do not read VPN internals

Do **not** claim that the assistant can directly read a VPN app's private configuration. Use only legitimate, system-visible signals:

- Environment variables: `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`, `NO_PROXY`.
- OS proxy settings.
- WinHTTP proxy settings on Windows.
- Localhost listening ports.
- Browser-visible proxy settings when the user provides them.
- Official app settings or documented CLI flags.

中文：不要写成“读取 VPN 内部配置”。正确说法是“从系统代理、环境变量、本机监听端口、浏览器代理设置中发现代理端口”。

日本語：VPN アプリ内部の秘密設定を読むとは言わない。取得対象は OS から見えるプロキシ設定、環境変数、localhost の待受ポート、ユーザーが提示したブラウザ設定に限定する。

### 2.3 Policy boundary

Do not provide instructions for bypassing law, employer policy, campus policy, or platform terms. Keep guidance to legitimate diagnostics, proxy consistency, loopback routing, DNS/TLS analysis, official client settings, and organization-approved access methods.

---

## 3. Required First Diagnosis / 必要诊断 / 必須診断

When information is missing, ask only for the minimum needed:

```text
1. OS: macOS / Windows / Linux, version:
2. Client: Codex desktop / Codex CLI / AI CLI / VS Code extension / browser / other:
3. Target service/domain: OpenAI/Codex / GitHub / China-hosted service / overseas API / company endpoint / other:
4. User region and network type: home / campus / company / public Wi-Fi / proxy / VPN / TUN / split tunnel:
5. Error stage: start / browser login / callback / request timeout / DNS / TLS / GitHub auth / other:
6. Exact error text or screenshot:
7. Callback URL or port, with code/token redacted:
8. Does the target domain open in the browser: yes/no:
9. Does terminal traffic use the same proxy or route as the browser: yes/no/unknown:
10. The failed command or task to retry, with secrets redacted:
```

If the user already gave enough information, do not ask again. Proceed with a best-effort fix.

---

## 4. Auto Proxy Discovery and Retry / 自动代理发现与重试 / 自動プロキシ検出と再実行

This is the key behavior for Codex and AI CLI tasks.

### 4.1 Trigger condition

Use this flow when:

- Browser access succeeds but CLI/IDE/Codex fails.
- User has a VPN/proxy/TUN app enabled.
- The error is timeout, network unreachable, DNS/TLS failure, or authentication callback failure caused by routing.
- The user wants the agent to continue the same failed task through the working browser proxy path.

### 4.2 Discovery order

Discover proxy candidates in this order:

1. Existing environment variables:
   - `HTTPS_PROXY`, `HTTP_PROXY`, `ALL_PROXY`
   - lowercase variants
   - `NO_PROXY`
2. OS/system proxy settings:
   - macOS: `scutil --proxy`
   - Windows: `netsh winhttp show proxy`, PowerShell environment variables, Windows proxy settings when visible
   - Linux: desktop proxy variables, environment variables, and common shell profile exports only when visible
3. Localhost listening ports that are commonly used by legitimate local proxy clients.
4. User-provided browser proxy setting or VPN local proxy port.

Common local proxy ports may include:

```text
7890, 7891, 7897, 1080, 10808, 10809, 20170, 2080, 8080, 8888, 9090
```

Do not assume these are correct. Treat them as candidates and test reachability.

### 4.3 Candidate test

For each candidate, test a harmless HEAD request to the actual target domain:

```bash
curl -I --proxy http://127.0.0.1:PORT https://TARGET_DOMAIN --connect-timeout 10
```

If SOCKS is likely:

```bash
curl -I --proxy socks5h://127.0.0.1:PORT https://TARGET_DOMAIN --connect-timeout 10
```

Windows:

```powershell
curl.exe -I --proxy http://127.0.0.1:PORT https://TARGET_DOMAIN --connect-timeout 10
curl.exe -I --proxy socks5h://127.0.0.1:PORT https://TARGET_DOMAIN --connect-timeout 10
```

### 4.4 Temporary retry environment

When a working proxy candidate is found, retry the failed command with temporary variables only.

macOS / Linux:

```bash
HTTPS_PROXY=http://127.0.0.1:PORT \
HTTP_PROXY=http://127.0.0.1:PORT \
ALL_PROXY=socks5://127.0.0.1:PORT \
NO_PROXY=localhost,127.0.0.1,::1 \
<FAILED_COMMAND>
```

Windows PowerShell:

```powershell
$env:HTTPS_PROXY="http://127.0.0.1:PORT"
$env:HTTP_PROXY="http://127.0.0.1:PORT"
$env:ALL_PROXY="socks5://127.0.0.1:PORT"
$env:NO_PROXY="localhost,127.0.0.1,::1"
<FAILED_COMMAND>
```

If the tool only supports HTTP proxy, use `HTTP_PROXY` and `HTTPS_PROXY`. If it explicitly supports SOCKS, use `ALL_PROXY` or the tool's documented SOCKS option.

### 4.5 Retry limit

Retry the same task once with the best proxy candidate. If it fails:

- Show the error difference.
- Do not loop repeatedly.
- Continue with DNS/TLS/callback/firewall diagnostics.
- Ask for the minimal missing information only if necessary.

中文：发现代理端口后，不要永久写入 shell 配置。先用临时变量重新执行刚刚失败的任务。成功后再建议用户是否写入长期配置。

日本語：プロキシ候補が見つかっても、最初から永続設定に書き込まない。一時的な環境変数で直前に失敗したタスクを一度だけ再実行する。

---

## 5. Local Callback and Port Flow / 本地回调端口 / ローカルコールバック

Symptoms:

- Browser login succeeds, but Codex/CLI/IDE still says not logged in.
- Error mentions `localhost`, `127.0.0.1`, `::1`, callback, redirect URI, or a port.
- The browser opens `http://127.0.0.1:PORT/...`, but the app never receives it.
- User recently changed port/proxy and login broke.

macOS / Linux:

```bash
lsof -nP -iTCP:PORT -sTCP:LISTEN
curl -v http://127.0.0.1:PORT/ 2>&1 | head -40
```

Windows PowerShell:

```powershell
netstat -ano | findstr :PORT
Get-Process -Id <PID>
```

Fix rules:

- If the port is occupied, close that process or change the client callback port through official settings.
- If `localhost` resolves to IPv6 and fails, test `127.0.0.1` if supported.
- If proxy/VPN/TUN captures localhost traffic, add loopback bypass: `localhost,127.0.0.1,::1`.
- Do not invent undocumented flags. Use official settings, `--help`, or documented config.

---

## 6. DNS, TLS, Region, and Target Domain Flow / DNS、TLS 与地区访问 / DNS・TLS・地域アクセス

Always test the actual target domain, not only OpenAI/GitHub.

macOS / Linux:

```bash
nslookup TARGET_DOMAIN
curl -Iv https://TARGET_DOMAIN --connect-timeout 10
```

Windows:

```powershell
nslookup TARGET_DOMAIN
curl.exe -Iv https://TARGET_DOMAIN --connect-timeout 10
```

If using a proxy candidate:

```bash
curl -Iv --proxy http://127.0.0.1:PORT https://TARGET_DOMAIN --connect-timeout 10
```

Fix rules:

- Verify system time and timezone first.
- If campus/company TLS inspection is used, the user may need organization-approved certificates or network admin support.
- If IPv6 is unstable, test IPv4 explicitly where supported; do not permanently disable IPv6 as a first fix.
- If DNS differs by region, compare browser, terminal, and proxy route before changing DNS globally.

---

## 7. Response Patterns / 回答模板 / 返答テンプレート

### Chinese starter

```text
你的想法可以按这个顺序处理：先确认浏览器是否能访问目标服务，再从系统代理、环境变量和本机监听端口里找代理候选端口；找到可用端口后，用临时 HTTP_PROXY/HTTPS_PROXY/ALL_PROXY/NO_PROXY 重新执行刚刚失败的 Codex/AI CLI 任务。注意不是读取 VPN 内部账号或密码，而是读取系统可见的代理设置。
```

### English starter

```text
The right flow is: confirm that the browser can reach the target service, discover proxy candidates from system-visible proxy settings, environment variables, and localhost listening ports, then retry the failed Codex/AI CLI task once with temporary HTTP_PROXY/HTTPS_PROXY/ALL_PROXY/NO_PROXY. Do not read VPN credentials or private VPN configuration.
```

### Japanese starter

```text
正しい流れは、まずブラウザで対象サービスに到達できるか確認し、OS から見えるプロキシ設定・環境変数・localhost の待受ポートから候補を検出し、一時的な HTTP_PROXY/HTTPS_PROXY/ALL_PROXY/NO_PROXY を設定して失敗した Codex/AI CLI タスクを一度再実行することです。VPN の認証情報や内部設定は読み取りません。
```

---

## 8. Common Error Mapping / 常见错误对应 / よくあるエラー対応

| Error / Symptom | Most likely cause | First check |
|---|---|---|
| Browser works, CLI fails | Browser proxy not shared with terminal | Auto-discover proxy candidates and retry with temp env |
| Browser says login succeeded, app still unauthenticated | Local callback port mismatch | `lsof` / `netstat` on callback port |
| `ECONNREFUSED 127.0.0.1:PORT` | Nothing listening on callback port | Restart client; check port |
| `EADDRINUSE` | Port occupied | Find and stop occupying process |
| Login callback hangs | Proxy/TUN captures loopback | Add `NO_PROXY=localhost,127.0.0.1,::1` |
| `CERTIFICATE_VERIFY_FAILED` | TLS interception or CA problem | Check system certs / organization CA |
| `ENOTFOUND` | DNS failure or region-specific DNS answer | `nslookup TARGET_DOMAIN` |
| Works in one region but not another | Routing, DNS, CDN, firewall, or service availability | Test actual target domain with and without proxy |
| China-hosted service fails overseas | Target-domain DNS/CDN/region policy/routing issue | Test target domain, TLS, browser route, terminal route |
| Overseas service fails from China or another restricted route | DNS/TLS/proxy/routing mismatch | Test target domain and legitimate proxy route |

---

## 9. What Not To Do / 不要做什么 / やってはいけないこと

- Do not ask users to paste tokens, cookies, OAuth codes, or full sensitive URLs.
- Do not read or request VPN credentials or private VPN configuration files.
- Do not recommend cracked clients, credential-forwarding tools, or random login helpers.
- Do not assume every issue is China-specific.
- Do not assume every cross-region issue requires a VPN.
- Do not permanently edit shell startup files before a temporary retry succeeds.
- Do not permanently disable firewall, antivirus, certificate verification, Gatekeeper, SIP, or IPv6 as a first fix.
- Do not confuse local OAuth callback failure with target-domain reachability failure.

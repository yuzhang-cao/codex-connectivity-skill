---
name: codex-connectivity-troubleshooter
description: Troubleshoot Codex and developer-tool startup, login, browser callback, localhost port, proxy, DNS, TLS, and firewall issues commonly seen by users in mainland China or restricted networks. Use when Codex, an IDE extension, CLI, desktop app, browser login, OAuth callback, or local development service cannot start, cannot authenticate, times out, opens the wrong local port, or fails behind a proxy/VPN/campus/company network. Respond in Chinese, English, or Japanese according to the user's language.
---

# Codex Connectivity Troubleshooter Skill

## 0. Scope / 范围 / 範囲

This skill helps diagnose and fix startup, login, OAuth callback, local port, proxy, DNS, TLS, firewall, and restricted-network problems affecting Codex or adjacent developer tools.

本 Skill 用于排查 Codex 或相关开发工具在中国大陆、校园网、公司网、代理/VPN/TUN 环境下出现的启动、登录、OAuth 回调、本地端口、代理、DNS、TLS、系统防火墙等问题。

この Skill は、中国本土・大学ネットワーク・社内ネットワーク・プロキシ/VPN/TUN 環境で発生しやすい Codex または開発ツールの起動、ログイン、OAuth コールバック、localhost ポート、プロキシ、DNS、TLS、ファイアウォール問題を診断するために使う。

Use this skill when the user reports problems such as:

- Codex cannot log in, browser login opens but does not return to the app.
- Login fails because the callback port is wrong, blocked, occupied, or routed through a proxy.
- CLI/desktop/IDE extension starts but cannot connect to the service.
- Requests time out only on Chinese mainland/campus/company networks.
- Proxy/VPN works in browser but not in terminal, IDE, or Codex.
- `localhost`, `127.0.0.1`, or `::1` behaves inconsistently.
- OpenAI/GitHub authentication fails, token refresh fails, or TLS/DNS errors appear.

---

## 1. Operating Rules / 操作规则 / 運用ルール

### 1.1 First response rule

When this skill is triggered, do **not** immediately reinstall everything. Start with a short diagnosis plan:

1. Identify the client: Codex web, Codex desktop, CLI, VS Code/JetBrains/Xcode extension, browser, or another app.
2. Identify the failure point: app launch, browser login, OAuth callback, local port, proxy, DNS, TLS, GitHub auth, OpenAI auth, firewall, or system keychain.
3. Ask for only the minimum missing data if needed: OS, exact error text, callback URL/port, proxy mode, and whether browser access works.
4. Give commands for the user's OS.
5. Redact secrets before asking for logs.

中文：不要一开始就让用户重装。先判断是“客户端类型”和“失败位置”。只要必要信息，不要让用户贴 token、cookie、完整 refresh token。

日本語：最初から再インストールを案内しない。まずクライアント種別と失敗箇所を切り分ける。ログを求める場合は必ずシークレットを伏せる。

### 1.2 Security rule

Never ask the user to paste secrets. Treat these as sensitive:

- OpenAI session tokens, refresh tokens, API keys
- GitHub tokens, OAuth codes, cookies
- Proxy usernames/passwords
- Full browser callback URLs when they contain `code=`, `state=`, `token=`, or `session=`

Ask the user to replace values with:

```text
<REDACTED_TOKEN>
<REDACTED_CODE>
<REDACTED_COOKIE>
```

### 1.3 Legality and policy rule

Do not provide instructions for bypassing local law, employer policy, campus policy, or platform terms. Keep guidance limited to legitimate network configuration, proxy consistency, local loopback routing, diagnostics, and official client settings.

中文：只处理合法合规的网络配置、代理一致性、本地回调端口、DNS/TLS/防火墙诊断。不要指导规避法律、组织政策或平台规则。

日本語：法律、組織ポリシー、プラットフォーム規約の回避を目的とした手順は提供しない。正当なネットワーク設定と診断に限定する。

---

## 2. Required Diagnosis Template / 必要诊断模板 / 必須診断テンプレート

When the user gives insufficient information, request this compact template:

```text
1. OS: macOS / Windows / Linux, version:
2. Client: Codex desktop / Codex CLI / VS Code extension / browser / other:
3. Error stage: start / browser login / callback / request timeout / GitHub auth / other:
4. Exact error text or screenshot:
5. Callback URL or port, with code/token redacted:
6. Proxy/VPN mode: none / system proxy / TUN / browser-only / company/campus network:
7. Does chatgpt.com or platform.openai.com open in the browser: yes/no:
8. Does terminal traffic use the same proxy as the browser: yes/no/unknown:
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

- If the port is occupied by another process, close that process or change Codex/client callback port through official settings.
- If the callback URL uses `localhost` but IPv6 breaks, try `127.0.0.1` if the client supports it.
- If the proxy/VPN captures localhost traffic, add loopback exclusions: `localhost`, `127.0.0.1`, `::1`.
- Do not invent undocumented flags. Check `--help`, official settings, or existing config before changing hidden options.

中文重点：登录失败但浏览器显示成功，通常优先查“本地回调端口”和“localhost 被代理/TUN 接管”。

日本語要点：ブラウザ上では成功しているのにアプリ側が未ログインの場合、まずローカルコールバックポートと loopback のプロキシ除外を確認する。

### Step B — Determine whether terminal/IDE traffic uses a different proxy from the browser

Symptoms:

- Browser can open the site, but CLI/IDE/Codex fails.
- `curl` times out while browser works.
- Proxy is browser-only, not system-wide.

Check:

**macOS / Linux**

```bash
env | grep -i proxy
printf 'NO_PROXY=%s\n' "$NO_PROXY"
curl -I https://api.openai.com --connect-timeout 10
```

**Windows PowerShell**

```powershell
Get-ChildItem Env:*proxy*
netsh winhttp show proxy
curl.exe -I https://api.openai.com --connect-timeout 10
```

Fix rules:

- If terminal has no proxy but browser does, configure terminal/IDE/Codex to use the same legitimate proxy.
- If terminal has proxy but localhost login fails, ensure `NO_PROXY` includes loopback hosts.
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
- Works on mobile hotspot but fails on campus/company network.

Check:

```bash
nslookup api.openai.com
curl -Iv https://api.openai.com --connect-timeout 10
```

Windows:

```powershell
nslookup api.openai.com
curl.exe -Iv https://api.openai.com --connect-timeout 10
```

Fix rules:

- Verify system time and timezone first.
- If company/campus TLS inspection is used, explain that the user may need organization-approved certificates or network admin support.
- If IPv6 is unstable, test IPv4 explicitly where supported; do not permanently disable IPv6 unless the user understands the tradeoff.

### Step D — Browser and OAuth state checks

Symptoms:

- Wrong browser opens.
- Browser login succeeds but app is not authorized.
- Callback opens in a browser profile that does not match the app session.

Actions:

- Try default browser first.
- Try copying the login URL into a browser profile where the user is actually logged in.
- Disable extensions that intercept redirects only for testing.
- Clear only the relevant Codex/OpenAI/GitHub auth cache using official or documented instructions.
- Separate OpenAI authentication failure from GitHub repository permission failure.

---

## 4. Response Patterns / 回答模板 / 返答テンプレート

### Chinese starter

```text
这个问题不要先重装。你这个现象更像是 OAuth 登录后的本地回调端口没有被 Codex 正确监听，或者 localhost 被代理/TUN 接管了。先查端口，再查 NO_PROXY。
```

### English starter

```text
Do not reinstall first. This looks more like an OAuth localhost callback problem: Codex is not listening on the callback port, another process owns the port, or loopback traffic is being captured by the proxy/TUN mode.
```

### Japanese starter

```text
最初に再インストールする必要はありません。この症状は OAuth 後の localhost コールバック問題に近いです。Codex がそのポートを listen していない、別プロセスが使っている、または proxy/TUN が loopback を捕まえている可能性があります。
```

---

## 5. Safe Remediation Checklist / 安全修复清单 / 安全な修正チェックリスト

Before changing anything persistent:

- Record current proxy settings.
- Use temporary shell variables first.
- Keep `NO_PROXY=localhost,127.0.0.1,::1` when local callbacks are involved.
- Avoid logging full URLs with OAuth code/state/token.
- Prefer official settings UI or documented config over hidden flags.
- Restart the app after changing proxy/port settings.
- Test browser, terminal, and app separately.

After fixing:

- Remove temporary debug variables if not needed.
- Do not leave tokens in terminal history or issue comments.
- Summarize what changed: port, proxy mode, NO_PROXY, DNS, certificate, or browser profile.

---

## 6. Common Error Mapping / 常见错误对应 / よくあるエラー対応

| Error / Symptom | Most likely cause | First check |
|---|---|---|
| Browser says login succeeded, app still unauthenticated | Local callback port mismatch | `lsof` / `netstat` on callback port |
| `ECONNREFUSED 127.0.0.1:PORT` | Nothing listening on callback port | Restart client; check port |
| `EADDRINUSE` | Port occupied | Find and stop occupying process |
| Browser works, terminal times out | Browser-only proxy | `env | grep -i proxy` / PowerShell env |
| Login page opens but callback hangs | Proxy/TUN captures loopback | Add `NO_PROXY` loopback entries |
| `CERTIFICATE_VERIFY_FAILED` | TLS interception or CA problem | Check system certs / organization CA |
| `ENOTFOUND` | DNS failure | `nslookup api.openai.com` |
| Works on hotspot but not campus/company network | Network policy/proxy/TLS inspection | Ask network admin or use approved proxy |
| GitHub repo unavailable | GitHub App or repo permission | Check GitHub authorization separately |

---

## 7. What Not To Do / 不要做什么 / やってはいけないこと

- Do not tell the user to paste tokens, cookies, OAuth codes, or full sensitive URLs.
- Do not recommend random third-party Codex packages, login helpers, cracked clients, or credential-forwarding tools.
- Do not assume every China-region issue requires a VPN. Diagnose browser/terminal/proxy/loopback first.
- Do not permanently disable firewall, SIP, Gatekeeper, antivirus, IPv6, or certificate verification as a first fix.
- Do not edit shell startup files until a temporary fix has worked.
- Do not confuse OpenAI login failure with GitHub repository permission failure.

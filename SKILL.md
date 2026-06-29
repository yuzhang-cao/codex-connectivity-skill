---
name: codex-proxy-assist
description: Help Codex, AI CLI tools, IDE extensions, and related developer tools continue login or web-access tasks when a target website, web app, API, or software page needs a proxy path. Use when direct CLI access fails but browser/VPN/proxy access may work. Discover safe local proxy candidates from system-visible proxy settings, environment variables, and localhost listening ports, then retry the same failed CLI task once with temporary HTTP_PROXY, HTTPS_PROXY, ALL_PROXY, and NO_PROXY settings. This Skill is an access-assist and retry Skill, not primarily a troubleshooting manual. Applies to users in any region, including mainland China users accessing overseas services and overseas users accessing China-hosted services. Respond in Chinese, English, or Japanese according to the user's language.
---

# Codex Proxy Assist Skill

## 0. Core Purpose / 核心目的 / 目的

This Skill helps Codex, AI CLI tools, IDE extensions, and related developer tools continue login or web-access tasks when the target website, web app, API, or software page requires a proxy path.

Its main purpose is **not** to diagnose for diagnosis's sake. Its main purpose is to help the CLI find a usable local proxy endpoint and retry the same failed task through that endpoint.

核心目的不是“排查故障”，而是：当 Codex 或其他 AI CLI 需要登录网页、网站、Web 应用、API 或软件页面，但 CLI 直接访问失败时，自动查找本机 VPN/代理软件暴露出来的网页代理端口，然后通过这个端口继续执行刚刚失败的登录或访问任务。

主目的は単なる診断ではない。Codex や AI CLI がログインページ、Web サイト、Web アプリ、API、またはソフトウェア画面へ直接アクセスできない場合に、ローカル VPN/プロキシソフトが公開している Web プロキシポートを見つけ、そのポート経由で失敗したログインまたはアクセス操作を続行することである。

The intended automation pattern is:

1. Codex / AI CLI tries to open or log in to a target website, web app, API, or software page.
2. Direct CLI access fails.
3. The Skill checks whether browser/VPN/proxy access may already work.
4. The Skill discovers safe proxy candidates from system-visible sources.
5. The Skill selects the most likely local proxy endpoint, usually `127.0.0.1:<port>` or `localhost:<port>`.
6. The Skill sets temporary `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`, and `NO_PROXY` values.
7. The Skill retries the exact failed CLI task once through that proxy path.
8. If it still fails, the Skill falls back to DNS, TLS, callback-port, and network-route analysis.

---

## 1. Scope / 范围 / 範囲

This Skill is useful when a CLI or developer tool must access a website, web login page, web app, API, or software page and that access path differs from the user's browser path.

It covers:

- Codex login or web access that fails in CLI but works in browser.
- AI CLI tools that need to open or authenticate against a website.
- IDE extensions that fail because terminal/extension traffic does not use the browser proxy.
- Mainland China users accessing overseas developer services.
- Overseas users accessing China-hosted services.
- Users on campus, company, hotel, public Wi-Fi, proxy, VPN, TUN, split-tunnel, or firewall-restricted networks.
- Users whose browser, terminal, IDE, and desktop app do not share the same proxy path.

本 Skill 适用于 CLI 或开发工具需要访问网页、网页登录页、Web 应用、API 或软件页面，但 CLI 访问路径与浏览器访问路径不一致的情况。

対象は、CLI または開発ツールが Web サイト、ログインページ、Web アプリ、API、またはソフトウェア画面へアクセスする必要があり、その経路がブラウザの経路と異なる場合である。

Use this Skill when the user reports:

- “Codex 登录网页时打不开，但浏览器走 VPN 可以打开。”
- “AI CLI needs to log in to a web page, but only the browser proxy works.”
- “CLI 访问某个网站失败，能不能自动找本机代理端口重试？”
- Browser login succeeds, but the CLI/app still says unauthenticated.
- A callback URL opens on `localhost`, `127.0.0.1`, or `::1`, but the app never receives it.
- A service works in one region/network but not another.
- Proxy/VPN works in browser but not in terminal, IDE, or Codex.

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

Do **not** claim that the Skill can directly read a VPN app's private configuration. Use only legitimate, system-visible signals:

- Environment variables: `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`, `NO_PROXY`.
- OS proxy settings.
- WinHTTP proxy settings on Windows.
- Localhost listening ports.
- Browser-visible proxy settings when the user provides them.
- Official app settings or documented CLI flags.

中文：不要写成“读取 VPN 内部配置”。正确说法是“从系统代理、环境变量、本机监听端口、浏览器代理设置中发现代理端口”。

日本語：VPN アプリ内部の秘密設定を読むとは言わない。取得対象は OS から見えるプロキシ設定、環境変数、localhost の待受ポート、ユーザーが提示したブラウザ設定に限定する。

### 2.3 Policy boundary

Do not provide instructions for bypassing law, employer policy, campus policy, or platform terms. Keep guidance to legitimate local proxy reuse, proxy consistency, loopback routing, DNS/TLS analysis, official client settings, and organization-approved access methods.

---

## 3. Required Minimal Context / 必要最小信息 / 最小限の情報

When information is missing, ask only for the minimum needed:

```text
1. OS: macOS / Windows / Linux, version:
2. Client: Codex desktop / Codex CLI / AI CLI / VS Code extension / browser / other:
3. Target website/domain: login page / web app / API / company endpoint / other:
4. Does the target open in the browser or VPN browser path: yes/no:
5. Error stage: start / browser login / callback / direct CLI access / DNS / TLS / other:
6. Exact error text or screenshot:
7. Callback URL or port, with code/token redacted:
8. The failed CLI command or task to retry, with secrets redacted:
```

If the user already gave enough information, do not ask again. Proceed with a best-effort proxy-assist flow.

---

## 4. Proxy Discovery and Task Retry / 代理发现与任务重试 / プロキシ検出とタスク再実行

This is the key behavior.

### 4.1 Trigger condition

Use this flow when:

- Browser access succeeds but CLI/IDE/Codex access fails.
- User has a VPN/proxy/TUN app enabled.
- The target website, web app, API, or software page appears to need a proxy path.
- The user wants the CLI to continue the same failed login or access task.

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
3. Localhost listening ports commonly used by legitimate local proxy clients.
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
- Fall back to DNS/TLS/callback/firewall checks.
- Ask for the minimal missing information only if necessary.

中文：发现代理端口后，不要永久写入 shell 配置。先用临时变量重新执行刚刚失败的登录或访问任务。成功后再建议用户是否写入长期配置。

日本語：プロキシ候補が見つかっても、最初から永続設定に書き込まない。一時的な環境変数で直前に失敗したログインまたはアクセス操作を一度だけ再実行する。

---

## 5. Local Callback Support / 本地回调支持 / ローカルコールバック補助

For OAuth login flows, also keep local callback traffic outside the proxy path.

Symptoms:

- Browser login succeeds, but Codex/CLI/IDE still says not logged in.
- The browser opens `http://127.0.0.1:PORT/...`, but the app never receives it.
- Proxy/VPN/TUN captures localhost traffic.

Fix rules:

- Keep `NO_PROXY=localhost,127.0.0.1,::1`.
- Check whether the callback port is occupied.
- If `localhost` resolves to IPv6 and fails, test `127.0.0.1` if supported.
- Use official settings, `--help`, or documented config for callback-port changes.

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

---

## 6. Fallback Checks / 失败后的兜底检查 / 失敗時の補助確認

If proxy-assisted retry fails, then check DNS, TLS, system time, certificate interception, IPv6, firewall, and target-domain routing.

macOS / Linux:

```bash
nslookup TARGET_DOMAIN
curl -Iv https://TARGET_DOMAIN --connect-timeout 10
curl -Iv --proxy http://127.0.0.1:PORT https://TARGET_DOMAIN --connect-timeout 10
```

Windows:

```powershell
nslookup TARGET_DOMAIN
curl.exe -Iv https://TARGET_DOMAIN --connect-timeout 10
curl.exe -Iv --proxy http://127.0.0.1:PORT https://TARGET_DOMAIN --connect-timeout 10
```

---

## 7. Response Patterns / 回答模板 / 返答テンプレート

### Chinese starter

```text
这个 Skill 的目标不是单纯排查，而是辅助 CLI 继续访问：如果 Codex/AI CLI 登录网页或访问网站失败，但浏览器通过本机 VPN/代理可以打开，就先从系统代理、环境变量和本机监听端口里找代理候选端口；找到可用端口后，用临时 HTTP_PROXY/HTTPS_PROXY/ALL_PROXY/NO_PROXY 重新执行刚刚失败的任务一次。
```

### English starter

```text
This Skill is not primarily a troubleshooting manual. It is a proxy-assist workflow: if Codex or an AI CLI cannot open or log in to a target site, but the browser works through a local VPN/proxy, discover system-visible proxy candidates and retry the same CLI task once with temporary proxy environment variables.
```

### Japanese starter

```text
この Skill は単なる診断用ではありません。Codex または AI CLI が対象サイトを開けない、またはログインできない場合に、ブラウザで使えているローカル VPN/プロキシの候補ポートを検出し、一時的なプロキシ環境変数で同じ CLI タスクを一度再実行するための補助 Skill です。
```

---

## 8. What Not To Do / 不要做什么 / やってはいけないこと

- Do not ask users to paste tokens, cookies, OAuth codes, or full sensitive URLs.
- Do not read or request VPN credentials or private VPN configuration files.
- Do not recommend cracked clients, credential-forwarding tools, or random login helpers.
- Do not permanently edit shell startup files before a temporary retry succeeds.
- Do not permanently disable firewall, antivirus, certificate verification, Gatekeeper, SIP, or IPv6 as a first fix.
- Do not repeatedly retry the same task in a loop.
- Do not confuse local OAuth callback failure with target-domain reachability failure.

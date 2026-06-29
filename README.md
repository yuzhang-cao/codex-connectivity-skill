# Codex Proxy Assist Skill

A trilingual auxiliary Skill for Codex, AI CLI tools, IDE extensions, and related developer tools. Its purpose is not mainly to troubleshoot failures. Its purpose is to help a CLI continue login or web-access tasks when the target website, web app, API, or software page requires a proxy path that is already available through the user's local VPN/proxy software.

面向 Codex、AI CLI、IDE 插件及相关开发工具的三语辅助 Skill。它的主要目的不是“排查故障”，而是当 CLI 需要登录某些网页、网站、Web 应用、API 或软件页面时，如果直接访问不上，就自动从系统可见的代理设置、环境变量和本机监听端口中寻找本机 VPN/代理软件提供的网页代理端口，然后通过这个代理端口继续执行刚刚失败的登录或访问任务。

Codex、AI CLI、IDE 拡張、関連開発ツール向けの三言語補助 Skill です。主目的は単なる診断ではありません。CLI がログインページ、Web サイト、Web アプリ、API、またはソフトウェア画面へ直接アクセスできない場合に、OS から見えるプロキシ設定、環境変数、localhost の待受ポートからローカル VPN/プロキシソフトの Web プロキシポートを見つけ、そのポート経由で失敗したログインまたはアクセス操作を続行するための Skill です。

## Core behavior

```text
1. Codex / AI CLI tries to open or log in to a target website, web app, API, or software page.
2. Direct CLI access fails.
3. The Skill checks whether a browser or local VPN/proxy path may already work.
4. The Skill discovers system-visible local proxy candidates:
   - HTTP_PROXY / HTTPS_PROXY / ALL_PROXY / NO_PROXY
   - OS proxy settings
   - WinHTTP proxy on Windows
   - localhost listening ports commonly used by local proxy software
   - user-provided browser proxy port
5. The Skill tests candidate ports against the target domain.
6. If a candidate works, the Skill retries the same failed CLI task once with temporary proxy variables.
7. If the retry still fails, it falls back to DNS, TLS, callback-port, and network-route analysis.
```

## What this Skill is not

- It is not primarily a troubleshooting manual.
- It does not read VPN credentials, VPN private configuration files, cookies, OAuth codes, or API keys.
- It does not permanently modify shell startup files unless the user explicitly asks.
- It does not provide instructions to violate laws, campus rules, company policy, or platform terms.

## Files

```text
codex-connectivity-skill/
├── SKILL.md
├── README.md
├── LICENSE
├── references/
│   └── diagnostic-checklist.md
└── scripts/
    ├── diagnose_codex_connectivity.sh
    └── diagnose_codex_connectivity.ps1
```

## Usage examples

Use it when a user says something like:

- “Codex 登录网页时打不开，但浏览器走 VPN 可以打开。”
- “AI CLI needs to log in to a web page, but only the browser proxy works.”
- “CLI 访问某个网站失败，能不能自动找本机代理端口重试？”
- “美国网络访问中国网站失败，但浏览器代理可以打开。”
- “中国から海外 API に接続できません。ブラウザでは開けます。”
- “CLI のログイン画面だけプロキシを通らず失敗します。”

## Suggested repository description

```text
A trilingual Proxy Assist Skill for Codex and AI CLI tools: discover system-visible local proxy ports and retry failed login or web-access tasks through temporary proxy settings.
```

## Safety

This Skill only uses system-visible proxy information and localhost listening ports. It does not access VPN internals or sensitive credentials. It uses temporary proxy variables first and keeps `NO_PROXY=localhost,127.0.0.1,::1` for local callback safety.

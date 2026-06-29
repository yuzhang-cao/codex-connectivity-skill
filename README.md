# Codex Connectivity Troubleshooter Skill

A trilingual Skill for troubleshooting Codex startup, login, OAuth callback, local port, proxy, DNS, TLS, firewall, and restricted-network issues commonly seen by users in mainland China, campus networks, company networks, or proxy/VPN/TUN environments.

面向中国 Codex 用户的三语 Skill，用于排查启动失败、登录回调失败、本地端口错误、代理不一致、DNS/TLS、系统防火墙、校园网/公司网限制等问题。

中国本土・大学ネットワーク・社内ネットワーク・プロキシ/VPN/TUN 環境で起きやすい Codex の起動、ログイン、OAuth コールバック、localhost ポート、DNS/TLS、ファイアウォール問題を診断する三言語 Skill です。

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

## Usage

Copy the whole directory into your Skills directory or repository, depending on your Codex/agent environment.

Use it when a user says something like:

- “Codex 登录失败，浏览器显示成功但是应用没有登录。”
- “Codex login failed after changing ports.”
- “CLI works in browser but not in terminal behind a proxy.”
- “ログイン後、localhost のコールバックで止まります。”

## Manual GitHub publishing

```bash
cd /path/to/codex-connectivity-skill
git init
git branch -M main
git add .
git commit -m "Add Codex connectivity troubleshooting skill"
git remote add origin https://github.com/<your-user>/codex-connectivity-skill.git
git push -u origin main
```

Suggested repository name:

```text
codex-connectivity-skill
```

Suggested description:

```text
Trilingual Skill for troubleshooting Codex startup, login, localhost callback port, proxy, DNS, TLS, and restricted-network issues for China-region users.
```

## Safety

This Skill does not ask users to paste tokens, cookies, OAuth codes, API keys, or full sensitive callback URLs. It focuses on legitimate diagnostics and configuration: local ports, loopback bypass, proxy consistency, DNS, TLS, browser profiles, and GitHub/OpenAI auth separation.

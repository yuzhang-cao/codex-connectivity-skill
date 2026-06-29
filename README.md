# Codex Connectivity Troubleshooter Skill

A trilingual Skill for troubleshooting Codex and developer-tool startup, login, OAuth callback, local port, proxy, DNS, TLS, firewall, and cross-region or restricted-network issues. It is designed for users in any region, including mainland China users accessing overseas services, overseas users accessing China-hosted services, and users on campus, company, proxy, VPN, or TUN networks.

面向跨地区网络环境的三语 Skill，用于排查 Codex 及相关开发工具的启动失败、登录回调失败、本地端口错误、代理不一致、DNS/TLS、系统防火墙、校园网/公司网限制等问题。适用对象不只限于中国用户，也包括海外用户访问中国服务、中国用户访问海外服务，以及任何受限网络、代理、VPN、TUN 环境下的用户。

地域を限定しない三言語 Skill です。Codex および関連開発ツールの起動失敗、ログイン・OAuth コールバック、localhost ポート、プロキシ不整合、DNS/TLS、ファイアウォール、大学・企業ネットワーク、VPN/TUN 環境の問題を診断します。中国本土から海外サービスへアクセスする場合だけでなく、海外から中国向けサービスへアクセスする場合にも利用できます。

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
- “I am in the US, but a China-hosted developer service times out.”
- “中国から海外 API に接続できません。”
- “海外から中国向けサービスにアクセスすると DNS/TLS で失敗します。”
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
Trilingual Skill for troubleshooting Codex startup, login, localhost callback port, proxy, DNS, TLS, firewall, and cross-region or restricted-network issues.
```

## Safety

This Skill does not ask users to paste tokens, cookies, OAuth codes, API keys, or full sensitive callback URLs. It focuses on legitimate diagnostics and configuration: local ports, loopback bypass, proxy consistency, DNS, TLS, browser profiles, target-domain reachability, and GitHub/OpenAI auth separation.

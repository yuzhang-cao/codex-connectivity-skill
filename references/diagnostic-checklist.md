# Diagnostic Checklist / 诊断清单 / 診断チェックリスト

## Chinese / 中文

### 一、先判断失败位置

1. 应用是否能启动？
2. 浏览器是否能打开登录页面？
3. 浏览器是否显示登录成功？
4. Codex/CLI/IDE 是否仍显示未登录？
5. 回调 URL 是否包含 `localhost`、`127.0.0.1`、`::1` 或端口号？
6. 终端和浏览器是否使用同一个代理？
7. 当前网络是家庭网、校园网、公司网，还是代理/VPN/TUN？

### 二、优先检查端口

macOS / Linux:

```bash
lsof -nP -iTCP:PORT -sTCP:LISTEN
```

Windows:

```powershell
netstat -ano | findstr :PORT
```

### 三、优先检查代理

macOS / Linux:

```bash
env | grep -i proxy
```

Windows:

```powershell
Get-ChildItem Env:*proxy*
netsh winhttp show proxy
```

必须确认：

```text
NO_PROXY=localhost,127.0.0.1,::1
```

### 四、不要让用户贴这些内容

- API Key
- OAuth code
- Refresh token
- Cookie
- 带 `code=`、`state=`、`token=` 的完整 URL

---

## English

### 1. Locate the failure stage

1. Does the app start?
2. Does the browser open the login page?
3. Does the browser report successful login?
4. Does Codex/CLI/IDE still show unauthenticated?
5. Does the callback URL contain `localhost`, `127.0.0.1`, `::1`, or a port?
6. Do terminal and browser use the same proxy?
7. Is the network home, campus, company, proxy, VPN, or TUN?

### 2. Check the local port first

macOS / Linux:

```bash
lsof -nP -iTCP:PORT -sTCP:LISTEN
```

Windows:

```powershell
netstat -ano | findstr :PORT
```

### 3. Check proxy consistency

macOS / Linux:

```bash
env | grep -i proxy
```

Windows:

```powershell
Get-ChildItem Env:*proxy*
netsh winhttp show proxy
```

Confirm:

```text
NO_PROXY=localhost,127.0.0.1,::1
```

### 4. Do not ask for

- API keys
- OAuth codes
- Refresh tokens
- Cookies
- Full URLs containing `code=`, `state=`, or `token=`

---

## Japanese / 日本語

### 1. 失敗箇所を確認する

1. アプリは起動するか。
2. ブラウザでログインページは開くか。
3. ブラウザ上ではログイン成功と表示されるか。
4. Codex/CLI/IDE 側では未ログインのままか。
5. コールバック URL に `localhost`、`127.0.0.1`、`::1`、ポート番号が含まれるか。
6. ターミナルとブラウザは同じプロキシを使っているか。
7. ネットワークは家庭、大学、会社、プロキシ、VPN、TUN のどれか。

### 2. まずローカルポートを確認する

macOS / Linux:

```bash
lsof -nP -iTCP:PORT -sTCP:LISTEN
```

Windows:

```powershell
netstat -ano | findstr :PORT
```

### 3. プロキシ設定を確認する

macOS / Linux:

```bash
env | grep -i proxy
```

Windows:

```powershell
Get-ChildItem Env:*proxy*
netsh winhttp show proxy
```

必ず確認する値：

```text
NO_PROXY=localhost,127.0.0.1,::1
```

### 4. ユーザーに貼らせてはいけない情報

- API キー
- OAuth code
- Refresh token
- Cookie
- `code=`、`state=`、`token=` を含む完全な URL

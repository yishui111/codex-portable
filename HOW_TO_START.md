# 如何启动 Codex（下次照着做就行）

> 路径: E:\codex-portable
> 本文档教你从头启动整套 Codex 平台：聊天界面 + 本地模型 + Codex 命令行。

---

## 第 0 步：确认环境

先确认这些已安装并运行：

| 依赖 | 说明 | 检查方式 |
|------|------|----------|
| Docker Desktop | 运行本地模型与聊天界面 | 双击打开，等它显示 "Engine running" |
| Node.js v18+ | 运行 codex-bridge 和 Codex CLI | 一般是装好的 |

> Docker Desktop 一定要先启动并处于运行状态，否则后面会报错。

---

## 第 1 步：启动全部服务

在「cmd」或「PowerShell」中执行：

```
cd /d E:\codex-portable
start.bat
```

启动成功后会自动打印 3 个地址：

| 服务 | 地址 |
|------|------|
| 聊天界面（Open WebUI） | http://localhost:3002 |
| 协议代理（codex-bridge） | http://localhost:4000 |
| 本地模型（Ollama） | http://localhost:11434 |

---

## 第 2 步：启动 Codex 命令行（和你现在聊天的一样）

用项目自带的快捷脚本启动即可，它会自动设置好环境变量，不需要手动 set。

### 方式 A：用 .bat（cmd 里用）

```
cd /d E:\codex-portable
codex.bat            :: 默认用 DeepSeek 在线
codex.bat ollama     :: 改用本地模型
```

### 方式 B：用 .ps1（PowerShell 里用）

```
cd E:\codex-portable
.\codex.ps1            :: 默认用 DeepSeek 在线
.\codex.ps1 ollama     :: 改用本地模型
```

打开后就是和我（Codex）对话的界面，输入你的需求即可。

---

## 只启动一部分服务（可选）

`start.bat` 支持按需只启动某个服务：

```
start.bat deepseek   :: 只启动在线 API 代理 (bridge, 端口4000)
start.bat ollama     :: 只启动本地模型 (Ollama, 端口11434)
start.bat webui      :: 只启动聊天界面 (端口3002)
```

> 注：如果只想用 Codex 命令行聊天，其实只需要 `bridge`（在线）或 `Ollama`（本地），不一定要开聊天界面。

---

## 浏览器里聊天（可选，Open WebUI）

如果你不想要命令行，也可以用网页聊：

1. 打开 http://localhost:3002
2. 左上角选模型（左侧模型列表）
3. 用 DeepSeek 在线：先到「管理设置 → 外部连接」添加
   - API 地址: `http://host.docker.internal:4000/v1`
   - API 密钥: `sk-proxy-local-codex-portable-key-2026`

---

## 停止 / 查看状态

| 操作 | 命令 |
|------|------|
| 停止所有服务 | `stop.bat` |
| 查看服务状态 | `status.bat` |

---

## 常见问题

- **报 `Docker 未运行`** → 检查 Docker Desktop 是否启动并处于 "Engine running"。
- **模型想离线用** → 用 `codex.ps1 ollama`（本地模型，数据不外传）。
- **想用在线 DeepSeek** → 确认 bridge 活着（`status.bat`），然后用 `codex.ps1`（默认）。

---

## 最简启动版（复制粘贴 2 行）

```
cd /d E:\codex-portable
start.bat && codex.ps1
```

> 详细架构和配置见根目录 `README.md`。

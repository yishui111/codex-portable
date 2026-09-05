# 启动 Codex 说明文档

本文档说明如何在本机启动 Codex 及配套服务。

## 一、启动全部服务

```batch
start.bat
```

该命令会启动 Ollama（本地模型）、codex-bridge（协议转换代理）和 Open WebUI（聊天界面）。

## 二、按需启动单个服务

```batch
# 仅启动 DeepSeek 在线模式
start.bat deepseek

# 仅启动 Ollama 本地模型
start.bat ollama

# 仅启动聊天界面
start.bat webui
```

## 三、启动 Codex 命令行

```batch
# 设置环境变量（每次打开新终端需要执行）
set CODEX_HOME=E:\codex-portable\config

# 使用 DeepSeek 在线 API
codex --profile deepseek

# 或使用本地模型
codex --profile ollama
```

## 四、常用管理命令

| 操作 | 命令 |
|------|------|
| 启动全部 | `start.bat` |
| 启动聊天界面 | `start.bat webui` |
| 启动桥接代理 | `start.bat deepseek` |
| 启动本地模型 | `start.bat ollama` |
| 停止服务 | `stop.bat` |
| 查看状态 | `status.bat` |

---

> 更多详细信息请参见项目根目录的 `README.md`。

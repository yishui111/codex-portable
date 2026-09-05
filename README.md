# Codex 便携平台（codex-portable）

> 一套"随身携带"的 AI 编程 + 聊天环境：Codex CLI + DeepSeek 线上 API + Ollama 本地模型 + Open WebUI 聊天界面。
> 整个文件夹复制到另一台电脑就能用，线上/本地模型自由切换。

## 一、这是干什么的

| 组件 | 作用 | 地址/端口 |
|------|------|-----------|
| Codex CLI | 终端里的 AI 编程助手，对话改代码 | 命令行使用 |
| codex-bridge | 协议转换代理（Responses → Chat Completions），让 Codex 接 DeepSeek | http://localhost:4000 |
| Ollama | 本地大模型平台（默认 qwen2.5:7b），离线可用、数据不外传 | http://localhost:11434 |
| Open WebUI | 浏览器聊天界面，支持多模型对话 | http://localhost:3002 |

两种用法：
- **终端编程**：`codex --profile deepseek`（线上）或 `codex --profile ollama`（本地）
- **网页聊天**：浏览器打开 http://localhost:3002，左上角选模型

## 二、安装位置

本机当前路径：`E:\codex-portable`（2026-08-14 从"数字人"项目文件夹里独立出来）
> 想换电脑：整个文件夹复制过去，先跑 `import.bat` 再跑 `setup.bat`（详见 `部署方案.md`）。

## 三、快速开始

前置条件（每台电脑只需装一次）：
1. Node.js v18+（https://nodejs.org）
2. Docker Desktop（https://www.docker.com），并启动到 "Engine running"

首次使用：
1. 双击 `import.bat` — 检查环境、导入 Docker 镜像、设置 CODEX_HOME 环境变量
2. 双击 `setup.bat` — 安装 Codex CLI
3. 双击 `启动.bat` — 一键启动全部服务
4. 打开 http://localhost:3002 或运行 `codex.bat` 开始用

日常使用：

| 操作 | 脚本 |
|------|------|
| 启动全部服务 | `启动.bat`（或 `start.bat`） |
| 停止全部服务 | `关闭.bat`（或 `stop.bat`） |
| 查看服务状态 | `状态.bat`（或 `status.bat`） |
| 启动 Codex CLI | `codex.bat`（默认 DeepSeek 线上）/ `codex.bat ollama`（本地） |

按需只起一部分（英文脚本支持参数）：
- `start.bat deepseek` — 只起线上代理（bridge）
- `start.bat ollama` — 只起本地模型
- `start.bat webui` — 只起聊天界面

## 四、模型切换

| 模型 | 来源 | 特点 | 命令 |
|------|------|------|------|
| deepseek-chat | DeepSeek 线上 API | V3，综合能力强，需联网 | `codex.bat` |
| deepseek-reasoner | DeepSeek 线上 API | R1 深度推理 | 配置里可选 |
| qwen2.5:7b | Ollama 本地 | 轻量，离线可用，数据不出本机 | `codex.bat ollama` |

## 五、配置文件

| 文件 | 说明 |
|------|------|
| `config\config.toml` | Codex 主配置（模型供应商、profile 定义） |
| `config\auth.json` | API 认证（敏感，勿外传） |
| `codex-bridge\.env` | 代理密钥，DeepSeek API Key 填 `DEEPSEEK_API_KEY=` |
| `docker-compose.yml` | Ollama / Open WebUI 容器编排，数据存在 `projects\` 下 |

## 六、目录结构

```
codex-portable/
├── 启动.bat / 关闭.bat / 状态.bat   # 中文一键脚本
├── start.bat / stop.bat / status.bat # 英文脚本（支持按需启动参数）
├── codex.bat / codex.ps1            # Codex CLI 快捷启动
├── import.bat / setup.bat           # 新机导入 / 环境初始化
├── docker-compose.yml               # 容器编排
├── ollama-image.tar                 # 离线 Ollama 镜像（约 3GB）
├── open-webui-image.tar             # 离线 Open WebUI 镜像（约 1.8GB）
├── codex-bridge/                    # 协议转换代理（含 .env 密钥配置）
├── config/                          # Codex 配置与会话数据（CODEX_HOME）
├── projects/
│   ├── ollama/data/                 # 本地模型数据
│   └── open-webui/data/             # 聊天界面数据库和上传
├── ziliao/                          # 素材/输入文件
├── tests/                           # 测试脚本（冒烟测试）
├── 部署方案.md                       # 部署/复原方案
├── 项目日志.md                       # 项目运行日志
└── README.md                        # 本说明
```

## 七、常见问题

| 问题 | 解决 |
|------|------|
| `codex` 命令找不到 | 运行 `setup.bat` 安装，或重新打开终端 |
| 提示 Docker 未运行 | 先启动 Docker Desktop，等 "Engine running" |
| Ollama 起不来 | 检查 GPU 驱动 / Docker 是否真的在运行 |
| 端口 3002/4000/11434 被占用 | 关掉占用程序，或 `关闭.bat` 后重试 |
| 聊天界面连不上 DeepSeek | 管理设置 → 外部连接，API 地址 `http://host.docker.internal:4000/v1`，密钥 `sk-proxy-local-codex-portable-key-2026` |
| 复制到别的电脑启动报错 | 按 `部署方案.md` 从头走一遍 import → setup → 启动 |

## 八、相关文档

- `部署方案.md` — 从零部署/换机复原全流程
- `HOW_TO_START.md` / `STARTUP.md` — 启动速查
- `MIGRATION.md` — 跨机器迁移指南
- `项目日志.md` — 每次改动记录
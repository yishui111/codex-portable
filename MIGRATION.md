# Codex 便携平台 - 迁移到新电脑指南

本指南说明如何把整个 `codex-portable` 文件夹完整迁移到另一台电脑，并快速配置好运行环境。

## 一、整体结论

- 这个平台是**便携版设计**，配置里没有硬编码本机绝对路径，数据全部存放在本文件夹内。
- 只需要**整包复制**整个文件夹，到新电脑后运行环境检查/导入脚本，即可正常启动。
- 但目标电脑必须预先安装好 **Node.js** 和 **Docker Desktop**（外部依赖无法随文件夹一起带走）。

## 二、需要复制什么

把 `codex-portable` 整个文件夹完整复制到目标电脑（U 盘或移动硬盘拷贝均可）。建议连同以下数据一起复制：

- `projects\ollama\data`：本地模型（Ollama）数据
- `projects\open-webui\data`：Open WebUI 数据
- `config\`：Codex CLI 配置与会话记录
- `ollama-image.tar`、`open-webui-image.tar`：离线 Docker 镜像（可选，见下）

> 提示：如果目标电脑联网畅通，两个 `.tar` 大文件可以不带，启动时会让 Docker 从网络自动拉取镜像。

## 三、目标电脑需要预装的环境

| 依赖 | 用途 | 安装方式 |
|------|------|------|
| Node.js v18+ | 运行 codex-bridge 和 Codex CLI | https://nodejs.org |
| Docker Desktop | 运行本地 Ollama 和 Open WebUI | https://www.docker.com |
| DeepSeek API Key | 调用在线模型 | https://platform.deepseek.com |

## 四、新机导入步骤

### 步骤 1：检查/安装环境
- 安装 Node.js v18+，然后安装 Docker Desktop 并**启动它**（Docker 守护进程必须处于运行状态）。
- 重新打开一个终端（或命令行窗口），确保新命令生效。

### 步骤 2：运行导入脚本

进入复制后的 `codex-portable` 目录，双击或命令行运行：

```bat
import.bat
```

脚本会自动完成：
- 检查 Node.js / npm / Docker 是否就绪
- 对比并导入两个 `.tar` 镜像（若已存在则跳过）
- 写入 `CODEX_HOME` 指向本文件夹 `config` 的用户环境变量
- 检查 `codex-bridge\.env` 里是否配好了 DeepSeek API Key

只做环境检查（不导入镜像、不写环境变量）可用：

```bat
import.bat check
```

### 步骤 3：首次使用前（需联网）

运行 `setup.bat` 安装 Codex CLI 并完成初始化（脚本会检测是否已安装）。

### 步骤 4：一键启动

```bat
start.bat
```

启动后可访问：
- 聊天界面：http://localhost:3001
- 代理服务：http://localhost:4000
- 本地模型：http://localhost:11434

## 五、需要在新电脑单独配置的内容

- **DeepSeek API Key**：打开 `codex-bridge\.env`，填入 `DEEPSEEK_API_KEY=` 对应的密钥。
- **Open WebUI 管理后台底座连接**（手动添加一次）：
  - API 地址：`http://host.docker.internal:4000/v1`
  - API 密钥：`sk-proxy-local-codex-portable-key-2026`
- **Codex CLI 登录/授权**：如果你用的是需要 `requires_openai_auth` 的配置，首次运行 `codex` 时按提示完成授权。

## 六、切换到别的电脑（给别人用）时的注意事项

如果这台新电脑是**别人**的机器，而不是你本人继续使用，建议：
- 删除 `config\auth.json`、`config\.sandbox-secrets\` 等本地凭据文件，避免泄露。
- 自己重新配置 `codex-bridge\.env` 中的 API Key（当前文件里含真实密钥，不要随文件夹外传）。
- 若无需离线模型，可以删除两个 `.tar` 大文件以节省空间和拷贝时间。

## 七、常见问题（FAQ）

- **提示 codex 不是内部或外部命令？** 说明 Codex CLI 未安装或环境变量未刷新，运行 `setup.bat` 后**关闭并重新打开终端**。
- **镜像导入失败？** 确保 Docker Desktop 已启动，再重新运行 `import.bat`。
- **开了 Docker 但 Ollama 起不来？** 检查 Docker Desktop 是否真的处于运行状态（`docker info` 能返回正常信息）。
- **端口被占用？** 确认没有其他程序占用 3001 / 4000 / 11434 端口。
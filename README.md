# Shell 提示符输入法控制

Bash/Zsh 提示符钩子报告 OSC 777，执行 read/exec/前台程序前解除限制。匹配的 Code 用户运行副本只限制获焦的 xterm textarea。

ime / ime status / ime english / ime system；默认英文，嵌套 Shell 独立开关；不切全局 IBus，不修改 PS1/DEBUG trap。

## 安装

这是独立 Git 仓库，可单独上传 GitHub。构建仅依赖 Bash、Python 3 标准库；逻辑模块使用 Node 18+。安装位置为实际运行 VS Code 窗口的 UI 端，当前部署目标为 Windows Code 1.145.2 + WSL Ubuntu 26.04。

```sh
bash package.sh
code --install-extension dist/local.shell-ime-0.1.0.vsix --force
```

Windows 上建议用 Windows Code CLI 安装。WSL 的 `code` 默认可能转交远程端，不要据此误判 UI 扩展安装位置。本终端桥声明 workspace 优先，以便向 WSL 远程新终端提供环境标记；纯 UI 场景可回退本地。

`config/settings.json` 和 `config/keybindings.json` 是本功能配置片段，必须按键/映射合并，不能整份覆盖已有配置。完整键位与保留 JSONC 注释的合并、备份、回滚工具见同级独立仓库 `vscode-custom-keybindings`。安装后由用户在合适时机 Reload Window；本脚本不会重启编辑器。

## 测试

```sh
python3 test/hooks.py
```

联合回归：`cd ../vscode-custom-keybindings && bash test/run-integration.sh`。测试创建独立 Xvnc、用户配置、扩展目录和工作区；不使用登录态，不向日常桌面发送按键。Linux Code 测试运行副本与 VSCodeVim 1.32.4 的位置可通过 `EDITOR_TOOLS_TEST_CODE` / `EDITOR_TOOLS_TEST_VIM` 指定。

2026-11-16 的联合结果：SV、Visual、分屏搜索、颜色标记次数/固定坐标、marker 一次撤销、Enter、快速分屏、Leader 共存、局部编辑区/终端限制均通过 Linux Code 1.145.2 集成检查。**这不等于 Windows 拼音和真实 Codex 提交已验收。** 原始结果在联合仓库的 `test-results/`，该目录不加入 Git。

## 停用与卸载

```sh
code --uninstall-extension local.shell-ime
```

在统一键位仓库执行受保护回滚，或仅删本仓库 config 中对应的键/映射。若安装后用户继续编辑了配置，回滚器拒绝覆盖后续修改，应根据备份合并恢复。

## 兼容范围和限制

当前目标 Windows Code + WSL，GNOME/VTE 动态库后端未实现、未部署。tmux/screen 不启用，tcsh 仅提供冲突检测的可选脚本且未实测。原生 Windows Terminal 不受此 Code 补丁控制。

备份、测试日志、运行副本、VSIX、编译产物不纳入 Git。没有复制浏览器/Codex 凭据。源码按 MIT 许可提供。

## Shell 接入

```sh
bash build.sh
# Bash
source /实际路径/shell-ime/shell/bash.sh
# Zsh
source /实际路径/shell-ime/shell/zsh.sh
```

初始化文件只追加带存在性检查的 source。新终端生效；本机当前 Codex 终端在 tmux 内，按设计不启用。状态文件含 PID 启动时间、700/600 权限并拒绝符号链接。Code 需 editor-ime-mode 构建的运行副本，单装 VSIX 不会限制 IME。

卸载：删除 Shell source 块、卸载 VSIX、从系统 Code 入口重开；现有 Shell 不会被自动中断。

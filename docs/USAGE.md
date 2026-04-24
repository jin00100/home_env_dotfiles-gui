# 🚀 全能开发环境使用指南 (Hyprland + 终端)

欢迎！您的开发环境现已升级为包含 **Hyprland 图形桌面**和**深度定制终端工作流**的“完全体”。本指南将帮助您快速上手。

## 1. 🖥️ 首次进入桌面

1. 在您的 Ubuntu 登录界面，点击右下角的齿轮图标。
2. 从列表中选择 **"Hyprland"** 会话。
3. 输入密码登录，您将进入一个全新的、由动画和透明效果构成的现代化桌面。

## 2. 🪟 Hyprland 桌面核心操作

您的键盘 `Win` / `Super` 键是所有桌面操作的核心。

| 快捷键 | 功能 |
| :--- | :--- |
| **`Super + Enter`** | 打开 **Ghostty** 终端 |
| **`Super + Space`** | 打开 **Noctalia** 程序启动器 |
| **`Super + Q`** | 关闭当前聚焦的窗口 |
| **`Super + F`** | 切换窗口全屏 |
| **`Super + h/j/k/l`** | 在不同窗口间移动焦点 |
| **`Super + Shift + h/j/k/l`**| 移动当前窗口的位置 |
| **`Super + Escape`** | **锁屏** (Hyprlock) |
| **`Super + Shift + E`** | **注销** (退出 Hyprland) |
| **Print Screen** | 全屏截图 (自动保存到 `~/Pictures`) |
| **`Super + Shift + S`** | 区域截图并使用 **Swappy** 编辑 |
| **`Super + Shift + C`** | 区域截图并直接复制到剪贴板 |

**提示**: 您可以在 `nix/modules/hyprland.nix` 文件中修改所有这些快捷键。

## 3. ⚙️ 配置生效与更新 (Nix 核心操作)

这一部分和以前完全一样。当您修改了 `~/home_env_dotfiles` 目录下的任何 `.nix` 配置文件后，**必须**在终端中运行以下命令让配置生效：

*   **`hms`** : 应用所有最新配置。
*   **`nix-clean`** : 清理 Nix 缓存，释放磁盘空间。
*   **`./update.sh`** : 将所有通过 Nix 安装的软件（包括桌面组件）更新到最新版本。

## 4. 🪟 终端工作流 (Zellij + Neovim)

您所熟悉的终端工作流**完美保留**，现在它运行在 Hyprland 的窗口之内。

*   **Zellij (终端复用器)**: 当您按下 `Super + Enter` 打开终端时，Zellij 会**自动启动**，并加载您自定义的 `cyber-blue` 主题。
*   **Neovim (编辑器)**: 所有快捷键、插件、主题 (TokyoNight) 和神级功能 (OSC 52 剪贴板) 都保持不变。
*   **核心快捷键**: `Ctrl + g` 依然是您在 Zellij 和 Neovim 之间切换的“灵魂”快捷键。

## 5. 🛠️ 现代化 CLI 工具

所有您喜欢的工具 (`zoxide`, `eza`, `bat`, `btop`, `jq`, `yq`) 都在。此外，我们还新增了两个：
*   **`yazi`** (别名: `y`): 一个极速的终端文件管理器。在终端输入 `y` 即可启动。
*   **`atuin`**: 魔法般的 Shell 历史记录工具，它已在后台自动记录您的所有命令。

## 6. 🧑‍🏫 如何添加新软件或自定义配置？

流程不变，声明式管理一切！
1. **加软件**: 编辑 `nix/modules/packages.nix`。
2. **加命令/变量**: 编辑 `nix/modules/zsh.nix`。
3. **改桌面快捷键**: 编辑 `nix/modules/hyprland.nix`。
4. 修改后，在终端运行 **`hms`** 使其生效。

---
**💡 提示**：如果您想调整显示器的分辨率或排列顺序，请在终端运行 `hyprctl monitors` 查看显示器名称，然后创建并编辑 `~/.config/hypr/monitors.conf` 文件。

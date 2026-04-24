# 🚀 Dotfiles (Nix Home Manager + Hyprland)

**jin**'s declarative development environment, blending a powerful **terminal-centric workflow** with a sleek **Hyprland GUI desktop**, all managed by Nix Home Manager.

This setup supports both **Native Linux** and **WSL** with a single, unified configuration, ensuring a consistent and high-performance experience.

## ✨ Features

### 🖥️ GUI Desktop Environment
- **🪟 Window Manager:** **Hyprland** (Wayland-native) with hardware-accelerated animations and blur effects.
- **🚀 App Launcher & Bar:** **Noctalia Shell** provides a unified app launcher, status bar, and notification center.
- **🔒 Security:** **Hyprlock** & **Hypridle** for automated screen locking and power management.
- **🎨 Global Theme:** A consistent and pleasant **Ayu-Dark** and **TokyoNight** aesthetic across GTK, icons, and terminal applications.
- **📸 Screenshots:** Fullscreen and regional screenshot capabilities via **Grim**, **Slurp**, and **Swappy**.

### ⚡ Terminal & Shell
- **🐚 Shells:** **Zsh** (main, with custom Gemini welcome), **Bash**, and **Nushell**, all optimized with **Starship (Jetpack Theme)** and auto-detection for SSH sessions.
- **🛠️ Modern Core Utils:** Replaces legacy tools with modern Rust alternatives like `eza`, `zoxide`, `bat`, `fd`, `ripgrep`, `btop`, `yazi`, and `atuin`.
- **💻 Terminal Multiplexer:** **Zellij** (Modern Rust-based) pre-configured with a custom `cyber-blue` theme and auto-start.
- **📝 Editor (Neovim):** Your custom **DevOps Enhanced** Neovim setup remains intact, with its TokyoNight theme, OSC 52 clipboard, advanced LSP, and snippets.
- **🤖 AI:** Auto-installation of `@google/gemini-cli`.

## 📂 Directory Structure

Your directory structure has been expanded to include all the new modules:
```text
~/home_env_dotfiles
├── flake.nix
└── nix
    ├── home.nix
    └── modules
        ├── (Your core modules: neovim, zellij, zsh, etc.)
        └── (New GUI modules: hyprland, noctalia, theme, etc.)
```

## 🚀 Installation

Your `install.sh` script is now an all-in-one setup tool that will automatically:
1. **(Ubuntu/Debian Only)** Install system-level dependencies like `git`, `curl`, and the `hyprland` engines via `apt`.
2. Install Nix Package Manager and enable Flakes if not already present.
3. Apply all your terminal and GUI configurations using Home Manager.
4. Set up `fnm` and `zsh` as the default shell.

Just run the script in a clean Ubuntu Desktop environment:
```bash
chmod +x install.sh
./install.sh
```

## ⌨️ Keybindings Cheat Sheet

### Hyprland Desktop
| Shortcut | Action |
| :--- | :--- |
| **`Super + Enter`** | Launch **Ghostty** terminal |
| **`Super + Space`** | Launch **Noctalia** (App Launcher) |
| **`Super + Q`** | Close active window |
| **`Super + F`** | Toggle Fullscreen |
| **`Super + h/j/k/l`** | Move focus between windows |
| **`Super + Shift + h/j/k/l`**| Move active window |
| **Super + Escape** | Lock Screen (**Hyprlock**) |
| **Print Screen** | Capture Whole Screen |
| **Super + Shift + S** | Capture Area & Edit (**Swappy**) |

### Terminal (Zellij + Neovim)
Your existing terminal cheat sheet remains the same!
| Command / Shortcut | Action |
| :--- | :--- |
| `hms` | Apply Nix configuration changes |
| `Ctrl + g` | Zellij Prefix (Lock/Unlock for Neovim) |
| `Alt + h/j/k/l` | Navigate between Zellij panes |
| `Space + f` (in Neovim) | Find files (Telescope) |

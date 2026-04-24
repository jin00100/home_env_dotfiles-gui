1# 🚀 Dotfiles (Nix Home Manager)

**jin**'s declarative development environment configuration managed by **Nix Home Manager**.
This setup supports both **Native Linux** and **WSL** with a single, unified configuration, ensuring a consistent and high-performance workflow.

## ✨ Features

- **⚡ Shell:** Zsh optimized with **Starship (Jetpack Theme)**. Auto-detects SSH sessions and displays a special Starship prompt (Starship-SSH).
- **🛠️ Modern Core Utils & DevOps:** Replaces legacy tools with modern Rust alternatives and essential DevOps data processors.
  - `ls` -> `eza` (Icons & Git status)
  - `cd` -> `zoxide` (Smarter navigation, overwrites default `cd`)
  - `cat` -> `bat` (Syntax highlighting)
  - `find` -> `fd` / `grep` -> `ripgrep`
  - `top` -> `btop` (Modern system monitor)
  - `jq` / `yq` (JSON and YAML processors)
  - `direnv` -> **`direnv` (Nix-direnv integrated)**
- **💻 Terminal Multiplexer:** **Zellij** (Modern Rust-based) pre-configured.
  - Auto-start on launch (except VS Code).
  - Prefix: `Ctrl + g` (Locked/Normal toggle).
  - Modern UI with Custom Cyber-Blue theme and helpful status bars.
  - Seamless navigation and integration with Neovim.
- **📝 Editor:** **Neovim (DevOps Enhanced)**.
  - Lazy loading, Telescope, Neo-tree, Treesitter.
  - Advanced LSP (C++, Go, Node, YAML, Bash, Docker).
  - Snippets (`friendly-snippets`), Beautiful Diagnostics UI.
  - **OSC 52 integration**: Seamless clipboard synchronization when working via SSH.
- **🤖 AI:** Auto-installation of `@google/gemini-cli`.
- **📦 Modular:** Clean file structure separated by function (`modules/*.nix`).

## 📂 Directory Structure

```text
~/home_env_dotfiles
├── flake.nix             # Entry point (Unified profile)
└── nix
    ├── home.nix          # Main loader
    └── modules
        ├── shell.nix     # Zsh, Starship, Aliases, Zellij autostart, Direnv
        ├── starship.toml # Jetpack theme config
        ├── neovim.nix    # Editor config
        ├── zellij.nix    # Modern Multiplexer config
        ├── packages.nix  # System packages & Installation scripts
        └── git.nix       # Git user config
```

## 🚀 Installation

This project includes an all-in-one setup script (`install.sh`) that will automatically:
1. Install Nix Package Manager and enable Flakes.
2. Configure variables based on your username (`jin`, etc.).
3. Download and apply the `zsh`, `zellij`, and `neovim` configurations.
4. Auto-install Node.js via `fnm`.
5. Set `zsh` as your default shell.

### Option 1: Quick Install
If you haven't cloned this repository yet, run these commands to clone and install everything:

```bash
git clone https://github.com/jin00100/home_env_dotfiles.git ~/home_env_dotfiles
cd ~/home_env_dotfiles
chmod +x install.sh
./install.sh
```

*(Note: If Nix is not already installed on your system, the script will install it for you and may pause, asking you to restart your terminal. Simply restart the terminal, then run `./install.sh` again to finish the setup.)*

### Option 2: Local Install
If you have already cloned the repository manually:

```bash
cd ~/home_env_dotfiles
chmod +x install.sh
./install.sh
```

## ⌨️ Cheat Sheet

| Command | Action | Alias |
| :--- | :--- | :--- |
| `hms` | Apply Nix configuration changes | `home-manager switch ...` |
| `nix-clean` | Clean up old Nix generations and garbage collect | `nix-env --delete-generations old...` |
| `ll` / `lt` | List files (Grid / Tree view) | `eza ...` |
| `zj` | Start Zellij session | - |
| `zj_shortcuts` | Show Zellij keybindings summary | - |
| `vi` / `vim` | Open Neovim | `nvim` |
| `Space + f` | Find files (Telescope) | - |
| `Space + g` | Live Grep (Telescope) | - |
| `Ctrl + n` | Toggle File Explorer | `Neotree` |
| `Ctrl + g` | Zellij Prefix (Lock/Unlock) | - |
| `Alt + h/j/k/l` | Navigate between Zellij panes | - |

## 🔄 Maintenance

### Update Packages & Configuration

To update all tools and environments managed by Nix and Home Manager to their latest versions, either run the `./update.sh` script or execute the following commands in order:

```bash
# 1. Update the package recipes (flake.lock) to the latest state
nix flake update

# 2. Apply and build the updated configurations
hms
```

---

**Note:** Ghostty configuration is managed, but the binary should be installed manually on Native Linux.

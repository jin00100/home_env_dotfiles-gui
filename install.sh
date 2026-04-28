#!/usr/bin/env bash
set -e

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting dotfiles installation and setup...${NC}"

# --- Section 0: System Dependencies ---
if [ -f /etc/debian_version ]; then
    echo -e "${YELLOW}📦 Detecting Debian/Ubuntu. Installing system dependencies...${NC}"
    sudo -v # Prompt for sudo password upfront
    sudo apt-get update
    sudo apt-get install -y curl git software-properties-common
    
    if ! grep -q "^deb .*cppiber/hyprland" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        sudo add-apt-repository -y ppa:cppiber/hyprland
    fi
    sudo apt-get update
    sudo apt-get install -y hyprland xdg-desktop-portal-hyprland hyprlock hypridle fcitx5 fcitx5-hangul fcitx5-config-qt
    echo -e "${GREEN}✅ System dependencies installed.${NC}"
fi

# --- Section 1: Nix Installation ---
if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}📦 Nix not found. Installing Nix...${NC}"
    # Use Determinate Systems installer for robust non-interactive installation
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --no-confirm
    
    # Crucial: The installer modifies system profiles. A re-login or reboot is typically needed.
    # We will use 'su -l' to force a login shell for the user running the script to get the new PATH.
    echo -e "${GREEN}✅ Nix installation finished.${NC}"
    echo -e "${YELLOW}⏳ Preparing to apply configuration in a new login shell...${NC}"

    # Re-invoke the rest of the script inside a fresh login shell for the current user.
    # This is the most reliable way to get the Nix environment on the PATH.
    # We pass the current directory to the sub-shell.
    INSTALL_DIR=$(pwd)
    sudo su -l "$USER" -c "cd '$INSTALL_DIR' && bash '$0' --post-nix-install"
    exit 0
fi

# --- Section 2: Home Manager Deployment (and subsequent runs) ---

# This part of the script is either run if Nix was already installed,
# or by the 'su -l' command from Section 1.

if [[ "$1" == "--post-nix-install" ]]; then
    echo -e "${GREEN}✅ Successfully re-executed in a new login shell.${NC}"
fi

echo -e "${GREEN}✅ Nix is available on the PATH.${NC}"

# Ensure flakes are enabled
if [ ! -d "$HOME/.config/nix" ] || ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    echo -e "${YELLOW}⚙️ Enabling Nix flakes for user $USER...${NC}"
    mkdir -p "$HOME/.config/nix"
    echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
fi

echo -e "${YELLOW}✨ Applying all dotfiles configurations... This may take a while.${NC}"
home-manager switch --extra-experimental-features "nix-command flakes" --flake .#default --impure -b backup

# --- Section 3: Post-Activation Tasks ---
echo -e "${YELLOW}🛡️ Fortifying Hyprland configuration...${NC}"
if [ -f "$HOME/.nix-profile/etc/xdg/hypr/hyprland.conf" ]; then
    mkdir -p "$HOME/.config/hypr"
    cp "$HOME/.nix-profile/etc/xdg/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
    echo -e "${GREEN}✅ Hyprland configuration fortified.${NC}"
else
    echo -e "${RED}⚠️ Could not find generated Hyprland config. Your Hyprland session may not start correctly.${NC}"
fi

if command -v fnm &> /dev/null; then
    echo -e "${YELLOW}📦 Setting up Node.js (via fnm)...${NC}"
    fnm install --lts
    fnm default lts-latest
    echo -e "${GREEN}✅ Node.js LTS configured.${NC}"
fi

echo -e "${YELLOW}⚙️ Setting Zsh as the default shell...${NC}"
if NIX_ZSH_PATH=$(which zsh); then
    if ! grep -q "$NIX_ZSH_PATH" /etc/shells; then
        echo "$NIX_ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    if [ "$SHELL" != "$NIX_ZSH_PATH" ]; then
        chsh -s "$NIX_ZSH_PATH"
        echo -e "${GREEN}✅ Default shell changed to Zsh.${NC}"
    fi
else
    echo -e "${RED}⚠️ Could not find Nix installed Zsh.${NC}"
fi

echo ""
echo -e "${GREEN}🎉 All done! Dotfiles installation is complete.${NC}"
echo -e "${BLUE}👉 Please reboot your system ('sudo reboot') and select 'Hyprland' at the login screen.${NC}"


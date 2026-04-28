#!/usr/bin/env bash
set -e

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Self-bootstrap: If Nix isn't on the PATH, but this is the second run,
# it means we need to source the environment first.
if [ "$1" != "--re-executed" ] && ! command -v nix &> /dev/null; then
    # Try to find and source the Nix profile
    if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
fi

# Re-execute under a login shell if Nix is still not available after sourcing
if [ "$1" != "--re-executed" ] && ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}Nix not found. Re-executing script in a login shell to ensure correct environment...${NC}"
    # Use bash -l to simulate a login shell which should correctly source /etc/profile.d
    bash -l "$0" --re-executed
    exit 0
fi


echo -e "${BLUE}🚀 Starting dotfiles installation and setup...${NC}"

# 0. Install System Dependencies (Ubuntu/Debian)
if [ -f /etc/debian_version ]; then
    echo -e "${YELLOW}📦 Detecting Debian/Ubuntu system. Installing core engines and dependencies...${NC}"
    # Ask for sudo upfront
    sudo -v
    
    echo -e "${BLUE}Installing basic utilities (curl, git)...${NC}"
    sudo apt-get update
    sudo apt-get install -y curl git software-properties-common
    
    echo -e "${BLUE}Adding Hyprland PPA and installing Window Manager engines...${NC}"
    if ! grep -q "^deb .*cppiber/hyprland" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        sudo add-apt-repository -y ppa:cppiber/hyprland
        sudo apt-get update
    fi
    sudo apt-get install -y hyprland xdg-desktop-portal-hyprland hyprlock hypridle
    
    echo -e "${BLUE}Installing Input Method (Fcitx5)...${NC}"
    sudo apt-get install -y fcitx5 fcitx5-hangul fcitx5-config-qt
    
    echo -e "${GREEN}✅ System dependencies installed.${NC}"
else
    echo -e "${YELLOW}⚠️ Not a Debian/Ubuntu system. Skipping apt package installation.${NC}"
    echo -e "${YELLOW}Please ensure curl, git, and Hyprland engines are installed manually.${NC}"
fi

# 1. Check for Nix Package Manager
if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}🧹 Cleaning up previous failed Nix installation residues (if any)...${NC}"
    sudo find /etc ~/ -name "*.backup-before-nix" -type f -delete 2>/dev/null || true

    echo -e "${YELLOW}📦 Nix is not installed. Installing Nix...${NC}"
    # Using Determinate Systems installer for better non-interactive installation
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --no-confirm
    
    echo -e "${GREEN}✅ Nix installation complete. The script will re-execute to load the new environment.${NC}"
    # Re-execute the script in a login shell to ensure Nix is on the PATH
    exec bash -l "$0" --re-executed
fi

# We are now sure Nix is on the PATH
echo -e "${GREEN}✅ Nix is available on the PATH.${NC}"

# 2. Ensure flakes are enabled
if ! nix path-info --extra-experimental-features "nix-command flakes" . &>/dev/null; then
    echo -e "${YELLOW}⚙️ Enabling Nix flakes...${NC}"
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# 3. Apply Home Manager Configuration
echo -e "${YELLOW}✨ Applying all dotfiles configurations... This may take a while.${NC}"
home-manager switch --extra-experimental-features "nix-command flakes" --flake .#default --impure -b backup

# 4. Fortify Hyprland Configuration (Final Fix)
echo -e "${YELLOW}🛡️ Fortifying Hyprland configuration to prevent fallback error...${NC}"
if [ -f "$HOME/.nix-profile/etc/xdg/hypr/hyprland.conf" ]; then
    mkdir -p "$HOME/.config/hypr"
    cp "$HOME/.nix-profile/etc/xdg/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
    echo -e "${GREEN}✅ Hyprland configuration fortified.${NC}"
else
    echo -e "${RED}⚠️ Could not find generated Hyprland config. Your Hyprland session may not start correctly.${NC}"
fi

# 5. Source newly updated environment variables
# This step is mostly for the current script's context if needed
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# 6. Auto-install Node.js (via fnm)
if command -v fnm &> /dev/null; then
    echo -e "${YELLOW}📦 Setting up Node.js (via fnm)...${NC}"
    fnm install --lts
    fnm default lts-latest
    echo -e "${GREEN}✅ Node.js LTS configured.${NC}"
else
    echo -e "${RED}⚠️ fnm not found after applying config. Skipping Node.js installation.${NC}"
fi

# 7. Set default shell to Zsh
echo -e "${YELLOW}⚙️ Setting Zsh as the default shell...${NC}"
NIX_ZSH_PATH=$(which zsh)
if [ -n "$NIX_ZSH_PATH" ] && [ -x "$NIX_ZSH_PATH" ]; then
    if ! grep -q "$NIX_ZSH_PATH" /etc/shells; then
        echo -e "${BLUE}Adding Nix Zsh to /etc/shells (requires sudo access)...${NC}"
        echo "$NIX_ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    
    if [ "$SHELL" != "$NIX_ZSH_PATH" ]; then
        echo -e "${BLUE}Changing default shell to Nix Zsh...${NC}"
        chsh -s "$NIX_ZSH_PATH"
        echo -e "${GREEN}✅ Default shell changed to Zsh.${NC}"
    else
        echo -e "${GREEN}✅ Zsh is already the default shell.${NC}"
    fi
else
    echo -e "${RED}⚠️ Could not find Nix installed Zsh. Skipping default shell changing.${NC}"
fi

echo ""
echo -e "${GREEN}🎉 All done! Dotfiles installation is complete.${NC}"
echo -e "${BLUE}👉 Please reboot your system ('sudo reboot') and select 'Hyprland' at the login screen.${NC}"

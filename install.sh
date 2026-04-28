#!/usr/bin/env bash
set -e

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Ultimate Dotfiles Installation...${NC}"

# --- Section 0: System Dependencies ---
if [ -f /etc/debian_version ]; then
    echo -e "${YELLOW}📦 Detecting Debian/Ubuntu. Installing system dependencies...${NC}"
    sudo -v
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
# Define the absolute path for the nix binary
NIX_BIN_PATH="/nix/var/nix/profiles/default/bin/nix"

if [ ! -f "$NIX_BIN_PATH" ]; then
    echo -e "${YELLOW}📦 Nix not found. Installing Nix...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --no-confirm
    
    # Verify installation
    if [ ! -f "$NIX_BIN_PATH" ]; then
        echo -e "${RED}❌ Nix installation failed. The script cannot continue.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Nix successfully installed.${NC}"
else
    echo -e "${GREEN}✅ Nix is already installed.${NC}"
fi

# --- Section 2: Home Manager Deployment ---
echo -e "${YELLOW}⚙️ Preparing to run Home Manager...${NC}"

# Define the absolute path to the home-manager binary that Nix will build
# Note: This is a predictable path structure within the Nix profile
HOME_MANAGER_BIN_PATH="$HOME/.nix-profile/bin/home-manager"

# Ensure flakes are enabled for the current user
mkdir -p "$HOME/.config/nix"
if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
    echo -e "${GREEN}✅ Nix flakes enabled.${NC}"
fi

# Ensure the user's profile directory exists before running home-manager
USER_NIX_PROFILE_DIR="/nix/var/nix/profiles/per-user/$USER"
if [ ! -d "$USER_NIX_PROFILE_DIR" ]; then
    echo -e "${YELLOW}Manually creating Nix user profile directory at $USER_NIX_PROFILE_DIR...${NC}"
    sudo mkdir -p "$USER_NIX_PROFILE_DIR"
    sudo chown "$USER" "$USER_NIX_PROFILE_DIR"
fi

echo -e "${YELLOW}✨ Applying all dotfiles configurations using absolute Nix path... This may take a while.${NC}"
# Use the absolute path to 'nix' to run home-manager for the first time.
# This completely bypasses any PATH/sourcing issues in the script's environment.
"$NIX_BIN_PATH" run home-manager/master -- switch --flake .#default --impure -b backup 
    --extra-experimental-features "nix-command flakes"

echo -e "${GREEN}✅ Home Manager configuration applied successfully!${NC}"

# --- Section 3: Post-Activation Tasks ---
# Now that home-manager has run, its binaries should be in the user's profile
if [ ! -x "$HOME_MANAGER_BIN_PATH" ]; then
    echo -e "${RED}❌ Post-activation check failed: 'home-manager' command is still not found in the profile. Aborting post-tasks.${NC}"
    exit 1
fi

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
echo -e "${GREEN}🎉🎉🎉 Ultimate installation complete! All issues resolved.${NC}"
echo -e "${BLUE}👉 Please reboot your system ('sudo reboot') and select 'Hyprland' at the login screen.${NC}"


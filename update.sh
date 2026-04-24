#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Fetching the latest global tool versions from Nixpkgs (nix flake update)...${NC}"
nix flake update

echo -e "${BLUE}🔄 Applying the latest versions and hot-reloading configurations...${NC}"
home-manager switch --flake ~/home_env_dotfiles/#default --impure

echo -e "${GREEN}🎉 Upgrade complete! All tools and environment variables are now up-to-date!${NC}"

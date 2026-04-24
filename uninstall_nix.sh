#!/usr/bin/env bash
set -e

# This script attempts to completely uninstall Nix (multi-user or single-user) from your system.
# WARNING: This will delete everything inside /nix, along with Nix configurations and build users.

echo "⚠️  WARNING: You are about to completely uninstall Nix from your system."
echo "This will permanently delete /nix, which means all packages installed via Nix will be gone."
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting uninstallation."
    exit 1
fi

echo "🚀 Starting thorough Nix uninstallation..."

# 1. Stop and disable systemd services
echo "🛑 Stopping Nix daemon services..."
if command -v systemctl &> /dev/null; then
    sudo systemctl stop nix-daemon.socket nix-daemon.service || true
    sudo systemctl disable nix-daemon.socket nix-daemon.service || true
    sudo systemctl daemon-reload || true
fi

# 2. Kill any lingering Nix processes
echo "🔪 Killing any remaining Nix processes..."
sudo pkill -u root nix-daemon || true

# 3. Clean up the main /nix store and /etc settings
echo "🗑️  Deleting /nix and /etc/nix..."
sudo rm -rf /nix
sudo rm -rf /etc/nix

# 4. Remove systemd service files
echo "🗑️  Removing systemd service files..."
sudo rm -f /etc/systemd/system/nix-daemon.service
sudo rm -f /etc/systemd/system/multi-user.target.wants/nix-daemon.service
sudo rm -f /etc/systemd/system/nix-daemon.socket
sudo rm -f /etc/systemd/system/sockets.target.wants/nix-daemon.socket

# 5. Clean up user-specific states and profiles
echo "🧹 Cleaning up user profiles and cache..."
rm -rf ~/.nix-profile ~/.nix-defexpr ~/.nix-channels ~/.local/state/nix ~/.cache/nix ~/.config/nix
sudo rm -rf /root/.nix-profile /root/.nix-defexpr /root/.nix-channels /root/.local/state/nix /root/.cache/nix /root/.config/nix

# 6. Delete Nix build users and group (nixbld1..nixbld32)
echo "👥 Removing Nix build users and groups..."
for i in $(seq 1 32); do
    sudo userdel -f nixbld$i 2>/dev/null || true
done
sudo groupdel nixbld 2>/dev/null || true

# 7. Restore modified shell rc files
echo "🔄 Restoring shell backup files (if they exist)..."
for file in /etc/bashrc /etc/profile /etc/bash.bashrc /etc/zshrc; do
    if [ -e "${file}.backup-before-nix" ]; then
        echo "   Restoring ${file}"
        sudo mv -f "${file}.backup-before-nix" "${file}"
    fi
done

echo "🧹 Forcefully sweeping any stubborn Nix backup residues..."
sudo find /etc ~/ -name "*.backup-before-nix" -type f -delete 2>/dev/null || true

echo ""
echo "✅ Uninstallation complete!"
echo "You can now safely attempt to reinstall Nix from scratch."
echo "If you want to reinstall Nix now, you can run:"
echo "sh <(curl -L https://nixos.org/nix/install) --daemon"

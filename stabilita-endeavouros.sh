#!/bin/bash

echo "Setting up stability and protection for Lenovo Miix 320 on EndeavourOS..."

# 1. Installation of LTS kernel and necessary tools
echo "Installing LTS kernel, ZRAM, and pacman cache management tools..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm linux-lts linux-lts-headers zram-generator pacman-contrib

# 2. Configure ZRAM (Offload eMMC disk)
echo "Configuring ZRAM (50% of RAM capacity)..."
sudo bash -c 'cat > /etc/systemd/zram-generator.conf << "EOF"
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF'

# 3. Automatic cleaning of disk from old updates
echo "Enabling automatic cleaning of pacman cache..."
sudo systemctl enable --now paccache.timer

# 4. Create safeguard against battery drain during updates
echo "Creating battery safety script..."
sudo bash -c 'cat > /usr/local/bin/kontrola-baterie.sh << "EOF"
#!/bin/bash
BATTERY_CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100)
BATTERY_STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")

if [[ "$BATTERY_STATUS" == "Discharging" ]] && [[ "$BATTERY_CAPACITY" -lt 20 ]]; then
    echo "=========================================================="
    echo " KRITICKÁ CHYBA: Batéria má pod 20% ($BATTERY_CAPACITY%)!"
    echo " Aktualizácia bola zablokovaná pre ochranu systému."
    echo " Pripoj nabíjačku a skús to znova."
    echo "=========================================================="
    exit 1
fi
exit 0
EOF'

# Make script executable
sudo chmod +x /usr/local/bin/kontrola-baterie.sh

# Create Pacman Hook that automatically calls the script
sudo mkdir -p /etc/pacman.d/hooks
sudo bash -c 'cat > /etc/pacman.d/hooks/ochrana-baterie.hook << "EOF"
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Battery status check before installation...
When = PreTransaction
Exec = /usr/local/bin/kontrola-baterie.sh
AbortOnFail
EOF'

echo "=========================================================="
echo "Done! System is now protected against wear and battery drain."
echo "After reboot, ZRAM will be active. At device boot (in boot menu)"
echo "you can select 'EndeavourOS (linux-lts)' via arrow keys."
echo "To apply changes, restart: sudo reboot"
echo "=========================================================="
#!/bin/bash

echo "Zahajujem nastavenie stability a ochrany pre Lenovo Miix 320..."

# 1. Inštalácia LTS jadra a potrebných nástrojov
echo "Inštalujem LTS kernel, ZRAM a nástroje na správu pacman cache..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm linux-lts linux-lts-headers zram-generator pacman-contrib

# 2. Nastavenie ZRAM (Odľahčenie eMMC disku)
echo "Konfigurujem ZRAM (50% RAM kapacity)..."
sudo bash -c 'cat > /etc/systemd/zram-generator.conf << "EOF"
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF' 

# 3. Automatické čistenie disku od starých aktualizácií
echo "Zapínam automatické čistenie cache pamäte balíčkov..."
sudo systemctl enable --now paccache.timer

# 4. Vytvorenie poistky proti vybitiu batérie počas aktualizácie
echo "Vytváram bezpečnostný skript pre kontrolu batérie..."

# Samotný skript na kontrolu batérie
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

# Udelenie práv na spustenie skriptu
sudo chmod +x /usr/local/bin/kontrola-baterie.sh

# Vytvorenie samotného Pacman Hooku, ktorý skript automaticky zavolá
sudo mkdir -p /etc/pacman.d/hooks
sudo bash -c 'cat > /etc/pacman.d/hooks/ochrana-baterie.hook << "EOF"
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Kontrola stavu batérie pred inštaláciou...
When = PreTransaction
Exec = /usr/local/bin/kontrola-baterie.sh
AbortOnFail
EOF'

echo "=========================================================="
echo "Hotovo! Systém je teraz chránený proti opotrebovaniu aj vybitiu."
echo "Po reštarte sa aktivuje ZRAM. Pri štarte zariadenia (v boot menu)"
echo "si môžeš šípkami zvoliť položku 'Arch Linux (linux-lts)'."
echo "Pre aplikovanie reštartuj: sudo reboot"
echo "=========================================================="

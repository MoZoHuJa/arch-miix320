#!/bin/bash

echo "Optimalizujem Arch Linux a GNOME pre Lenovo Miix 320..."

# 1. Inštalácia podpory pre senzory (rotácia) a ochranu RAM (proti zamrznutiu)
echo "Stahujem a aktivujem iio-sensor-proxy a earlyoom..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm iio-sensor-proxy earlyoom

sudo systemctl enable --now iio-sensor-proxy
sudo systemctl enable --now earlyoom

# 2. Nastavenie dotykovej klávesnice
# GNOME inteligentne deteguje dock. Keď je pripojený, klávesnica na obrazovke sa nevysunie.
# Keď dock odpojíš, pri ťuknutí do textového poľa sa OSK (On-Screen Keyboard) automaticky zobrazí.
echo "Zapinam inteligentnu dotykovu klavesnicu..."
gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true

# 3. Extrémna optimalizácia grafiky a procesov na pozadí
echo "Orezavam GNOME na maximalny vykon..."

# Vypnutie všetkých prechodov a animácií (okamžité reakcie)
gsettings set org.gnome.desktop.interface enable-animations false

# Vypnutie automatického sťahovania aktualizácií na pozadí (šetrí eMMC disk)
gsettings set org.gnome.software download-updates false

# Vypnutie indexovania súborov (Tracker) - najväčší žrút výkonu na slabých procesoroch
systemctl --user mask tracker-extract-3.service tracker-miner-fs-3.service tracker-miner-rss-3.service tracker-writeback-3.service
systemctl --user stop tracker-extract-3.service tracker-miner-fs-3.service tracker-miner-rss-3.service tracker-writeback-3.service

echo "=========================================================="
echo "Hotovo! System je orezany, rotacia aj dotyk su pripravene."
echo "Pre uplne aplikovanie zmian restartuj zariadenie:"
echo "sudo reboot"
echo "=========================================================="

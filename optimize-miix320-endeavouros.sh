#!/bin/bash

echo "Optimizing EndeavourOS and GNOME for Lenovo Miix 320..."

# 1. Installation of sensor support (rotation) and RAM protection (against freezing)
echo "Fetching and activating iio-sensor-proxy and earlyoom..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm iio-sensor-proxy earlyoom

sudo systemctl enable --now iio-sensor-proxy
sudo systemctl enable --now earlyoom

# 2. Touch keyboard configuration
# GNOME intelligently detects dock. When docked, on-screen keyboard does not appear.
# When dock is unplugged, tapping a text field automatically shows OSK (On-Screen Keyboard).
echo "Enabling intelligent touch keyboard..."
gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true

# 3. Extreme graphics and background process optimization
echo "Trimming GNOME for maximum performance..."

# Disable all transitions and animations (instant responses)
gsettings set org.gnome.desktop.interface enable-animations false

# Disable automatic background update downloads (saves eMMC disk)
gsettings set org.gnome.software download-updates false

# Disable file indexing (Tracker) - biggest performance hog on weak processors
systemctl --user mask tracker-extract-3.service tracker-miner-fs-3.service tracker-miner-rss-3.service tracker-writeback-3.service
systemctl --user stop tracker-extract-3.service tracker-miner-fs-3.service tracker-miner-rss-3.service tracker-writeback-3.service

echo "=========================================================="
echo "Done! System is trimmed, rotation and touch are ready."
echo "For full application of changes, restart the device:"
echo "sudo reboot"
echo "=========================================================="
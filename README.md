# New System Install

## Pacman

### All systems

pacman -S doas git nvim alsa-utils bluez bluez-utils fatsort accountsservice

### Guis

pacman -S firefox blueberry xfce4-settings flameshot volumeicon udiskie tickrs \
 nitrogen rofi polybar solaar nerd-fonts cmus lightdm dex gamemode

## Paru

```
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

### All systems

paru -S tmuxinator tmux-plugin-manager bat eza starship

### Guis

paru -S google-chrome remmina-plugin-rdesktop freerdp betterlockscreen xss-lock noto-fonts-emoji-git thunar zenity dunst

## Install NVM

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

## systemctl

systemctl --user enable <services in .config/systemctl/user>

## Manual Installs

https://github.com/tmux-plugins/tpm
https://github.com/mop-tracker/mop

## Stupid fucking capslock key

localectl set-x11-keymap us pc105 "" ctrl:nocaps,terminate:ctrl_alt_bksp

### old

fix capslock https://www.ejmastnak.com/tutorials/arch/caps2esc/

## Teams

install teams pwa through chrome then move the file to ~/.local/share/applications/teams.desktop

## /etc

### Use more cores

MAKEFLAGS="-j $(nproc)" in /etc/makepkg.conf

### Use doas instead of sudo

Edit /etc/paru.conf

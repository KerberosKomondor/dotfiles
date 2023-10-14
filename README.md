
pacman -S doas firefox git nvim alsa-utils bluez bluez-utils blueberry xfce4-settings flameshot nitrogen rofi \
    volumeicon udiskie tickrs fatsort

paru -S google-chrome tmuxinator noto-fonts-emoji-git nerd-fonts-meta remmina-plugin-rdesktop freerdp \ 
    tmux-plugin-manager

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

systemctl --user enable <services in .config/systemctl/user>

https://github.com/tmux-plugins/tpm
https://github.com/mop-tracker/mop

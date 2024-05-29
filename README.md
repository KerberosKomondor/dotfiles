pacman -S doas git nvim alsa-utils bluez bluez-utils fatsort
pacman -S firefox blueberry xfce4-settings flameshot volumeicon udiskie tickrs \
 nitrogen rofi polybar solaar nerd-fonts cmus

paru -S tmuxinator tmux-plugin-manager
paru -S google-chrome remmina-plugin-rdesktop freerdp betterlockscreen xss-lock noto-fonts-emoji-git

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

systemctl --user enable <services in .config/systemctl/user>

https://github.com/tmux-plugins/tpm
https://github.com/mop-tracker/mop

fix capslock https://www.ejmastnak.com/tutorials/arch/caps2esc/

# Neovim

## Prereqs

### Pacman requirements

```bash
sudo pacman -S go \
  luarocks \
  wget \
  ruby \
  fd \
  ripgrep \
  fzf \
  xclip \
  python3 \
  jq \
  tidy \
  stylua \
  luacheck \
  clang \
  cmake \
  sqlite
```

### AUR requirements

```bash
paru -S nvm \
  python-pynvim-git \
  ruby-neovim \
  jira-cli-bin
```

### NPM requirements

```bash
npm i -g eslint_d \
  @fsouza/prettierd \
  eslint \
  prettier \
  @styled/typescript-styled-plugin \
  typescript-styled-plugin \
  neovim \
  tree-sitter-cli
```

## RUN CHECKHEALTH

run :checkhealth from inside nvim and fix other issues

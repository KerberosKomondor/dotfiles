#!/bin/zsh

exit_if_master_password_error() {
  if [[ -z $BW_SESSION ]]; then
    notify-send --wait --urgency=critical "master password was incorrect"
    exit 1
  fi
}

unlock_bw_if_locked() {
  if [[ -z $BW_SESSION ]]; then
    export BW_SESSION="$(bw unlock "$(zenity --password)" --raw)"
  fi
}

connect() {
  unlock_bw_if_locked
  exit_if_master_password_error

  local bw_id="f454103e-c244-452c-89f7-b1a80036ee46"

  local password="$(bw get password okta.com)" || exit 1
  local username="$(bw get username $bw_id)"
  local ip_addr="$(bw get uri $bw_id)"

  xfreerdp /v:$ip_addr \
    /bpp:32 \
    /u:$username \
    /p:$password \
    /cert:ignore \
    /sec:tls \
    /w:1920 \
    /h:1080
    /d: \
    /kbd:remap:58=29 \
    +clipboard \
}

connect "$@"

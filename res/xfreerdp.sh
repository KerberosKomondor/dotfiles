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

try_command() {
  readonly cmd=${1:?"the command must be specified"}
  readonly retries=3
  readonly wait_retry=3

  for i in `seq 1 $retries`; do
    $cmd
    ret_value=$?
    [ $ret_value -eq 0 ] && break
    echo "> failed with $ret_value, waiting to retry..."
    sleep $wait_retry
  done

  exit $ret_value
}

main() {
  unlock_bw_if_locked
  exit_if_master_password_error

  local bw_id="f454103e-c244-452c-89f7-b1a80036ee46"

  local password="$(bw get password okta.com)" || exit 1
  local username="$(bw get username $bw_id)"
  local ip_addr="$(bw get uri $bw_id)"

  command=$(xfreerdp3 /v:$ip_addr \
    /bpp:32 \
    /u:$username \
    /p:$password \
    /cert:ignore \
    /sec:tls \
    /w:1920 \
    /h:1080 \
    /d: \
    /kbd:remap:58=29 \
    +clipboard
  )

  try_command $command
}

main "$@"

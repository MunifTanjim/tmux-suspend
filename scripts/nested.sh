#!/usr/bin/env bash

set -eu

declare -r CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare -r depth_option='@suspend_depth'

get_depth() {
  local -r value="$(tmux show-option -qv "${depth_option}")"
  echo "${value:-0}"
}

declare -r action="${1}"

case "${action}" in
  enter)
    # This level is active. Start the depth counter, then suspend it.
    declare -r on_suspend_command="${2}"
    declare -r suspended_options="${3}"
    tmux set-option -q "${depth_option}" 1
    "${CURRENT_DIR}/suspend.sh" "${on_suspend_command}" "${suspended_options}"
    ;;
  deeper)
    # This level is suspended. Count one more level and forward the key inward.
    declare -r down_key="${2}"
    tmux set-option -q "${depth_option}" "$(( $(get_depth) + 1 ))"
    tmux send-keys "${down_key}"
    ;;
  shallower)
    # This level is suspended. Come out one level, or forward the key inward.
    declare -r up_key="${2}"
    declare -r on_resume_command="${3}"
    declare -r depth="$(( $(get_depth) - 1 ))"
    if [[ "${depth}" -le 0 ]]; then
      "${CURRENT_DIR}/resume.sh" "${on_resume_command}"
    else
      tmux set-option -q "${depth_option}" "${depth}"
      tmux send-keys "${up_key}"
    fi
    ;;
esac

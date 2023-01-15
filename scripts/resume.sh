#!/usr/bin/env bash

set -eu

set_options_for_resumed_state() {
  local -r escaped_delim="${RANDOM}${RANDOM}${RANDOM}"

  local _options="${1#,}"
  _options="${_options//\\,/${escaped_delim}}"
  IFS=, read -ra options <<< "${_options}"

  local flags=""
  local name=""
  local value=""

  for item in "${options[@]}"; do
    name="$(echo "${item%%:*}" | xargs)"
    item="${item#*:}"
    flags="${item%%:*}"
    value="${item#*:}"
    value="${value//${escaped_delim}/,}"

    tmux set-option -q${flags} "${name}" "${value}"
  done
}

declare -r on_resume_command="${1}"
declare -r resumed_options="$(tmux show-option -qv '@suspend_resumed_options')"

declare -r prefix="$(tmux show-option -qv '@suspend_prefix')"
declare prefix_flags=""
if [[ -z ${prefix} ]]; then
  prefix_flags="u"
fi

eval "${on_resume_command}"

set_options_for_resumed_state "${resumed_options}"

tmux set-option -q${prefix_flags} prefix "${prefix}" \; set-option -u key-table

tmux refresh-client -S

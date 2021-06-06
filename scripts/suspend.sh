#!/usr/bin/env bash

set -eu

set_options_for_suspended_state() {
  local -r escaped_delim="${RANDOM}${RANDOM}${RANDOM}"

  local _options="${1#,}"
  _options="${_options//\\,/${escaped_delim}}"
  IFS=, read -ra options <<< "${_options}"

  local flags=""
  local name=""
  local value=""

  local resumed_options=""
  for item in "${options[@]}"; do
    if [[ -z "$(echo "${item}" | xargs)" ]]; then
      continue
    fi

    name="$(echo "${item%%:*}" | xargs)"
    item="${item#*:}"
    flags="${item%%:*}"
    value="${item#*:}"
    value="${value//${escaped_delim}/,}"

    has_value="$(tmux show-options -qv${flags} "${name}" | wc -l | xargs)"
    preserved_flags="${flags}"
    if [[ "${has_value}" = "0" ]]; then
      preserved_flags="${preserved_flags}u"
    fi
    preserved_value="$(tmux show-options -qv${flags} "${name}")"
    resumed_options="${resumed_options},${name}:${preserved_flags}:${preserved_value//,/\\,}"

    tmux set-option -q${flags} "${name}" "${value}"
  done

  tmux set-option -q '@suspend_resumed_options' "${resumed_options}"
}

declare -r on_suspend_command="${1}"
declare -r suspended_options="${2}"

tmux set-option -q '@suspend_prefix' "$(tmux show-option -qv prefix)"

tmux set-option -q prefix none \; set-option key-table suspended \; \
  if-shell -F '#{pane_in_mode}' 'send-keys -X cancel' \; \
  if-shell -F '#{pane_synchronized}' 'set synchronize-panes off'

set_options_for_suspended_state "${suspended_options}"

eval "${on_suspend_command}"

tmux refresh-client -S

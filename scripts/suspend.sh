#!/usr/bin/env bash

set -ex

declare -r on_suspend_command="$1"

tmux set-option -q '@suspend_prefix' "$(tmux show-option -qv prefix)"

tmux set-option -q prefix none \; set-option key-table suspended \; \
  if-shell -F '#{pane_in_mode}' 'send-keys -X cancel' \; \
  if-shell -F '#{pane_synchronized}' 'set synchronize-panes off'

eval "$on_suspend_command"

tmux refresh-client -S

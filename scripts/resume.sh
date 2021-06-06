#!/usr/bin/env bash

set -ex

declare -r on_resume_command="$1"
declare -r prefix="$(tmux show-option -qv '@suspend_prefix')"
declare prefix_scope=""
if [[ -z $prefix ]]; then
  prefix_scope="u"
fi

tmux set-option -q$prefix_scope prefix "$prefix" \; set-option -u key-table

eval "$on_resume_command"

tmux refresh-client -S

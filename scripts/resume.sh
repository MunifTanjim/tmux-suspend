#!/usr/bin/env bash

set -ex

declare -r on_resume_command="$1"
declare -r prefix="$(tmux show-option -gqv '@suspend_prefix')"

tmux set-option -g prefix "$prefix" \; set-option -u key-table

eval "$on_resume_command"

tmux refresh-client -S

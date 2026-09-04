# Tmux Suspend

Plugin that lets you suspend **local tmux session**, so that you can work with
**nested remote tmux session** painlessly.

**Demo**:

![Tmux Suspend Demo GIF](screenshots/tmux-suspend-demo.gif)

## Usage

With the default keybinding,

Press `F12` to suspend your local tmux session. In suspeded state, you can only
interact with the currently active pane (which will be running the remote tmux session).

Press `F12` again in suspended state to resume local tmux session.

_**Note**_: If you have [**tmux-mode-indicator**](https://github.com/MunifTanjim/tmux-mode-indicator)
plugin installed, it'll automatically show indicator for the suspended state.

### Nested Sessions (arbitrary depth)

The single `@suspend_key` toggles one level. It cannot reach a tmux that is
nested more than one level deep, because the outer tmux always owns the key.

To control tmux sessions nested to any depth, enable nested mode. Nested mode
adds two directional keys:

- `Ctrl-F12` (`@suspend_nested_down_key`) — move control one level inward.
- `Ctrl-Shift-F12` (`@suspend_nested_up_key`) — move control one level outward.

Press `Ctrl-F12` to step into the inner tmux. Press it again to step deeper.
Press `Ctrl-Shift-F12` to step back out one level. Each level keeps its own
depth counter and forwards the key inward with `send-keys`, so this works across
`ssh` without extra environment configuration.

Enable nested mode:

```conf
set -g @suspend_nested 'on'
```

_**Requirements**_:

- Install tmux-suspend and set `@suspend_nested 'on'` at **every** nested level.
  The inner level must bind the same keys to receive the forwarded key.
- Your terminal must send distinct sequences for `Ctrl-F12` and
  `Ctrl-Shift-F12`, and tmux must recognize them. Enable extended keys:

  ```conf
  set -s extended-keys on
  ```

  Some terminals do not send these key combinations.
In nested mode, `F12` also becomes depth-aware. `F12` suspends the current level
and, when suspended, surfaces one level at a time. So `F12` is safe to mix with
`Ctrl-F12` and `Ctrl-Shift-F12`. It cannot resume out of order and leave an
inner level suspended. At a single level, `F12` behaves exactly as before.

## Installation

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

Add this repository as a TPM plugin in your `.tmux.conf` file:

```conf
set -g @plugin 'MunifTanjim/tmux-suspend'
```

Press `prefix + I` in Tmux environment to install it.

### Manual Installation

Clone this repository:

```bash
git clone https://github.com/MunifTanjim/tmux-suspend.git ~/.tmux/plugins/tmux-suspend
```

Add this line in your `.tmux.conf` file:

```conf
run-shell ~/.tmux/plugins/tmux-suspend/suspend.tmux
```

Reload Tmux configuration file with:

```sh
tmux source-file ~/.tmux.conf
```

## Configuration Options

The following configuration options are available:

### `@suspend_key`

Key used to suspend/resume local tmux session. This is not binded to any Prefix.

```conf
set -g @suspend_key 'F12'
```

### `@suspend_nested`

Enables nested mode for controlling tmux sessions nested to any depth. Default
is `off`. Set it to `on` to bind the directional keys below. See
[Nested Sessions](#nested-sessions-arbitrary-depth).

```conf
set -g @suspend_nested 'off'
```

### `@suspend_nested_down_key` and `@suspend_nested_up_key`

Keys used to move control inward and outward in nested mode. They are bound only
when `@suspend_nested` is `on`.

```conf
set -g @suspend_nested_down_key 'C-F12'
set -g @suspend_nested_up_key 'C-S-F12'
```

### `@suspend_suspended_options`

Comma-seperated list of items denoting options to set for suspended state.
These options will be automatically reverted when session is resumed.

```conf
set -g @suspend_suspended_options " \
  @mode_indicator_custom_prompt:: ---- , \
  @mode_indicator_custom_mode_style::bg=brightblack\\,fg=black, \
"
```

The syntax of each item is `#{option_name}:#{option_flags}:#{option_value}`.

| Item Segment      | Description                                                                |
| ----------------- | -------------------------------------------------------------------------- |
| `#{option_name}`  | name of the option.                                                        |
| `#{option_flags}` | flags accepted by `set-option`, can be left empty.                         |
| `#{option_value}` | value of the option, commas (`,`) inside value need to be escaped as `\\,` |

For example:

```conf
# remove colors from status line for suspended state
set -g @suspend_suspended_options " \
  status-left-style::bg=brightblack\\,fg=black bold dim, \
  window-status-current-style:gw:bg=brightblack\\,fg=black, \
  window-status-last-style:gw:fg=brightblack, \
  window-status-style:gw:bg=black\\,fg=brightblack, \
  @mode_indicator_custom_prompt:: ---- , \
  @mode_indicator_custom_mode_style::bg=brightblack\\,fg=black, \
"
```

### `@suspend_on_suspend_command` and `@suspend_on_resume_command`

These options can be set to arbritary commands to run when session is
suspended (`@suspend_on_suspend_command`) or resumed (`@suspend_on_resume_command`).

```conf
set -g @suspend_on_resume_command ""
set -g @suspend_on_suspend_command ""
```

For example, you can do the same thing that the default value of `@suspend_suspended_options`
does using these options instead:

```conf
set -g @suspend_suspended_options ""

set -g @suspend_on_resume_command "tmux \
  set-option -uq '@mode_indicator_custom_prompt' \\; \
  set-option -uq '@mode_indicator_custom_mode_style'"

set -g @suspend_on_suspend_command "tmux \
  set-option -q '@mode_indicator_custom_prompt' ' ---- ' \\; \
  set-option -q '@mode_indicator_custom_mode_style' 'bg=brightblack,fg=black'"
```

As you can see, it's more convenient to use `@suspend_suspended_options` for setting
and reverting options.

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.

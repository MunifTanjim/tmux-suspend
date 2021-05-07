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

```conf
# key to suspend/resume local tmux session
set -g @suspend_key 'F12'

# command to execute when local tmux session is resumed
set -g @suspend_on_resume_command "tmux \
  set-option -ugq '@mode_indicator_custom_prompt' \\; \
  set-option -ugq '@mode_indicator_custom_mode_style'"

# command to execute when local tmux session is suspended
set -g @suspend_on_suspend_command "tmux \
  set-option -gq '@mode_indicator_custom_prompt' ' ---- ' \\; \
  set-option -gq '@mode_indicator_custom_mode_style' 'bg=brightblack,fg=black'"
```

You can use the `@suspend_on_resume_command` and `@suspend_on_resume_command` to customize tmux status line
to indicate the suspended state.

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.

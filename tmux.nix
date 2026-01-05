{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;

    # NixOS will generate /etc/tmux.conf
    # and automatically source plugins listed below.
    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
      continuum
      vim-tmux-navigator
      yank
    ];

    extraConfig = ''
      ##### Prefix / basic behavior #####
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Mouse (you had it off)
      set -g mouse off

      # Faster Esc / vi-mode responsiveness
      set -s escape-time 50
      set -g display-time 2000

      # Scrollback
      set -g history-limit 100000

      # vi keys in copy mode / status
      setw -g mode-keys vi
      set -g status-keys vi

      # Clipboard (Wayland): let tmux-yank use wl-copy
      # tmux-yank supports overriding the copy command. :contentReference[oaicite:2]{index=2}
      set -g @override_copy_command '${pkgs.wl-clipboard}/bin/wl-copy'

      ##### Pane management #####
      setw -g aggressive-resize on

      bind-key R command-prompt -I "resize-pane -"  # keeping your custom prompt
      bind -r C-h resize-pane -L 5
      bind -r C-j resize-pane -D 5
      bind -r C-k resize-pane -U 5
      bind -r C-l resize-pane -R 5

      # Alt keys to switch panes (your original M-b / M-f)
      bind -n M-b select-pane -L
      bind -n M-f select-pane -R

      # Splits open in the current pane's path
      unbind %
      unbind '"'
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      # Clear screen (you had it on k)
      unbind k
      bind k send-keys C-l

      # Marked pane switch
      bind Q switch-client -t'{marked}'

      ##### Reload config #####
      # Since NixOS generates /etc/tmux.conf, reload that.
      bind r source-file /etc/tmux.conf \; display-message "Reloaded tmux (/etc/tmux.conf)"

      ##### Resurrect / Continuum settings #####
      # Use XDG-ish paths like your old config
      set -g @resurrect-dir '~/.config/tmux/resurrect'
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-capture-pane-contents 'on'

      set -g @continuum-restore 'on'
      # Your old config had iterm/fullscreen; continuum’s documented knobs differ across versions,
      # but restore + interval is the important part.
      set -g @continuum-save-interval '60'

      ##### Look & feel (kept from your config, de-duplicated) #####
      set -g status on
      set -g status-position bottom

      # Colors (your variables)
      DARKER_FG_COLOR=colour21
      ACCENT_FG_COLOR=colour124
      LIGHTER_FG_COLOR=purple
      DEFAULT_BG_COLOR=default
      BG_HIGHLIGHT_COLOR=#13040f

      set -g message-command-style bg=$DEFAULT_BG_COLOR,fg=$DARKER_FG_COLOR
      set -g message-style         bg=$DEFAULT_BG_COLOR,fg=$DARKER_FG_COLOR
      set -g mode-style            bg=$BG_HIGHLIGHT_COLOR,fg=$DARKER_FG_COLOR

      set -g status-style bg=$DEFAULT_BG_COLOR,fg=$DARKER_FG_COLOR
      set -g pane-border-style fg=$DARKER_FG_COLOR
      set -g pane-active-border-style fg=$LIGHTER_FG_COLOR

      set -g renumber-windows on
      set -g status-left-length 20

      # status-right (kept your date; removed your old battery script path since it was Mac-specific)
      set -g status-right '#(date "+%H:%M %a %d.%m.%y")'

      # window flags formatting (kept)
      set -g window-status-current-format '#{window_index}#(echo ":")#{window_name}#[fg='$ACCENT_FG_COLOR']#{window_flags}'
      set -g window-status-format         '#{window_index}#(echo ":")#{window_name}#[fg='$ACCENT_FG_COLOR']#{window_flags}'

      # Activity/bell off (kept)
      set -g visual-activity off
      setw -g monitor-activity off
      set -g visual-bell off
      set -g visual-silence off
      set -g bell-action none

      # TERM / truecolor
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",screen-256color:Tc"
    '';
  };

  # Make sure the needed programs exist on the system
  environment.systemPackages = with pkgs; [
    tmux
    wl-clipboard
    # optional: if you ever run tmux inside X11 sessions
    xclip
  ];
}


{ config, pkgs, ... }:

{
  imports = [
    ./modules/secrets.nix
    ./modules/github.nix
    ./modules/emacs.nix
    ./modules/firefox.nix
    ./modules/ai.nix
    ./modules/waybar.nix
    ./modules/apps.nix
  ];

  home.username = "dev";
  home.homeDirectory = "/home/dev";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # ===== Zsh =====
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      # Modern CLI
      ls = "eza --icons --group-directories-first";
      ll = "eza -la --icons --group-directories-first";
      lt = "eza --tree --icons -L 2";
      cat = "bat --style=plain";
      top = "btop";
      ".." = "cd ..";
      "..." = "cd ../..";

      # Git (basics — more in github.nix)
      g = "git";
      gs = "git status";
      gc = "git commit";
      gp = "git push";
      gd = "git diff";
      glog = "git log --oneline --graph --decorate -10";

      # System
      rebuild-home = "home-manager switch --flake ~/cahy#dev -b backup";
    };

    initContent = ''
      # FZF init (suppress zle option restore error in fzf --zsh)
      if [[ $options[zle] = on ]]; then
        source <(fzf --zsh 2>/dev/null) 2>/dev/null
      fi

      # FZF theming (Gruvbox)
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=bg+:#3c3836,bg:#1d2021,spinner:#fabd2f,hl:#d3869b,fg:#ebdbb2,header:#83a598,info:#fabd2f,pointer:#fabd2f,marker:#fe8019,fg+:#fbf1c7,prompt:#fabd2f,hl+:#d3869b'

      # Helpers
      mkcd() { mkdir -p "$1" && cd "$1"; }

      # History search
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
      bindkey '^P' history-search-backward
      bindkey '^N' history-search-forward
    '';
  };

  # ===== Starship Prompt =====
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch.symbol = " ";
      nodejs.symbol = " ";
      python.symbol = " ";
      rust.symbol = " ";
      nix_shell.symbol = " ";
      cmd_duration.min_time = 500;
      battery.display = [{ threshold = 30; style = "bold red"; }];
    };
  };

  # ===== FZF =====
  programs.fzf = {
    enable = true;
    enableZshIntegration = false;  # manual init to suppress zle error
  };

  # ===== Zoxide =====
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ===== Direnv =====
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ===== GTK Theme =====
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # ===== Environment =====
  home.sessionVariables = {
    EDITOR = "emacsclient -t";
    VISUAL = "emacsclient -c";
    PAGER = "bat --style=plain";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    LIBVA_DRIVER_NAME = "iHD";
    PATH = "$HOME/.local/bin:$HOME/bin:$PATH";
  };

  # ===== XDG =====
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # ===== Font Config =====
  fonts.fontconfig.enable = true;
}

{ config, pkgs, ... }:

{
  # Core applications and CLI tools

  home.packages = with pkgs; [
    # ── Modern CLI replacements ──
    ripgrep       # grep → rg
    fd            # find → fd
    bat           # cat → bat
    eza           # ls → eza
    delta         # diff pager
    sd            # sed → sd
    dust          # du → dust
    procs         # ps → procs
    btop          # system monitor
    bottom        # alt monitor → btm
    bandwhich     # network monitor
    hexyl         # hex viewer
    tokei         # code stats
    hyperfine     # benchmarking

    # ── File managers ──
    yazi
    lf

    # ── Info & docs ──
    tealdeer      # tldr pages
    jq            # JSON
    yq            # YAML
    fastfetch

    # ── Media ──
    mpv
    imv
    ffmpeg
    yt-dlp

    # ── Dev tools ──
    lazygit
    gh
    neovim
    helix
    gnumake
    cmake

    # ── Productivity ──
    zathura

    # ── Wayland / Sway tools ──
    grim          # screenshot
    slurp         # area select
    swappy        # screenshot edit
    wl-clipboard
    wf-recorder   # screen record
    wlsunset      # night light
    libnotify     # notify-send
    cliphist      # clipboard history
    bluetui       # bluetooth TUI

    # ── Fonts ──
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    noto-fonts
    noto-fonts-color-emoji
    # DankMono Nerd Font: manually installed to ~/.local/share/fonts/
  ];

  # ── XDG MIME defaults ──
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "video/mp4" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "audio/mpeg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
    };
  };
}

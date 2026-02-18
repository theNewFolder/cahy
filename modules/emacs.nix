{ config, pkgs, ... }:

{
  # Emacs daemon + productivity setup

  home.packages = with pkgs; [
    emacs
    # Emacs-specific deps (ripgrep/fd in apps.nix)
    sqlite        # org-roam
    graphviz      # org-roam-ui graph
    aspell        # spell check
    aspellDicts.en
    poppler-utils # PDF tools
  ];

  # Emacs daemon as systemd service
  services.emacs = {
    enable = true;
    defaultEditor = false;
    startWithUserSession = "graphical";
  };

  # Shell aliases for emacsclient
  programs.zsh.shellAliases = {
    e = "emacsclient -c -a emacs";
    et = "emacsclient -t -a emacs";
    magit = "emacsclient -c -e '(magit-status)' -a emacs";
    org-agenda = "emacsclient -c -e '(org-agenda nil \"d\")' -a emacs";
    org-capture = "emacsclient -c -e '(org-capture)' -a emacs";
    org-roam = "emacsclient -c -e '(org-roam-node-find)' -a emacs";
  };

  # Org directory structure
  home.activation.orgDirs = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/org/{roam,archive,templates,attachments}
    for f in tasks notes journal ideas agenda inbox habits projects meetings; do
      touch $HOME/org/$f.org
    done
  '';

  # Org-protocol desktop entry for Firefox integration
  xdg.desktopEntries.org-protocol = {
    name = "Org Protocol";
    comment = "Handle org-protocol URLs for Emacs capture";
    exec = "emacsclient %u";
    type = "Application";
    terminal = false;
    categories = [ "System" ];
    mimeType = [ "x-scheme-handler/org-protocol" ];
    noDisplay = true;
  };

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/org-protocol" = "org-protocol.desktop";
  };

  # Session variables set in home.nix to avoid conflicts
}

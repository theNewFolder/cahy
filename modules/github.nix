{ config, pkgs, ... }:

{
  # GitHub integration

  home.packages = with pkgs; [
    # gh and lazygit in apps.nix
    git-lfs
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "theNewFolder";
        email = "theNewFolder@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "emacsclient -t";
      color.ui = "auto";
      credential.helper = "store";

      # Delta for beautiful diffs
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "gruvbox-dark";
      };

      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        di = "diff";
        dc = "diff --cached";
        aa = "add --all";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };
    ignores = [ "*~" "*.swp" ".DS_Store" ".env" ".direnv" "result" ];
  };

  # GitHub CLI completion
  programs.zsh.initContent = ''
    # gh completion
    command -v gh &>/dev/null && eval "$(gh completion -s zsh)"
  '';
}

{ config, pkgs, ... }:

{
  # AI tools setup - Claude Code, Gemini CLI, helper scripts

  home.packages = with pkgs; [
    # Node.js runtime (needed for claude-code and gemini-cli)
    nodejs_22
  ];

  # AI helper scripts managed by home-manager
  home.file.".local/bin/ai-commit" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # AI-powered commit message generator using gemini
      set -euo pipefail
      DIFF=$(git diff --staged)
      if [ -z "$DIFF" ]; then
          echo "No staged changes. Stage files first with: git add <files>"
          exit 1
      fi
      echo "$DIFF" | gemini "Generate a concise git commit message for these changes. Format: type(scope): description. Types: feat, fix, refactor, docs, chore, style, test. One line only, no quotes."
    '';
  };

  home.file.".local/bin/ai-review" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # AI-powered code review using gemini
      set -euo pipefail
      if [ $# -gt 0 ]; then
          INPUT=$(cat "$@")
      else
          INPUT=$(git diff)
      fi
      if [ -z "$INPUT" ]; then
          echo "No diff to review. Pass files or have unstaged changes."
          exit 1
      fi
      echo "$INPUT" | gemini "Review this code diff for bugs, security issues, performance problems, and style improvements. Be concise and actionable."
    '';
  };

  home.file.".local/bin/ai-explain" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # AI-powered code/command explainer
      set -euo pipefail
      if [ $# -gt 0 ]; then
          INPUT="$*"
      else
          INPUT=$(cat)
      fi
      echo "$INPUT" | gemini "Explain this clearly and concisely. If it's code, explain what it does and why. If it's a command, explain each flag."
    '';
  };

  home.file.".local/bin/ai-fix" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # AI-powered code fixer
      set -euo pipefail
      if [ $# -gt 0 ]; then
          INPUT=$(cat "$@")
      else
          INPUT=$(cat)
      fi
      echo "$INPUT" | gemini "Find and fix issues in this code. Show the corrected version with brief comments explaining each fix."
    '';
  };

  home.file.".local/bin/ai-summarize" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # AI-powered text/file summarizer
      set -euo pipefail
      if [ $# -gt 0 ]; then
          INPUT=$(cat "$@")
      else
          INPUT=$(cat)
      fi
      echo "$INPUT" | gemini "Summarize this concisely. Keep key points, remove fluff. Use bullet points for long content."
    '';
  };

  home.file.".local/bin/ai-test" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # AI-powered test generator
      set -euo pipefail
      if [ $# -gt 0 ]; then
          INPUT=$(cat "$@")
      else
          INPUT=$(cat)
      fi
      echo "$INPUT" | gemini "Generate unit tests for this code. Use the appropriate testing framework for the language. Include edge cases."
    '';
  };

  # Shell integration - AI aliases and PATH setup
  programs.zsh.shellAliases = {
    aic = "ai-commit";
    air = "ai-review";
    aie = "ai-explain";
    aif = "ai-fix";
    ais = "ai-summarize";
    ait = "ai-test";
    "ai?" = "gemini";
    claude = "claude";
  };

  # fnm + npm global tools PATH setup
  programs.zsh.initContent = ''
    # fnm (Fast Node Manager) setup
    if [[ -f "$HOME/.local/share/fnm/fnm" ]]; then
      export PATH="$HOME/.local/share/fnm:$PATH"
      eval "$($HOME/.local/share/fnm/fnm env --use-on-cd)"
    fi

    # npm global bin
    export PATH="$HOME/.local/share/fnm/aliases/default/bin:$PATH"
  '';

  # Sway keybindings for AI (sourced by sway config)
  xdg.configFile."sway/ai-keybinds".text = ''
    # AI tool keybindings for Sway
    # $mod+i = Gemini chat in floating terminal
    # $mod+Shift+i = Claude Code in floating terminal
    # These are included by the main sway config
  '';
}

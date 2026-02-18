{ config, pkgs, ... }:

{
  # Firefox - Gruvbox ultra-minimal, vertical tabs, keyboard-driven, Emacs-integrated
  # NOTE: Firefox profile configs (user.js, userChrome.css) are deployed by install.sh
  # which auto-detects the profile directory after first Firefox launch.

  home.packages = with pkgs; [
    tridactyl-native  # Native messenger for Tridactyl extension
  ];

  # Tridactyl config
  xdg.configFile."tridactyl/tridactylrc".text = ''
    " Tridactyl config - Gruvbox + Vim workflow

    " Reset
    sanitise tridactyllocal tridactylsync

    " Theme
    colorscheme dark

    " General
    set smoothscroll true
    set newtab about:blank
    set editorcmd foot -a floating emacsclient -t %f

    " Hints
    set hintchars hjklasdfgyuiopqwertnmzxcvb
    set hintfiltermode vimperator-reflow
    set hintdelay 100

    " Search engines
    set searchurls.g https://www.google.com/search?q=%s
    set searchurls.gh https://github.com/search?q=%s
    set searchurls.w https://en.wikipedia.org/wiki/Special:Search/%s
    set searchurls.yt https://www.youtube.com/results?search_query=%s
    set searchurls.nix https://search.nixos.org/packages?query=%s
    set searchurls.r https://www.reddit.com/search/?q=%s
    set searchurls.mdn https://developer.mozilla.org/en-US/search?q=%s

    " Navigation
    bind j scrollline 5
    bind k scrollline -5
    bind J tabnext
    bind K tabprev
    bind d tabclose
    bind u undo
    bind gi focusinput -l
    bind gd tabdetach
    bind gD composite tabduplicate; tabdetach

    " Open/follow
    bind O fillcmdline open
    bind t fillcmdline tabopen
    bind T current_url tabopen
    bind yy clipboard yank
    bind p clipboard open
    bind P clipboard tabopen

    " Bookmarks
    bind B fillcmdline bmarks -t

    " Org-protocol capture from Firefox to Emacs
    command org-capture composite get_current_url | js -p tri.excmds.open("org-protocol:///capture?template=w&url=" + encodeURIComponent(document.location.href) + "&title=" + encodeURIComponent(document.title))
    bind ,c org-capture

    " Disable on sites that need keyboard
    autocmd DocStart mail.google.com mode ignore
    autocmd DocStart calendar.google.com mode ignore
    autocmd DocStart docs.google.com mode ignore
    autocmd DocStart meet.google.com mode ignore
    autocmd DocStart discord.com mode ignore
    autocmd DocStart monkeytype.com mode ignore

    " vim: set filetype=tridactyl
  '';

  # Firefox profile configs stored as XDG files — install.sh deploys them to the active profile
  xdg.configFile."firefox/user.js".text = ''
    // Firefox Performance + Privacy tweaks for Wayland/Intel UHD 620

    // ===== Enable userChrome.css =====
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

    // ===== Vertical Tabs + Sidebar =====
    user_pref("sidebar.revamp", true);
    user_pref("sidebar.verticalTabs", true);
    user_pref("sidebar.visibility", "hide-sidebar");

    // ===== Wayland + Hardware Acceleration =====
    user_pref("gfx.webrender.all", true);
    user_pref("media.ffmpeg.vaapi.enabled", true);
    user_pref("media.hardware-video-decoding.enabled", true);
    user_pref("widget.dmabuf.force-enabled", true);
    user_pref("media.av1.enabled", false); // Intel UHD 620 has no AV1 decode

    // ===== Performance =====
    user_pref("browser.cache.disk.enable", true);
    user_pref("browser.cache.memory.capacity", 524288); // 512MB
    user_pref("network.http.max-persistent-connections-per-server", 10);
    user_pref("network.dns.disablePrefetch", false);
    user_pref("network.prefetch-next", true);
    user_pref("content.notify.interval", 100000);
    user_pref("browser.sessionstore.interval", 60000);

    // ===== Privacy (moderate - don't break sites) =====
    user_pref("privacy.trackingprotection.enabled", true);
    user_pref("privacy.trackingprotection.socialtracking.enabled", true);
    user_pref("dom.security.https_only_mode", true);
    user_pref("network.cookie.cookieBehavior", 5); // Total cookie protection
    user_pref("privacy.resistFingerprinting", false);

    // ===== UI Ultra Minimal =====
    user_pref("browser.tabs.inTitlebar", 0);
    user_pref("browser.compactmode.show", true);
    user_pref("browser.uidensity", 1); // Compact
    user_pref("browser.theme.content-theme", 0); // Dark
    user_pref("browser.theme.toolbar-theme", 0); // Dark
    user_pref("extensions.pocket.enabled", false);
    user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
    user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
    user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
    user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
    user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
    user_pref("browser.aboutConfig.showWarning", false);
    user_pref("browser.download.autohideButton", true);

    // ===== Keyboard/Tridactyl friendly =====
    user_pref("browser.ctrlTab.recentlyUsedOrder", false);
    user_pref("accessibility.typeaheadfind.flashBar", 0);

    // ===== Font rendering =====
    user_pref("gfx.text.subpixel-position.force-enabled", true);
    user_pref("font.name.monospace.x-western", "DankMono Nerd Font");
  '';

  xdg.configFile."firefox/userChrome.css".text = ''
    /* ============================================================
       Gruvbox Ultra-Minimal Firefox
       - Native vertical tabs (sidebar)
       - Auto-hide everything
       - Keyboard-driven (Tridactyl)
       ============================================================ */

    :root {
      --gruvbox-bg: #1d2021;
      --gruvbox-bg1: #282828;
      --gruvbox-bg2: #3c3836;
      --gruvbox-bg3: #504945;
      --gruvbox-fg: #fbf1c7;
      --gruvbox-fg2: #d5c4a1;
      --gruvbox-fg3: #bdae93;
      --gruvbox-fg4: #a09080;
      --gruvbox-yellow: #fabd2f;
      --gruvbox-orange: #fe8019;
      --gruvbox-red: #fb4934;
      --gruvbox-green: #b8bb26;
      --gruvbox-aqua: #8ec07c;
      --gruvbox-blue: #83a598;
      --gruvbox-purple: #d3869b;

      scrollbar-color: var(--gruvbox-bg3) var(--gruvbox-bg) !important;
      scrollbar-width: thin !important;
    }

    /* ===== Hide horizontal tab bar (using vertical tabs) ===== */
    #TabsToolbar {
      visibility: collapse !important;
    }

    /* ===== Sidebar (vertical tabs) - Gruvbox themed ===== */
    #sidebar-box {
      background: var(--gruvbox-bg) !important;
      border-right: 1px solid var(--gruvbox-bg2) !important;
      min-width: 0 !important;
    }

    #sidebar-header {
      display: none !important;
    }

    #sidebar-splitter {
      width: 1px !important;
      border: none !important;
      background: var(--gruvbox-bg2) !important;
    }

    #sidebar {
      background: var(--gruvbox-bg) !important;
    }

    /* ===== Nav bar - ultra minimal ===== */
    #nav-bar {
      background: var(--gruvbox-bg) !important;
      border: none !important;
      padding: 2px 4px !important;
    }

    /* Auto-hide nav bar */
    #nav-bar {
      transform: rotateX(90deg);
      transform-origin: top;
      transition: transform 0.15s ease-in-out, opacity 0.15s ease-in-out !important;
      opacity: 0;
      z-index: 2;
    }

    #navigator-toolbox:hover > #nav-bar,
    #nav-bar:focus-within {
      transform: rotateX(0);
      opacity: 1;
    }

    /* ===== URL bar ===== */
    #urlbar-background {
      background: var(--gruvbox-bg1) !important;
      border: 1px solid var(--gruvbox-bg3) !important;
      border-radius: 6px !important;
    }

    #urlbar:not([focused]) #urlbar-background {
      background: var(--gruvbox-bg) !important;
      border-color: var(--gruvbox-bg2) !important;
    }

    #urlbar[focused] #urlbar-background {
      border-color: var(--gruvbox-yellow) !important;
      box-shadow: 0 0 4px rgba(250, 189, 47, 0.15) !important;
    }

    #urlbar-input {
      color: var(--gruvbox-fg) !important;
      font-family: "DankMono Nerd Font", monospace !important;
      font-size: 13px !important;
    }

    /* Hide clutter */
    #tracking-protection-icon-container,
    #pageActionSeparator,
    #pageActionButton,
    #pocket-button,
    #reader-mode-button,
    #star-button-box,
    #fullscr-toggler,
    .titlebar-spacer,
    #identity-icon-box:not(:hover) #identity-icon-label {
      display: none !important;
    }

    /* Prevent URL bar popup enlargement */
    #urlbar[breakout][breakout-extend] {
      top: 5px !important;
      left: 0px !important;
      width: 100% !important;
      padding: 0px !important;
    }

    #urlbar[breakout][breakout-extend] > #urlbar-input-container {
      height: var(--urlbar-height) !important;
      padding: 0 !important;
    }

    #urlbar[breakout][breakout-extend] > #urlbar-background {
      animation: none !important;
      box-shadow: none !important;
    }

    /* ===== Navigator toolbox ===== */
    #navigator-toolbox {
      border-bottom: none !important;
    }

    /* ===== Context menus ===== */
    menupopup {
      --panel-background: var(--gruvbox-bg1) !important;
      --panel-color: var(--gruvbox-fg) !important;
      --panel-border-color: var(--gruvbox-bg3) !important;
    }

    /* ===== Findbar ===== */
    .findbar-container {
      background: var(--gruvbox-bg1) !important;
      color: var(--gruvbox-fg) !important;
    }

    .findbar-textbox {
      background: var(--gruvbox-bg) !important;
      color: var(--gruvbox-fg) !important;
      border: 1px solid var(--gruvbox-bg3) !important;
    }

    /* ===== Autocomplete / URL suggestions ===== */
    .urlbarView {
      background: var(--gruvbox-bg1) !important;
      color: var(--gruvbox-fg) !important;
    }

    .urlbarView-row:hover,
    .urlbarView-row[selected] {
      background: var(--gruvbox-bg2) !important;
    }

    .urlbarView-url {
      color: var(--gruvbox-blue) !important;
    }

    .urlbarView-title {
      color: var(--gruvbox-fg2) !important;
    }
  '';

  xdg.configFile."firefox/userContent.css".text = ''
    @-moz-document url("about:blank"), url("about:newtab"), url("about:home") {
      body, #newtab-customize-overlay {
        background-color: #1d2021 !important;
        color: #fbf1c7 !important;
      }
    }

    @-moz-document url-prefix("about:") {
      :root {
        --in-content-page-background: #1d2021 !important;
        --in-content-page-color: #fbf1c7 !important;
      }
    }
  '';
}

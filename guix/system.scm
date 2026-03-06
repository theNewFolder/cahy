;; Guix System Configuration — Samsung 990 PRO 2TB
;; Hardware: ASUS TUF A15, Ryzen 7 7435HS, RTX 3050, 16GB DDR5
;;
;; Usage: guix system reconfigure ~/cahy/guix/system.scm

(define-module (system)
  #:use-module (gnu)
  #:use-module (gnu system nss)
  #:use-module (gnu system setuid)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages nvidia)
  #:use-module (nongnu packages mozilla)
  #:use-module (nongnu system linux-initrd))

(use-service-modules desktop networking ssh xorg pm mcron)
(use-package-modules emacs gnome linux node shells wm freedesktop file-systems)

(operating-system
  ;; ── Kernel (nonguix for NVIDIA) ──
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (kernel-loadable-modules (list nvidia-module))

  ;; Blacklist nouveau, NVIDIA suspend/resume, enable power management
  (kernel-arguments
   (append '("modprobe.blacklist=nouveau"
             "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
             "nvidia.NVreg_DynamicPowerManagement=0x02")
           %default-kernel-arguments))

  ;; ── Locale ──
  (locale "en_US.utf8")
  (timezone "Asia/Dubai")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "guix-tuf")

  ;; ── User ──
  (users (cons* (user-account
                 (name "dev")
                 (comment "Developer")
                 (group "users")
                 (home-directory "/home/dev")
                 (shell (file-append zsh "/bin/zsh"))
                 (supplementary-groups
                  '("wheel" "netdev" "audio" "video" "input" "kvm")))
                %base-user-accounts))

  ;; ── System packages (minimal — user packages in Guix Home) ──
  (packages
   (append
    (list
     hyprland
     emacs-next-pgtk
     zsh git curl wget
     node                               ;Claude Code + MCP servers
     nvidia-driver
     xdg-utils
     xdg-desktop-portal
     xdg-desktop-portal-hyprland
     snapper                            ;btrfs snapshot management (needs root)
     firefox)                           ;Firefox from nonguix (nonfree)
    %base-packages))

  ;; ── Services ──
  (services
   (append
    (list
     ;; NVIDIA driver + module loading
     (service nvidia-service-type)
     (service kernel-module-loader-service-type
              '("nvidia" "nvidia_modeset" "nvidia_uvm"))

     ;; NVIDIA suspend/resume (RTX 3050 laptop fix)
     (simple-service 'nvidia-suspend
                     shepherd-root-service-type
                     (list (shepherd-service
                            (provision '(nvidia-suspend))
                            (requirement '())
                            (one-shot? #t)
                            (start #~(lambda _
                                       (invoke "/run/current-system/profile/bin/nvidia-sleep.sh"
                                               "suspend")))
                            (documentation "NVIDIA suspend handler."))
                           (shepherd-service
                            (provision '(nvidia-resume))
                            (requirement '())
                            (one-shot? #t)
                            (start #~(lambda _
                                       (invoke "/run/current-system/profile/bin/nvidia-sleep.sh"
                                               "resume")))
                            (documentation "NVIDIA resume handler."))))

     ;; greetd + tuigreet (replaces GDM)
     (service greetd-service-type
              (greetd-configuration
               (greeter-supplementary-groups '("video" "input"))
               (terminals
                (list
                 (greetd-terminal-configuration
                  (terminal-vt "1")
                  (terminal-switch #t)
                  (default-session-command
                    (greetd-tuigreet-session
                     (command (file-append hyprland "/bin/Hyprland")))))
                 ;; Fallback TTY on vt2
                 (greetd-terminal-configuration
                  (terminal-vt "2"))))))

     ;; Networking
     (service network-manager-service-type)
     (service wpa-supplicant-service-type)

     ;; SSH
     (service openssh-service-type)

     ;; Power management (TLP for laptop battery/thermals)
     (service tlp-service-type
              (tlp-configuration
               (cpu-scaling-governor-on-ac (list "performance"))
               (cpu-scaling-governor-on-bat (list "powersave"))
               (cpu-boost-on-ac? #t)
               (cpu-boost-on-bat? #f)))

     ;; Mcron — system maintenance
     (service mcron-service-type
              (mcron-configuration
               (jobs (list
                      ;; Weekly: keep only last 5 system generations (Sunday 4am)
                      #~(job '(next-day-from (next-hour '(4)) 0)
                             (string-append #$guix "/bin/guix system delete-generations 5d")
                             "system-gen-cleanup")))))

     ;; Substitute servers + guix.moe mirrors
     (modify-services %base-services
       (guix-service-type
        config => (guix-configuration
                   (inherit config)
                   (substitute-urls
                    '("https://bordeaux.guix.gnu.org"
                      "https://ci.guix.gnu.org"
                      "https://substitutes.nonguix.org"
                      "https://cache-us-lax.guix.moe"
                      "https://cache-sg.guix.moe"))
                   (extra-options '("--max-jobs=4"
                                    "--cores=8"))
                   (authorized-keys
                    (append
                     (list (plain-file "nonguix.pub"
                             "(public-key
                               (ecc
                                (curve Ed25519)
                                (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                     %default-authorized-guix-keys))))))
    ;; Desktop services WITHOUT GDM (greetd replaces it)
    (modify-services %desktop-services
      (delete gdm-service-type))))

  ;; ── Bootloader (UEFI) ──
  (bootloader
   (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (targets (list "/boot/efi"))
    (keyboard-layout keyboard-layout)))

  ;; ── File systems — Samsung 990 PRO 2TB (nvme1n1) ──
  ;; Btrfs subvolumes: @, @home, @gnu, @log, @tmp
  ;; TODO: Update UUIDs after partitioning
  (file-systems
   (cons* (file-system
            (mount-point "/")
            (device (file-system-label "guix-root"))
            (type "btrfs")
            (options "subvol=@,compress=zstd:1,noatime,space_cache=v2"))
          (file-system
            (mount-point "/home")
            (device (file-system-label "guix-root"))
            (type "btrfs")
            (options "subvol=@home,compress=zstd:1,noatime,space_cache=v2"))
          (file-system
            (mount-point "/gnu/store")
            (device (file-system-label "guix-root"))
            (type "btrfs")
            (options "subvol=@gnu,compress-force=zstd:3,noatime,space_cache=v2")
            (needed-for-boot? #t))
          (file-system
            (mount-point "/var/log")
            (device (file-system-label "guix-root"))
            (type "btrfs")
            (options "subvol=@log,compress=zstd:3,noatime,space_cache=v2"))
          (file-system
            (mount-point "/tmp")
            (device (file-system-label "guix-root"))
            (type "btrfs")
            (options "subvol=@tmp,compress=zstd:1,noatime,space_cache=v2"))
          (file-system
            (mount-point "/boot/efi")
            (device (file-system-label "GUIX-EFI"))
            (type "vfat"))
          %base-file-systems)))

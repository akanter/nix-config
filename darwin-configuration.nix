{ config, pkgs, ... }:
let
  powerlevel10k = pkgs.fetchFromGitHub {
    owner = "romkatv";
    repo = "powerlevel10k";
    rev = "f07d7baea36010bfa74708844d404517ea6ac473";
    # to update: nix-prefetch-url --unpack https://github.com/romkatv/powerlevel10k/archive/f07d7baea36010bfa74708844d404517ea6ac473.tar.gz
    sha256 = "0208437mx12rnqwdmw3r9n5w6n8zq1h3y7h1nm8yr92acnxq8rz5";
  };
in {
  imports = [ ./home-manager/nix-darwin ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.black
    pkgs.emacs
    pkgs.eternal-terminal
    pkgs.gitAndTools.gitFull
    pkgs.lftp
    pkgs.nixfmt
    pkgs.nix-prefetch
    pkgs.poetry
  ];

  programs.tmux.enable = true;

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  users = {
    users.ak = {
      home = "/Users/ak";
      shell = pkgs.zsh;
    };
  };

  homebrew = {
    enable = true;
    autoUpdate = true;
    cleanup = "zap";
    taps = [ "homebrew/cask" ];
    casks = [
      "brave-browser"
      "clipy"
      "disk-inventory-x"
      "dropbox"
      "flux"
      "iina"
      "iterm2"
      "keepassxc"
      "keka"
      "messenger"
      "nextcloud"
      "pycharm-ce"
      "rectangle"
      "signal"
      "slack"
      "sublime-text"
      "subsurface"
      "swinsian"
      "time-out"
      "whatsapp"
      "xld"
      "zoom"
    ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
  };

  nix.trustedUsers = [ "ak" "@admin" ];

  services.emacs = {
    enable = true;
    package = config.home-manager.users.ak.programs.emacs.finalPackage;
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  programs.bash.enable = false;
  environment.shells = with pkgs; [ zsh ];

  home-manager = {
    useGlobalPkgs = true;
    users.ak = { pkgs, lib, ... }: {
      programs.home-manager.enable = true;
      programs.emacs = {
        enable = true;
        extraPackages = epkgs: [
          epkgs.ace-jump-mode
          epkgs.magit
          epkgs.magit-imerge
          epkgs.nix-mode
          epkgs.nixos-options
        ];
        extraConfig = ''
          (define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
        '';
      };
      programs.zsh = {
        enable = true;
        history.size = 50000;
        shellAliases = {
          bd = "${pkgs.black}/bin/blackd > /dev/null 2>&1 &";
          ec = "${pkgs.emacs}/bin/emacsclient -ct";
          g = "${pkgs.git}/bin/git";
          gco = "g checkout";
          la = "ls -la";
        };
        prezto = {
          enable = true;
          prompt.theme = "powerlevel10k";
          tmux.itermIntegration = true;
        };
        plugins = [{
          name = "powerlevel10k";
          src = powerlevel10k;
        }];
      };
      home.file = {
        ".p10k.zsh".source = "${./conf/.p10k.zsh}";
        ".lftprc".source = "${./conf/.lftprc}";
      };
      home.activation.setCocoaKeybindings =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          $VERBOSE_ECHO "Configuring keybindings for the Cocoa Text System"
          $DRY_RUN_CMD install -Dm644 $VERBOSE_ARG \
             "${
               ./conf/DefaultKeyBinding.dict
             }" "${config.users.users.ak.home}/Library/KeyBindings/DefaultKeyBinding.dict"
        '';
      home.sessionVariables = {
        EDITOR = "${pkgs.emacs}/bin/emacsclient -ct";
        VISUAL = "$EDITOR";
      };
      programs.git = {
        enable = true;
        package = pkgs.gitFull;
        userName = "Aaron Kanter";
        userEmail = "alkanter@gmail.com";
        aliases = {
          br = "branch";
          ca = "commit --amend";
          co = "checkout";
          cp = "cherry-pick";
          ds = "diff --stat";
          ri = "rebase --interactive";
          sl =
            "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --all";
          sl2 =
            "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
          ss = "show --stat";
          st = "status";
        };
        ignores = [ "#*#" "*~" ".idea" ];
        extraConfig = {
          core.editor = "$EDITOR";
          merge = {
            conflictstyle = "diff3";
            stat = true;
          };
          push.default = "current";
        };
      };
      programs.ssh = {
        enable = true;
        matchBlocks = {
          alkanter_gmail = {
            host = "*";
            identityFile = "~/.ssh/id_rsa";
            extraOptions = {
              UseKeychain = "yes";
              AddKeysToAgent = "yes";
              IgnoreUnknown = "UseKeychain";
            };
          };
        };
      };
    };
  };

  system = {
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;
    defaults = {
      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        AppleInterfaceStyle = "Dark";
        _HIHideMenuBar = false;
        # "com.apple.keyboard.fnState" = true;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = "0.0";
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.swipescrolldirection" = false;
      };

      ".GlobalPreferences" = {
        "com.apple.sound.beep.sound" = "/System/Library/Sounds/Funk.aiff";
      };

      dock = {
        autohide = true;
        launchanim = false;
        orientation = "bottom";
      };

      trackpad = { Clicking = true; };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
  fonts = {
    enableFontDir = true;
    fonts = [ pkgs.meslo-lgs-nf ];
  };
}

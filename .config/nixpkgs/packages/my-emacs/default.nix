{ pkgs, fetchFromGitHub, writeText, ... }:

let

  emacsConfig = pkgs.runCommand "README.emacs-conf.org" {
    buildInputs = with pkgs; [ emacs ];
  } ''
     install -D ${./README.org} $out/share/emacs/site-lisp/README.org
     cd $out/share/emacs/site-lisp
     emacs --batch --quick -l ob-tangle --eval "(org-babel-tangle-file \"README.org\")"
  '';

  emacsPackages =
    pkgs.emacsPackagesNg.overrideScope
    (self: super: {
      inherit (self.melpaPackages)
        evil flycheck-haskell haskell-mode
        use-package;
    });

  ## use up-to-date nix-mode
  nix-mode = emacsPackages.melpaBuild {
    pname = "nix-mode";
    version = "20180630";

    src = fetchFromGitHub {
      owner = "NixOS";
      repo = "nix-mode";
      rev = "57ac40d53b4f4fe0d61fcabb41f8f3992384048e";
      sha256 = "0l5m5p3rsrjf7ghik3z1bglf255cwliglgr3hiv6qpp121k4p0ga";
    };

    recipeFile = writeText "nix-mode-recipe" ''
      (nix-mode :repo "NixOS/nix-mode" :fetcher github
                :files (:defaults (:exclude "nix-mode-mmm.el")))
    '';
  };

  prescientSource = fetchFromGitHub {
    owner  = "raxod502";
    repo   = "prescient.el";
    rev    = "27c94636489d5b062970a0f7e9041ca186b6b659";
    sha256 = "05jk8cms48dhpbaimmx3akmnq32fgbc0q4dja7lvpvssmq398cn7";
  };

  prescient = emacsPackages.melpaBuild {
    pname   = "prescient";
    version = "1.0";
    src     = prescientSource;

    recipeFile = writeText "prescient-recipe" ''
      (prescient :files ("prescient.el"))
    '';
  };

  ivy-prescient = emacsPackages.melpaBuild {
    pname   = "ivy-prescient";
    version = "1.0";
    src     = prescientSource;
    packageRequires = [ prescient ];

    recipeFile = writeText "ivy-prescient-recipe" ''
      (ivy-prescient :files ("ivy-prescient.el"))
    '';
  };

  company-prescient = emacsPackages.melpaBuild {
    pname   = "company-prescient";
    version = "1.0";
    src     = prescientSource;
    packageRequires = [ prescient ];

    recipeFile = writeText "company-prescient-recipe" ''
      (company-prescient :files ("company-prescient.el"))
    '';
  };

in

  emacsPackages.emacsWithPackages (epkgs: with epkgs; [
    use-package

    # Interface
    bind-key
    company
    ivy counsel swiper
    projectile  # project management
    counsel-projectile
    ripgrep  # search
    which-key  # display keybindings after incomplete command

    # sorting and filtering
    prescient
    ivy-prescient
    company-prescient

    # Themes
    diminish
    all-the-icons
    powerline
    spaceline
    spaceline-all-the-icons
    zerodark-theme

    # Delimiters
    smartparens
    linum-relative
    fringe-helper

    highlight-numbers

    # Evil
    avy
    evil
    evil-org ## or syndicate?
    evil-magit
    evil-indent-textobject
    evil-nerd-commenter
    ## evil-cleverparens ## use lispyville / lispy instead?

    undo-tree
    frames-only-mode
    zoom-window

    # Git
    # git-auto-commit-mode
    # git-timemachine
    magit
    diff-hl

    # Helpers
    direnv

    # Language support
    moonscript
    lua-mode
    json-mode
    yaml-mode
    markdown-mode

    company-quickhelp

    # Go
    go-mode
    company-go
    go-guru
    go-eldoc
    flycheck-gometalinter
    ob-go

    flycheck-checkbashisms

    auto-compile
    flycheck
    flycheck-popup-tip
    flycheck-pos-tip

    string-inflection

    markdown-mode
    yaml-mode
    web-mode
    pos-tip
    dockerfile-mode
    scala-mode
    js2-mode

    # Haskell
    haskell-mode
    flycheck-haskell
    company-ghci  # provide completions from inferior ghci

    # Org
    org org-ref evil-org org-bullets

    # Rust
    rust-mode cargo flycheck-rust

    # Nix
    nix-buffer nixos-options company-nixos-options nix-sandbox

    # config file
    emacsConfig
  ] ++

  # Custom packages
  [ nix-mode prescient ivy-prescient company-prescient ]
)

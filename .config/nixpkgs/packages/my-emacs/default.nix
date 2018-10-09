{ pkgs, fetchFromGitHub, git, writeText, ... }:

let

  emacsConfig = pkgs.runCommand "README.emacs-conf.org" {
    buildInputs = with pkgs; [ emacs ];
  } ''
     install -D ${./README.org} $out/share/emacs/site-lisp/README.org
     cd $out/share/emacs/site-lisp
     emacs --batch --quick -l ob-tangle --eval "(org-babel-tangle-file \"README.org\")"
  '';

  emacsPackages =
    pkgs.emacsPackagesNg.overrideScope'
    (self: super: {
      inherit (self.melpaPackages)
        evil flycheck-haskell haskell-mode
        use-package;
    });

  ## searches for git at build time and atm this isn't reflected in nixpkgs
  evil-magit = pkgs.emacsPackagesNg.evil-magit.overrideAttrs (
    attrs: {
    nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [ git ];
    }
  );

  ## use up-to-date nix-mode
  nix-mode = emacsPackages.melpaBuild {
    pname = "nix-mode";
    version = "20180801";

    src = fetchFromGitHub {
      owner = "NixOS";
      repo = "nix-mode";
      rev = "fbcbc446f84bbfdafac0d6f37df5918cab2e4610";
      sha256 = "1yhga5rgbc9aqnbqq7rbdv8ycbw8jk40l2m04p5d1065q8icpaka";
    };

    recipe = writeText "nix-mode-recipe" ''
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

    recipe = writeText "prescient-recipe" ''
      (prescient :repo "raxod502/prescient.el" :fetcher github
                 :files ("prescient.el"))
    '';
  };

  ivy-prescient = emacsPackages.melpaBuild {
    pname   = "ivy-prescient";
    version = "1.0";
    src     = prescientSource;
    packageRequires = [ prescient ];

    recipe = writeText "ivy-prescient-recipe" ''
      (ivy-prescient :repo "raxod502/prescient.el" :fetcher github
                     :files ("ivy-prescient.el"))
    '';
  };

  company-prescient = emacsPackages.melpaBuild {
    pname   = "company-prescient";
    version = "1.0";
    src     = prescientSource;
    packageRequires = [ prescient ];

    recipe = writeText "company-prescient-recipe" ''
      (company-prescient  :repo "raxod502/prescient.el" :fetcher github
                         :files ("company-prescient.el"))
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
    telephone-line
    spaceline
    spaceline-all-the-icons
    zerodark-theme
    nord-theme

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
    groovy-mode
    alchemist # elixir

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
    ensime
    scala-mode
    sbt-mode
    js2-mode

    # Haskell
    haskell-mode
    flycheck-haskell
    company-ghci  # provide completions from inferior ghci

    # Org
    org org-ref evil-org org-bullets
    org-tree-slide # presentations

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

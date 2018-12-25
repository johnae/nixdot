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

  ## use a nord-theme that works with 24-bit terminals
  nord-theme = emacsPackages.melpaBuild {
    pname = "nord-theme";
    version = "20181017";
    src = fetchFromGitHub {
      owner = "visigoth";
      repo = "nord-emacs";
      rev = "4f1cdf095a0c99c926fcf296dd6b4f8db1e4ee57";
      sha256 = "1p89n8wrzkwvqhrxpzr2fhy4hnw44mha8ydwjbxr3fpnc120q2qs";
    };

    recipe = writeText "nord-theme-recipe" ''
      (nord-theme :repo "visigoth/nord-theme.el" :fetcher github
                 :files (:defaults))
    '';
  };

  ## use up-to-date nix-mode
  nix-mode = emacsPackages.melpaBuild {
    pname = "nix-mode";
    version = "20181212";

    src = fetchFromGitHub {
      owner = "NixOS";
      repo = "nix-mode";
      rev = "1512d02830fe90dddd35c9b4bd83d0ee963de57b";
      sha256 = "1sn2077vmn71vwjvgs7a5prlp94kyds5x6dyspckxc78l2byb661";
    };

    recipe = writeText "nix-mode-recipe" ''
      (nix-mode :repo "NixOS/nix-mode" :fetcher github
                :files (:defaults (:exclude "nix-mode-mmm.el")))
    '';
  };

  prescientSource = fetchFromGitHub {
    owner  = "raxod502";
    repo   = "prescient.el";
    rev    = "1623a0d4e5b9a752db45923fd91da48b49c85068";
    sha256 = "0yan4m9xf4iia4ns8kqa0zsham4h2mcnwsq9xnfwm26rkn94xrw0";
  };

  prescient = emacsPackages.melpaBuild {
    pname   = "prescient";
    version = "2.2.1";
    src     = prescientSource;

    recipe = writeText "prescient-recipe" ''
      (prescient :repo "raxod502/prescient.el" :fetcher github
                 :files ("prescient.el"))
    '';
  };

  ivy-prescient = emacsPackages.melpaBuild {
    pname   = "ivy-prescient";
    version = "2.2.1";
    src     = prescientSource;
    packageRequires = [ prescient ];

    recipe = writeText "ivy-prescient-recipe" ''
      (ivy-prescient :repo "raxod502/prescient.el" :fetcher github
                     :files ("ivy-prescient.el"))
    '';
  };

  company-prescient = emacsPackages.melpaBuild {
    pname   = "company-prescient";
    version = "2.2.1";
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
    evil-surround
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
    terraform-mode

    company-quickhelp
    column-enforce-mode

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
    tide
    prettier-js

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
  [ nix-mode prescient ivy-prescient company-prescient nord-theme ]
)

{ pkgs, fetchFromGitHub, fetchgit, glibc, pandoc, isync, imapnotify, git, wl-clipboard, mu, writeText, ... }:

let

  emacsConfig = pkgs.runCommand "README.emacs-conf.org" {
    buildInputs = with pkgs; [ emacs ];
  } ''
     install -D ${./README.org} $out/share/emacs/site-lisp/README.org
     substituteInPlace "$out/share/emacs/site-lisp/README.org" \
                       --subst-var-by MUSE_LOAD_PATH \
                       "${mu}/share/emacs/site-lisp/mu4e" \
                       --subst-var-by MBSYNC \
                       "${isync}/bin/mbsync" \
                       --subst-var-by PANDOC \
                       "${pandoc}/bin/pandoc" \
                       --subst-var-by IMAPNOTIFY \
                       "${imapnotify}/bin/imapnotify" \
                       --subst-var-by WLCOPY \
                       "${wl-clipboard}/bin/wl-copy" \
                       --subst-var-by WLPASTE \
                       "${wl-clipboard}/bin/wl-paste"
     cd $out/share/emacs/site-lisp
     emacs --batch --quick -l ob-tangle --eval "(org-babel-tangle-file \"README.org\")"
     emacs -batch -f batch-byte-compile **/*.el
  '';

  emacsPackages =
    pkgs.emacsPackagesNg.overrideScope'
    (self: super: {
      inherit (self.melpaPackages)
        evil flycheck-haskell haskell-mode
        use-package;
    });

  compileEmacsFiles = pkgs.callPackage ./builder.nix;
  fetchFromEmacsWiki = pkgs.callPackage ({ fetchurl, name, sha256 }:
    fetchurl {
      inherit sha256;
      url = "https://www.emacswiki.org/emacs/download/" + name;
    });

  compileEmacsWikiFile = { name, sha256, buildInputs ? [], patches ? [] }:
    compileEmacsFiles {
      inherit name buildInputs patches;
      src = fetchFromEmacsWiki { inherit name sha256; };
  };

  jl-encrypt = emacsPackages.melpaBuild {
    pname = "jl-encrypt";
    version = "20190618";

    src = fetchgit {
      url = "https://gitlab.com/lechten/defaultencrypt.git";
      rev = "ba07acc8e9fd692534c39c7cdad0a19dc0d897d9";
      sha256 = "1ln7h1syx7yi7bqvirv90mk4rvwxg4zm1wvfcvhfh64s3hqrbfgl";
    };

    recipe = writeText "jl-encrypt-recipe" ''
      (jl-encrypt :fetcher git
                  :url "https://gitlab.com/lechten/defaultencrypt.git"
                  :files (:defaults))
    '';
  };

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

  ra-emacs-lsp = emacsPackages.melpaBuild {
    pname = "ra-emacs-lsp";
    version = "20190720";
    src = fetchFromGitHub {
      owner = "rust-analyzer";
      repo = "rust-analyzer";
      rev = "dc7cec8cf4badddb54be03cfa187567b436dd82a";
      sha256 = "086hnxy0yp08q4qmspavjh1v463cqlwj4kkgyscnhsj9vs6jlwz4";
    };

    recipe = writeText "ra-emacs-lsp-recipe" ''
      (ra-emacs-lsp :repo "rust-analyzer/rust-analyzer" :fetcher github
                 :files ("editors/emacs/ra-emacs-lsp.el"))
    '';
  };

  ## use up-to-date nix-mode
  nix-mode = emacsPackages.melpaBuild {
    pname = "nix-mode";
    version = "20190119";

    src = fetchFromGitHub {
      owner = "NixOS";
      repo = "nix-mode";
      rev = "1e53bed4d47c526c71113569f592c82845a17784";
      sha256 = "172s5lxlns633gbi6sq6iws269chalh5k501n3wffp5i3b2xzdyq";
    };

    recipe = writeText "nix-mode-recipe" ''
      (nix-mode :repo "NixOS/nix-mode" :fetcher github
                :files (:defaults (:exclude "nix-mode-mmm.el")))
    '';
  };

  prescientSource = fetchFromGitHub {
    owner  = "raxod502";
    repo   = "prescient.el";
    rev    = "5c23565eeb1c8fe7192578cb492ffdf1108ea6ed";
    sha256 = "0c6s6hwzkpzcwxzb656jz66jl88j0blr7zkc55lxn6brz7src55c";
  };

  prescient = emacsPackages.melpaBuild {
    pname   = "prescient";
    version = "3.0.0";
    src     = prescientSource;

    recipe = writeText "prescient-recipe" ''
      (prescient :repo "raxod502/prescient.el" :fetcher github
                 :files ("prescient.el"))
    '';
  };

  ivy-prescient = emacsPackages.melpaBuild {
    pname   = "ivy-prescient";
    version = "3.0.0";
    src     = prescientSource;
    packageRequires = [ prescient ];

    recipe = writeText "ivy-prescient-recipe" ''
      (ivy-prescient :repo "raxod502/prescient.el" :fetcher github
                     :files ("ivy-prescient.el"))
    '';
  };

  company-prescient = emacsPackages.melpaBuild {
    pname   = "company-prescient";
    version = "3.0.0";
    src     = prescientSource;
    packageRequires = [ prescient ];

    recipe = writeText "company-prescient-recipe" ''
      (company-prescient  :repo "raxod502/prescient.el" :fetcher github
                         :files ("company-prescient.el"))
    '';
  };


  lua-mode = emacsPackages.melpaBuild {
    pname = "lua-mode";
    version = "20190113";

    src = fetchFromGitHub {
      owner = "immerrr";
      repo = "lua-mode";
      rev = "95c64bb5634035630e8c59d10d4a1d1003265743";
      sha256 = "0cawb544qylifkvqads307n0nfqg7lvyphqbpbzr2xvr5iyi4901";
    };

    recipe = writeText "lua-mode-recipe" ''
      (lua-mode :repo "immerrr/lua-mode" :fetcher github
                :files ("lua-mode.el"))
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

    jl-encrypt

    prodigy # manage external services

    visual-fill-column

    #benchmark-init

    # Themes
    diminish
    all-the-icons
    powerline
    telephone-line
    spaceline
    spaceline-all-the-icons
    zerodark-theme
    eink-theme

    # Delimiters
    smartparens
    linum-relative
    fringe-helper

    highlight-numbers

    memoize

    # Evil
    avy
    evil
    evil-org
    evil-magit
    evil-indent-textobject
    evil-nerd-commenter
    evil-surround
    evil-collection

    alert
    mu4e-alert

    undo-tree
    frames-only-mode
    zoom-window

    # Git
    # git-auto-commit-mode
    # git-timemachine
    magit
    diff-hl

    swift-mode

    # Helpers
    direnv
    kubernetes-tramp
    docker-tramp
    counsel-tramp

    # Language support
    moonscript
    lua-mode
    json-mode
    yaml-mode
    markdown-mode
    groovy-mode
    alchemist # elixir
    terraform-mode
    company-terraform
    elvish-mode
    jsonnet-mode

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

    lsp-mode
    lsp-ui
    company-lsp

    racket-mode
    esh-autosuggest
    fish-completion # fish completion in eshell

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
    org
    org-ref
    org-bullets
    org-tree-slide # presentations
    org-wild-notifier # notifications for TODO:s

    # polymode allows more than 1 major mode in a buffer basically
    polymode
    poly-markdown
    poly-org

    # Rust
    rust-mode cargo flycheck-rust racer ra-emacs-lsp

    # Nix
    # nix-buffer nixos-options company-nixos-options nix-sandbox
    nixos-options company-nixos-options

    # config file
    emacsConfig
  ] ++

  # Custom packages
  [ nix-mode prescient ivy-prescient company-prescient nord-theme ]
)

# My NixOS / Nix dotfiles

These are the dotfiles I use on [NixOS](https://nixos.org). Please also see [nixos-config](https://github.com/johnae/nixos-config). That config is used to bootstrap the whole system while this repo is for my dotfiles and user packages. This includes some custom nix packages and a dotfiles builder based on nix.

Normally the procedure (after cloning and checking out this) is:

```sh
$ nix-env -iA nixos.home && home-update
```

or in fish that would be:
```fish
$ nix-env -iA nixos.home; and home-update
```

Please note that a `default.nix` is expected to be present in your home directory with some configuration:

```nix
{
  codecommitUser = "AABBCCDDEEFFGG";
  homeDomain = "the-domain-I-use-for-my-servers-at-home";
  hyperionIP = "some-ip-address";
  signingKey = "0x00FF00FF00FF00";
  fullName = "My Full Name";
  email = "email@example.com";
}⏎
```

Without the above nix will fail the install.


## Emacs

See [README.org](.config/nixpkgs/packages/my-emacs/README.org) for emacs configuration - handled through the [nix package manager](https:nixos.org). Emacs configuration is untangled from that org file. Install it like this:

`$ nix-env -iA nixos.my-emacs`

or if not on NixOS:

`$ nix-env -iA nixpkgs.my-emacs`


## Default packages

So even if above would give me my emacs with the packages and config I want, I prefer installing it through the "meta" package [default-packages](.config/nixpkgs/overlays/default-packages.nix) - like this:

`$ nix-env -iA nixos.default-packages`

or if not on nixos:

`$ nix-env -iA nixpkgs.default-packages`


## Dotfiles

While some "dotfiles" are clearly installed by just going through the procedure below, most of them are generated and kept up-to-date via nix and the command `home-update`. The general procedure would be something like:

```
$ nix-env -iA nixos.dotfiles
$ home-update
```

Since I have a more comprehensive package called "home" which includes the dotfiles, that is what I install instead of just the dotfiles really.

The above maintains a `.dotfiles_version` file and a `.dotfiles_manifest` file in the home directory. These are used for determining whether any update is necessary and what to potentially remove as files might be removed from the nix output. The actual dotfiles are copied rather than linked. It's a somewhat crude solution but works pretty well in practice and as long as `home-update` is installed (and run pretty much immediately after any changes caused by a `nix-env -iA nixos.home`) no dependencies should be garbage collected.


## Installation

The dotfiles keep a config for the fish shell as I've recently made the switch from zsh.

Git clone something like this:

```sh
$ git clone --bare https://github.com/johnae/nixdot.git ~/.cfg
$ cd ~
$ GIT_WORK_TREE=$HOME GIT_DIR=$HOME/.cfg git checkout
$ GIT_WORK_TREE=$HOME GIT_DIR=$HOME/.cfg git config --local status.showUntrackedFiles no
```

If there are any complaints like files already being there, this should help:

```sh
$ mkdir -p .cfg-backup && GIT_WORK_TREE=$HOME GIT_DIR=$HOME/.cfg git checkout 2>&1 | egrep "\s+\." | awk '{print $1}' | xargs -I{} mv {} .cfg-backup/{}
```

Above backs up any preexisting files to .cfg-backup. After all this, your home repo can be managed using:

```sh
$ home add
$ home pull
$ home push
```

Etc. It's just git with some special env vars for management. Ofc as mentioned nix is used for generating dotfiles etc so this should mostly just contain the nix expressions and perhaps some helpers.


## License

This code is released under the [MIT License](http://opensource.org/licenses/MIT)
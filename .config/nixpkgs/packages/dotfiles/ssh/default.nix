{stdenv, libdot, writeText, settings, ...}:

let

  config = writeText "ssh-config" ''
    Host *.compute.amazonaws.com
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null

    Host git-codecommit.*.amazonaws.com
      User ${settings.codecommitUser}
      PreferredAuthentications publickey

    Host github github.com
      User git
      Hostname github.com
      PreferredAuthentications publickey

    Host titan
      HostName ${settings.homeDomain}
      Port 443
      User john
      ForwardAgent yes

    Host hyperion
      HostName ${settings.hyperionIP}
      Port 22
      User john
      ForwardAgent yes

    Host kubetunnel
      HostName ${settings.homeDomain}
      Port 443
      User john
      LocalForward 6443 localhost:6443
      RequestTTY no
      ExitOnForwardFailure yes
      ControlMaster auto
      ControlPath ~/.ssh/cm_sockets/%r@%h:%p

  '';

in


  {
    __toString = self: ''
      ${libdot.mkdir { path = ".ssh"; mode = "0700"; }}
      ${libdot.copy { path = config; to = ".ssh/config"; mode = "0600"; }}
    '';
  }
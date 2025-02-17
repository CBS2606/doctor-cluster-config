{ config, lib, pkgs, ... }:
{
  imports = [ ./. ];

  systemd.services.znapzend-setup = {
    wantedBy = ["multi-user.target"];
    before = ["znapzend"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.zfs}/bin/zfs allow znapzend create,destroy,mount,receive,userprop zpool1"
        "${pkgs.zfs}/bin/zfs allow znapzend create,destroy,mount,receive,userprop zpool2"
      ];
      RemainAfterExit = true;
    };
  };

  boot.zfs.extraPools = [ "zpool1" "zpool2" ];

  users.users.znapzend = {
    isSystemUser = true;
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIORiUPbKrKzb55DrqDK4YXmqM5L1Qo8mDhmbdvKu+nIi"
    ];
  };
}

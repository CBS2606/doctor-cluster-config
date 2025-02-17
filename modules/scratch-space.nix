{ lib, config, ... }: {
  # Create scratch space per user.
  # The scratch space is not backed up!
  # /scratch is stored on the local rootfs (usually zfs) instead of NFS
  # /scratch2 is meant for dedicated storage devices. We usually use a faster
  #           more common fileystem i.e. ext4. Use this for
  #           benchmarks/evaluation if present. This block device might be more
  #           of re-formatted in order to have consistent measurement results
  systemd.tmpfiles.rules =
    let
      loginUsers = lib.filterAttrs (n: v: v.isNormalUser) config.users.users;
    in
      (lib.mapAttrsToList (n: v: "d /scratch/${n} 0755 ${n} users -") loginUsers)
      ++ (lib.optionals (config.fileSystems ? "/scratch2") (lib.mapAttrsToList (n: v: "d /scratch2/${n} 0755 ${n} users -") loginUsers));
}

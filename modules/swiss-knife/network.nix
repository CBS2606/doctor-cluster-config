{ lib, config, ... }:
let
  concatAttrs = attrList: lib.fold (x: y: x // y) {} attrList;
in {
  options = {
    networking.doctorwho.swissknife.macs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        Mac address of our internal 10G interface.
        We use these macs to rename our interfaces.
      '';
    };
  };
  config = {
    systemd.network.links = concatAttrs (lib.imap0 (num: mac: {
      "05-swissknife${toString num}".extraConfig = ''
        [Match]
        MACAddress = ${mac}
        Type = ether

        [Link]
        Name = swissknife${toString num}
      '';
    }) config.networking.doctorwho.swissknife.macs);

    systemd.network.networks = concatAttrs (lib.imap0 (num: mac: {
      "05-swissknife${toString num}".extraConfig = ''
        [Match]
        MACAddress = ${mac}

        [Network]
        DNSSEC = no
        DHCP = no
        LinkLocalAddressing = yes
        Address = 192.168.55.${toString (num + 1)}/24
        Address = fd00::${toString (num + 1)}/64
        IPForward = yes
      '';
    }) config.networking.doctorwho.swissknife.macs);
  };
}

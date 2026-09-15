{ config, lib, ... }:
let
  cfg = config.homelab.files;
in
{
  # A plain directory served over SMB to tailnet clients only. Data lives
  # under /var/lib so it is covered by the host's restic backup.
  #
  # Mount on macOS: Finder > Go > Connect to Server > smb://<host>/files
  options.homelab.files = {
    enable = lib.mkEnableOption "files (Samba share over tailscale)";
    path = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/files";
      description = "Directory exported as the `files` share.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "claby2";
      description = "Unix user that owns the share and is allowed to log in.";
    };
    passwordFile = lib.mkOption {
      type = lib.types.path;
      description = "File containing the Samba password for `user`.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.samba = {
      enable = true;
      # Port 445 is only opened on tailscale0 below.
      openFirewall = false;
      # NetBIOS name service and winbind are useless over tailscale.
      nmbd.enable = false;
      winbindd.enable = false;
      settings = {
        global = {
          "server role" = "standalone server";
          "server string" = config.networking.hostName;
          "server min protocol" = "SMB3_00";
          "map to guest" = "Never";
          # Belt and braces with the firewall: only tailnet addresses.
          # (Not `bind interfaces only`: smbd cannot bind dynamically and would
          # fail at boot if tailscale0 appears after it starts.)
          "hosts allow" = "100.64.0.0/10 fd7a:115c:a1e0::/48 127.0.0.1";
          "hosts deny" = "0.0.0.0/0 ::/0";
          # `fruit` is Samba's Apple compatibility module: it speaks the AAPL
          # SMB extensions macOS uses with real Apple servers (faster Finder)
          # and stores resource forks / Finder info as xattrs via
          # streams_xattr instead of littering `._*` sidecar files. The
          # wipe/delete options clean up the empty forks Finder creates.
          "vfs objects" = "fruit streams_xattr";
          "fruit:metadata" = "stream";
          "fruit:model" = "MacSamba";
          "fruit:posix_rename" = "yes";
          "fruit:veto_appledouble" = "no";
          "fruit:nfs_aces" = "no";
          "fruit:wipe_intentionally_left_blank_rfork" = "yes";
          "fruit:delete_empty_adfiles" = "yes";
        };
        files = {
          inherit (cfg) path;
          browseable = "yes";
          "read only" = "no";
          "valid users" = cfg.user;
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.path} 0750 ${cfg.user} users - -"
    ];

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 445 ];

    # Samba keeps its own password database (/var/lib/samba/private), so
    # seed it from the agenix secret before smbd starts.
    systemd.services.samba-password = {
      description = "Set Samba password for ${cfg.user}";
      before = [ "samba-smbd.service" ];
      requiredBy = [ "samba-smbd.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        password=$(cat ${cfg.passwordFile})
        printf '%s\n%s\n' "$password" "$password" \
          | ${config.services.samba.package}/bin/smbpasswd -s -a ${cfg.user}
      '';
    };
  };
}

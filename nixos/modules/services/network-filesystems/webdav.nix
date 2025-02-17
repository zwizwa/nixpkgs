{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.webdav;
  format = pkgs.formats.yaml { };
in
{
  options = {
    services.webdav = {
      enable = mkEnableOption "WebDAV server";

      user = mkOption {
        type = types.str;
        default = "webdav";
        description = "User account under which WebDAV runs.";
      };

      group = mkOption {
        type = types.str;
        default = "webdav";
        description = "Group under which WebDAV runs.";
      };

      settings = mkOption {
        type = format.type;
        default = { };
        description = ''
          Attrset that is converted and passed as config file. Available options
          can be found at
          <link xlink:href="https://github.com/hacdias/webdav">here</link>.

          This program supports reading username and password configuration
          from environment variables, so it's strongly recommended to store
          username and password in a separate
          <link xlink:href="https://www.freedesktop.org/software/systemd/man/systemd.exec.html#EnvironmentFile=">EnvironmentFile</link>.
          This prevents adding secrets to the world-readable Nix store.
        '';
        example = literalExpression ''
          {
              address = "0.0.0.0";
              port = 8080;
              scope = "/srv/public";
              modify = true;
              auth = true;
              users = [
                {
                  username = "{env}ENV_USERNAME";
                  password = "{env}ENV_PASSWORD";
                }
              ];
          }
        '';
      };

      configFile = mkOption {
        type = types.path;
        default = format.generate "webdav.yaml" cfg.settings;
        defaultText = "Config file generated from services.webdav.settings";
        description = ''
          Path to config file. If this option is set, it will override any
          configuration done in options.services.webdav.settings.
        '';
        example = "/etc/webdav/config.yaml";
      };

      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Environment file as defined in <citerefentry>
          <refentrytitle>systemd.exec</refentrytitle><manvolnum>5</manvolnum>
          </citerefentry>.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "webdav") {
      webdav = {
        description = "WebDAV daemon user";
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = mkIf (cfg.group == "webdav") {
      webdav = { };
    };

    systemd.services.webdav = {
      description = "WebDAV server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.webdav}/bin/webdav -c ${cfg.configFile}";
        Restart = "on-failure";
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
      };
    };
  };

  meta.maintainers = with maintainers; [ pengmeiyu ];
}

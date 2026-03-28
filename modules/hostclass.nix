{ lib, config, ... }:
{
  options.hostclass.name = lib.mkOption {
    type = lib.types.str;
    description = "The hostclass of this machine. Must be set by importing a hostclass file.";
  };

  config.environment.variables.HOSTCLASS = config.hostclass.name;
}

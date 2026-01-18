# Wrapper that provides version-agnostic package names
# This reads node-packages.json and exports packages with clean names
# e.g., @anthropic-ai/claude-code -> claude-code
{ pkgs }:
let
  # Read the JSON manifest
  packageSpecs = builtins.fromJSON (builtins.readFile ./node-packages.json);

  # Import the node2nix-generated packages
  node2nixPackages = import ./default.nix {
    inherit pkgs;
    system = pkgs.stdenv.hostPlatform.system;
    nodejs = pkgs.nodejs;
  };

  # Helper to get a clean name from npm package name
  # @scope/package-name -> package-name
  # simple-name -> simple-name
  cleanName =
    name:
    let
      parts = builtins.split "/" name;
    in
    if builtins.length parts > 1 then builtins.elemAt parts 2 else name;

  # Build attribute set from JSON specs
  getPackage =
    spec:
    let
      name = builtins.head (builtins.attrNames spec);
      version = spec.${name};
      attrName = "${name}-${version}";
    in
    {
      name = cleanName name;
      value = node2nixPackages.${attrName};
    };
in
builtins.listToAttrs (map getPackage packageSpecs)

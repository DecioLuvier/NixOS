{ self, ... }:
{
  nix.registry.jupyter = {
    to = {
      type = "path";
      path = "${self}/shells/jupyter";
    };
  };
}
{
  description = "Nix flake to bootstrap a Headscale control plane on Ubuntu 24.04";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # The wrapper application
        ubxstrap = pkgs.writeShellApplication {
          name = "ubxstrap";
          runtimeInputs = [ pkgs.ansible pkgs.iproute2 pkgs.python3 ];
          text = ''
            # Detect local primary IP
            LOCAL_IP=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | head -n 1 | cut -d/ -f1)
            
            if [ -z "$LOCAL_IP" ]; then
              echo "Error: Could not detect local IP address."
              exit 1
            fi
            
            echo "Detected Local IP: $LOCAL_IP"
            
            # Path to the flake source
            FLAKE_DIR="${self}"
            
            # Check for sudo
            if [ "$EUID" -ne 0 ]; then
              echo "This script needs to be run with sudo to modify system files."
              exec sudo nix run ".#ubxstrap" -- "$@"
            fi

            ansible-playbook \
              -i "localhost," \
              -c local \
              "$FLAKE_DIR/playbook.yml" \
              -e "host_ip=$LOCAL_IP" \
              "$@"
          '';
        };
      in
      {
        packages.default = ubxstrap;
        apps.default = flake-utils.lib.mkApp { drv = ubxstrap; };
        
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.ansible
            pkgs.python3
          ];
        };
      }
    );
}

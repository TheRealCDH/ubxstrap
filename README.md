# ubxstrap

A Nix flake that bootstraps a [Headscale](https://github.com/juanfont/headscale) control plane on **Ubuntu 24.04**.

This project uses **Nix** to provide a reproducible **Ansible** environment, which then configures the local host as a Headscale server and joins it to its own tailnet.

## Prerequisites
- Ubuntu 24.04 host
- [Determinate Nix Installer](https://determinate.systems/nix/install)

## Usage

You can run the bootstrap directly from GitHub:

```bash
sudo nix run github:your-user/ubxstrap
```

Or locally if you have cloned the repository:

```bash
sudo nix run .
```

### What it does:
1. Detects the local primary IP address.
2. Installs Headscale (latest .deb from GitHub).
3. Configures Headscale for local non-TLS use on port 8080.
4. Installs Tailscale using the official apt repository.
5. Creates a default Headscale user named `admin`.
6. Generates an auth key and joins the host to its own Headscale tailnet.

## Configuration
The playbook uses standard Ansible roles. You can modify the variables in `playbook.yml` if you want to change the default port, user, or Headscale version.

### Key Paths:
- **Config:** `/etc/headscale/config.yaml`
- **Data:** `/var/lib/headscale/`
- **DB:** `/var/lib/headscale/db.sqlite`

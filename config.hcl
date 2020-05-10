client {
  chroot_env {
    # empty on purpose
  }
  host_volume "nix-store" {
    path = "/nix/store"
    read_only = true
  }
  host_volume "nix-db" {
    path = "/nix/var/nix/db"
    read_only = true
  }
  host_volume "nix-daemon" {
    path = "/nix/var/nix/daemon-socket"
    read_only = true
  }
}

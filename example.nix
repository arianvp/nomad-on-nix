{ pkgs ? import <nixpkgs> {}}:
pkgs.writeText "example.hcl"
''
job "batch" {
  datacenters = ["dc1"]

  type = "batch"

  group "batch" {
    count = 1

    # Mount the host nix store into the job

    volume "nix-store" {
      type = "host"
      read_only = true
      source = "nix-store"
    }
    volume "nix-db" {
      type = "host"
      read_only = true
      source = "nix-db"
    }
    volume "nix-daemon" {
      type = "host"
      read_only = true
      source = "nix-daemon"
    }
    task "batch" {
      /*
      If I use driver = "exec"  I get:
      2020-05-10T23:15:44.839+0200 [ERROR] client.alloc_runner.task_runner: running
      driver failed: alloc_id=c03ce7a9-c530-93aa-a0a0-33ef81929ed2 task=batch
      error="failed to launch command with executor: rpc error: code = Unknown desc
      = file /nix/store/y26qxcq1gg2hrqpxdc58b2fghv2bhxjg-hello-2.10/bin/hello not
      found under path
      /tmp/NomadClient378332617/c03ce7a9-c530-93aa-a0a0-33ef81929ed2/batch" */
      # this suggests to me that the "exec" driver is mounting the volume later than the "docker" driver; which is strange.
      # Now _only_ using the docker driver as a hack to get things to work
      driver = "docker"
      # uncomment to reproduce issue:
      # driver = "exec"
      env {
        # Make nix talk to the host daemon
        NIX_REMOTE = "daemon"
      }
      volume_mount {
        volume      = "nix-store"
        destination = "/nix/store"
      }
      volume_mount {
        volume = "nix-db"
        destination = "/nix/var/nix/db"
      }
      volume_mount {
        volume = "nix-daemon"
        destination = "/nix/var/nix/daemon-socket"
      }
      config {
        # comment the "image" line when running with driver = "exec"
        # content of the alpine image isn't used. We only refer to bind-mounted nix store paths
        # Just here to make nomad happy as the docker driver bind-mounts the directories early enough
        # whilst the exec driver doesn't
        image = "alpine"
        command = "${pkgs.hello}/bin/hello"
      }
    }
  }
}
''

# nomad-on-nix

```
$ nix run nixpkgs.nomad
$ nomad -dev -config ./config.hcl
$ nomad run $(nix-build ./example.nix)

```

Bind-mounts the host nix store into the container, and executes the file.
In the future; we want to run `nix-build` _inside_ the nomad job; not outside; so that
each node in the cluster can download the corresponding nix derivation from the nix cache. Currently this example only works if the submitter and the executor are the same computer. not very useful :). But it's just here to experiment getting `nomad` jobs to access the nix store. 


Problem is that the bind mounts do _not_ work with the `exec` driver but _do_ work
with the `docker` driver

If I use `driver = "exec"`  I get:

      2020-05-10T23:15:44.839+0200 [ERROR] client.alloc_runner.task_runner: running
      driver failed: alloc_id=c03ce7a9-c530-93aa-a0a0-33ef81929ed2 task=batch
      error="failed to launch command with executor: rpc error: code = Unknown desc
      = file /nix/store/y26qxcq1gg2hrqpxdc58b2fghv2bhxjg-hello-2.10/bin/hello not
      found under path
      /tmp/NomadClient378332617/c03ce7a9-c530-93aa-a0a0-33ef81929ed2/batch"
      

But with `driver = "docker"` it works fine.
Seems like the `exec` driver bind-mounts their paths too late

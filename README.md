# nomad-on-nix

```
$ nix run nixpkgs.nomad
$ nomad -dev -config ./config.hcl
$ nomad run $(nix-build ./example.nix)

```

Bind-mounts the host nix store into the container, and executes the file.
In the future; we want to run `nix-build` _inside_ the nomad job; not outside; so that
each node in the cluster can download the corresponding nix derivation from the nix cache


Problem is that the bind mounts do _not_ work with the `exec` driver but _do_ work
with the `docker` driver


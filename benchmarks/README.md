# Benchmarks
A list of available benchmarks. For results, see `RESULTS.md`

## Coremark
* We have a [Galois fork of coremark](https://gitlab-ext.galois.com/ssith/coremark) which supports both P1, P2 and P3 CPUs.
* To build coremark binarier, run `coremark/build_gfe_baseline_from_nix.sh` - if you don't have nix environment, individual make commands can be run manually.
* On bare-metal, `run_coremark.sh` shows how to reploy and run the binaries.
* On Linux/FreeBSD, please start up the system manually, and then `scp` the binary to the file system.

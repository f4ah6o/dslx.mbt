# Continuous integration

`MoonBit CI` runs on the exact pull request head and on pushes to `main`.
One Ubuntu 24.04 job
installs the official MoonBit toolchain and core release
`0.10.14+7d59c7ec9` with the official installer, records tool versions, and runs:

```sh
moon check --target all -j 2
moon test --target all -j 2
```

For this pinned release, `all` exercises wasm, wasm-gc, js, and native. The job
includes the 46 existing tests, including the fixed-seed core QuickCheck models.
It validates Linux; Windows and macOS behavior needs separate execution.

The toolchain is installed under the runner's temporary directory. Checkout has
read-only permissions and does not retain Git credentials. A newer run cancels
an older run for the same pull request or branch, and the job has a ten-minute
timeout. Toolchain upgrades should update the explicit release and rerun these
checks.

Full `moon fmt --check` is deferred because six existing files have baseline
formatting differences: `core.mbt`, `emit.mbt`, `examples.mbt`, `grammar.mbt`,
`project.mbt`, and `validate.mbt`. This check/test gate does not reformat them or
treat those known differences as a new failure. Formatting cleanup remains a
separate change.

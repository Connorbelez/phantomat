# Contributing

Issues and pull requests are welcome.

For bugs, include your Hyprland version (`hyprctl version`), your monitor
setup, and what you did right before. A crash leaves a report you can see with
`coredumpctl list Hyprland`.

The plugin reaches deep into Hyprland internals, so please test a change in a
nested session before sending it:

```sh
make                                   # builds spatialoverview.so
make test-tools                        # the virtual mouse some tests use
python3 tests/navigator-nested.py --plugin spatialoverview.so
python3 tests/popup-nested.py spatialoverview.so
```

Each test opens Hyprland in a window of its own and closes it again; nothing
touches your running session or your config.


## Contribution fork maintenance

Open an issue describing the failure or intended behavior before a large change. Small fixes may go directly to a pull request. Include the source revision, relevant dependency versions, reproduction steps, and verification output. Run `bash scripts/verify.sh` before submitting.

Keep fixes separate from packaging and documentation changes. Preserve upstream authorship and license notices. Disclose AI assistance. Never include personal machine identifiers, credentials, biometric state, or firmware in reports. Hardware qualification belongs in a redacted test report with model, page size, and tested versions.

The maintainer may merge after required CI and review. Additional review is encouraged when another maintainer is available; branch protection does not require a nonexistent second maintainer.

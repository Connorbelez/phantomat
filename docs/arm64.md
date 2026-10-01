# ARM64 function hooks

Hyprland 0.56.2's `CFunctionHook::hook()` returns false outside x86_64. That allows Phantomat to load on ARM64, but opening an overview reports the misleading error about another overview plugin. This fork uses Dobby for ARM64 instruction relocation, original-function trampolines, and unhook restoration. The existing Hyprland hook backend remains in use on other architectures.

## Build

The changes were tested with Hyprland 0.56.2 (`efb50993780079460b0cbed1363e2166a2de1d9f`), GCC 16.1.1, Linux 7.1.13, and 16 KiB pages on a MacBook Pro 13-inch M1/J293. Use headers matching the running compositor.

```sh
git clone --branch fix/linux-arm64 https://github.com/Connorbelez/Dobby.git
cmake -S Dobby -B Dobby/build \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DPlugin.SymbolResolver=OFF -DDOBBY_DEBUG=OFF
cmake --build Dobby/build --target dobby_static -j2

export DOBBY_INCLUDE="$(realpath Dobby/include)"
export DOBBY_LIBRARY="$(realpath Dobby/build/libdobby.a)"
make -j2 OUT=.build/dev/spatialoverview.so
make test-tools
```

Exporting the two variables also makes them available to the installer. Alternatively, place their assignments in the ignored `.build/dobby-config.mk` file. Only the Make build frontend is integrated in this experiment; supply equivalent include/library dependencies when using another frontend.

The static archive is embedded in the plugin and its symbols are hidden from the compositor's global dynamic-symbol namespace. No replacement Hyprland build is required.

## Verification

Before replacing a live binary, use the repository's disposable nested sessions:

```sh
python3 tests/navigator-nested.py --plugin .build/dev/spatialoverview.so
python3 tests/popup-nested.py .build/dev/spatialoverview.so
python3 tests/multimonitor-nested.py .build/dev/spatialoverview.so
```

All three passed on the tested M1. The standalone Dobby smoke test also passed integer and floating-point argument/return handling, relocated original calls, and repeated hook installation/removal with pointer-authentication/BTI compiler flags.

The nested harness now sizes its own host window to the requested mode. Without this, a tiling host reduced the test output to 781 pixels wide and caused false popup/clipping failures. The multi-monitor test also creates its screenshot directory and checks capture failure rather than reporting success without the artifact.

Use the installer's existing atomic replacement and safe-unload workflow when deploying. Keep a copy of the previous binary. Rebuild against matching headers after a Hyprland update.

## Independent workspaces

The ARM64 backend supports both the persistent canvas and transient workspace overview. For Hyprsplit-style independent workspaces, configure `canvas.enabled`, `canvas.desktop_mode`, `canvas.persistent`, `canvas.auto_float`, and `canvas.auto_place` to false, and load the monitor-local workspace bindings after Phantomat's bindings. That preserves normal tiling while the overview is closed.

This is an agent-assisted local compatibility experiment, published to a personal fork. The source base and test evidence are described here; it is not an upstream release or a claim that every ARM64 system has been tested.

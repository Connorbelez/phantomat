#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'CHECK'
import ast,pathlib
for p in pathlib.Path('tests').rglob('*.py'): ast.parse(p.read_text(), filename=str(p))
assert pathlib.Path('FunctionHook.hpp').is_file()
for p in ['LICENSE','ATTRIBUTION.md','docs/arm64.md','ROADMAP.md']: assert pathlib.Path(p).is_file()
print('PASS: Python harness syntax and ARM64 source/documentation integrity')
CHECK

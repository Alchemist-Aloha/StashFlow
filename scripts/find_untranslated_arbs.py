import json
from pathlib import Path

l10n_dir = Path('../lib/l10n').resolve()
files = list(l10n_dir.glob('*.arb'))
files = sorted(files)

en = None
for f in files:
    if f.name.endswith('_en.arb') or f.name == 'app_en.arb':
        en = json.loads(f.read_text())
        break
if en is None:
    print('No app_en.arb found')
    raise SystemExit(1)

results = {}
for f in files:
    if f.name == 'app_en.arb':
        continue
    data = json.loads(f.read_text())
    missing = []
    same_as_en = []
    for k, v in en.items():
        if k.startswith('@'):
            continue
        if k not in data:
            missing.append(k)
        else:
            if isinstance(v, str) and data[k] == v:
                same_as_en.append(k)
    results[f.name] = {'missing': missing, 'same_as_en': same_as_en}

out = Path('build/untranslated_report.json')
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(results, indent=2, ensure_ascii=False))
print('Wrote', out)

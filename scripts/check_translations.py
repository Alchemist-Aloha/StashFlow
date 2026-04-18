import json
import glob
from pathlib import Path

root = Path(__file__).resolve().parent.parent
l10n_dir = root / 'lib' / 'l10n'

with open(l10n_dir / 'app_en.arb', 'r', encoding='utf-8') as f:
    en = json.load(f)

arb_files = sorted(glob.glob(str(l10n_dir / 'app_*.arb')))
results = {}
for path in arb_files:
    if path.endswith('app_en.arb'):
        continue
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    matches = []
    for k, v in en.items():
        if k.startswith('@'):
            continue
        if k in data and data[k] == v:
            matches.append(k)
    if matches:
        results[path] = matches

if not results:
    print('OK: No untranslated exact matches found (non-English ARBs differ from English).')
else:
    for path, keys in results.items():
        print(f'{path}: {len(keys)} keys match English:')
        for k in keys:
            print('  ' + k)

import json
from pathlib import Path

root = Path(__file__).resolve().parent.parent
l10n_dir = root / 'lib' / 'l10n'
report_file = root / 'l10n_untranslated.json'

translations = {
  "de": {
    "settings_playback_gravity_orientation": "Schwerkraftgesteuerte Ausrichtung",
    "settings_playback_gravity_orientation_subtitle": "Erlaube die Rotation zwischen passenden Ausrichtungen mithilfe des Gerätesensors (z. B. Landschaft links/rechts)."
  },
  "es": {
    "settings_playback_gravity_orientation": "Orientación controlada por la gravedad",
    "settings_playback_gravity_orientation_subtitle": "Permitir rotar entre orientaciones coincidentes usando el sensor del dispositivo (p. ej., girar el paisaje izquierda/derecha)."
  },
  "fr": {
    "settings_playback_gravity_orientation": "Orientation contrôlée par la gravité",
    "settings_playback_gravity_orientation_subtitle": "Permettre la rotation entre orientations correspondantes à l'aide du capteur de l'appareil (par ex. basculer paysage gauche/droite)."
  },
  "it": {
    "settings_playback_gravity_orientation": "Orientamento controllato dalla gravità",
    "settings_playback_gravity_orientation_subtitle": "Consenti la rotazione tra orientamenti corrispondenti usando il sensore del dispositivo (es. capovolgere il paesaggio a sinistra/destra)."
  },
  "ja": {
    "settings_playback_gravity_orientation": "重力制御の画面向き",
    "settings_playback_gravity_orientation_subtitle": "デバイスのセンサーを使って一致する向きに回転できるようにします（例：左右の横向きに反転）。"
  },
  "ko": {
    "settings_playback_gravity_orientation": "중력 제어 화면 방향",
    "settings_playback_gravity_orientation_subtitle": "기기 센서를 사용하여 일치하는 방향으로 회전하도록 허용합니다(예: 좌/우 가로 방향 전환)."
  },
  "ru": {
    "settings_playback_gravity_orientation": "Ориентация, управляемая гравитацией",
    "settings_playback_gravity_orientation_subtitle": "Разрешить поворот между совпадающими ориентациями с помощью датчика устройства (например, переворачивать альбомную ориентацию влево/вправо)."
  },
  "zh": {
    "settings_playback_gravity_orientation": "重力控制的方向",
    "settings_playback_gravity_orientation_subtitle": "允许使用设备传感器在匹配的方向之间旋转（例如：左右翻转横向）。"
  },
  "zh_Hans": {
    "settings_playback_gravity_orientation": "重力控制的方向",
    "settings_playback_gravity_orientation_subtitle": "允许使用设备传感器在匹配的方向之间旋转（例如：左右翻转横向）。"
  },
  "zh_Hant": {
    "settings_playback_gravity_orientation": "重力控制的方向",
    "settings_playback_gravity_orientation_subtitle": "允許使用裝置感測器在相符方向之間旋轉（例如：將橫向向左/向右翻轉）。"
  }
}

# Load reported untranslated locales to only update those
if not report_file.exists():
    print('No l10n_untranslated.json found; aborting')
    raise SystemExit(1)
report = json.loads(report_file.read_text())

for locale, keys in report.items():
    # map locale to file name
    fname = f'app_{locale}.arb' if not locale.startswith('en') else 'app_en.arb'
    path = l10n_dir / fname
    if not path.exists():
        print(f'Locale file not found: {path}, skipping')
        continue
    data = json.loads(path.read_text())
    updated = False
    tr = translations.get(locale)
    if not tr:
        print(f'No translations provided for {locale}, skipping')
        continue
    for k in keys:
        if k in data:
            continue
        if k in tr:
            data[k] = tr[k]
            updated = True
    if updated:
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
        print(f'Updated {path}')
    else:
        print(f'No changes for {path}')

print('Done')

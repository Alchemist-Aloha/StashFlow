import json
from pathlib import Path

root = Path(__file__).resolve().parent.parent
l10n_dir = root / 'lib' / 'l10n'
report_file = root / 'l10n_untranslated.json'

translations = {
  "de": {
    "scenes_filter_saved": "Filtereinstellungen als Standard gespeichert",
    "settings_develop_proxy_auth": "Proxy-Authentifizierungsmodi aktivieren",
    "settings_develop_proxy_auth_subtitle": "Aktivieren Sie erweiterte Basic-Auth- und Bearer-Token-Methoden für die Verwendung mit authentifizierungsfreien Backends hinter Proxys wie Authentik.",
    "settings_server_auth_basic": "Basic Auth",
    "settings_server_auth_bearer": "Bearer-Token",
    "settings_server_auth_basic_desc": "Sendet den Header 'Authorization: Basic <base64(user:pass)>'.",
    "settings_server_auth_bearer_desc": "Sendet den Header 'Authorization: Bearer <token>'.",
    "images_filter_title": "Bilder filtern",
    "images_filter_saved": "Filtereinstellungen als Standard gespeichert"
  },
  "es": {
    "scenes_filter_saved": "Preferencias de filtro guardadas como predeterminadas",
    "settings_develop_proxy_auth": "Habilitar modos de autenticación de proxy",
    "settings_develop_proxy_auth_subtitle": "Habilite los métodos avanzados de Basic Auth y Bearer Token para su uso con backends sin autenticación detrás de proxies como Authentik.",
    "settings_server_auth_basic": "Autenticación básica",
    "settings_server_auth_bearer": "Token de portador",
    "settings_server_auth_basic_desc": "Envía el encabezado 'Authorization: Basic <base64(user:pass)>'.",
    "settings_server_auth_bearer_desc": "Envía el encabezado 'Authorization: Bearer <token>'.",
    "images_filter_title": "Filtrar imágenes",
    "images_filter_saved": "Preferencias de filtro guardadas como predeterminadas"
  },
  "fr": {
    "scenes_filter_saved": "Préférences de filtre enregistrées par défaut",
    "settings_develop_proxy_auth": "Activer les modes d'authentification proxy",
    "settings_develop_proxy_auth_subtitle": "Activez les méthodes avancées Basic Auth et Bearer Token pour une utilisation avec des backends sans authentification derrière des proxys comme Authentik.",
    "settings_server_auth_basic": "Authentification de base",
    "settings_server_auth_bearer": "Jeton porteur",
    "settings_server_auth_basic_desc": "Envoie l'en-tête 'Authorization: Basic <base64(user:pass)>'.",
    "settings_server_auth_bearer_desc": "Envoie l'en-tête 'Authorization: Bearer <token>'.",
    "images_filter_title": "Filtrer les images",
    "images_filter_saved": "Préférences de filtre enregistrées par défaut"
  },
  "it": {
    "scenes_filter_saved": "Preferenze del filtro salvate come predefinite",
    "settings_develop_proxy_auth": "Abilita modalità di autenticazione proxy",
    "settings_develop_proxy_auth_subtitle": "Abilita i metodi avanzati Basic Auth e Bearer Token per l'uso con backend senza autenticazione dietro proxy come Authentik.",
    "settings_server_auth_basic": "Autenticazione di base",
    "settings_server_auth_bearer": "Token Bearer",
    "settings_server_auth_basic_desc": "Invia l'header 'Authorization: Basic <base64(user:pass)>'.",
    "settings_server_auth_bearer_desc": "Invia l'header 'Authorization: Bearer <token>'.",
    "images_filter_title": "Filtra immagini",
    "images_filter_saved": "Preferenze del filtro salvate come predefinite"
  },
  "ja": {
    "scenes_filter_saved": "フィルター設定をデフォルトとして保存しました",
    "settings_develop_proxy_auth": "プロキシ認証モードを有効にする",
    "settings_develop_proxy_auth_subtitle": "Authentikなどのプロキシの背後にある認証不要のバックエンドで使用するために、高度なBasic認証およびBearerトークン方式を有効にします。",
    "settings_server_auth_basic": "Basic認証",
    "settings_server_auth_bearer": "Bearerトークン",
    "settings_server_auth_basic_desc": "'Authorization: Basic <base64(user:pass)>' ヘッダーを送信します。",
    "settings_server_auth_bearer_desc": "'Authorization: Bearer <token>' ヘッダーを送信します。",
    "images_filter_title": "画像をフィルター",
    "images_filter_saved": "フィルター設定をデフォルトとして保存しました"
  },
  "ko": {
    "scenes_filter_saved": "필터 설정이 기본값으로 저장되었습니다",
    "settings_develop_proxy_auth": "프록시 인증 모드 활성화",
    "settings_develop_proxy_auth_subtitle": "Authentik과 같은 프록시 뒤의 인증 없는 백엔드에서 사용하기 위해 고급 Basic Auth 및 Bearer Token 방식을 활성화합니다.",
    "settings_server_auth_basic": "기본 인증",
    "settings_server_auth_bearer": "전달자 토큰",
    "settings_server_auth_basic_desc": "'Authorization: Basic <base64(user:pass)>' 헤더를 전송합니다.",
    "settings_server_auth_bearer_desc": "'Authorization: Bearer <token>' 헤더를 전송합니다.",
    "images_filter_title": "이미지 필터링",
    "images_filter_saved": "필터 설정이 기본값으로 저장되었습니다"
  },
  "ru": {
    "scenes_filter_saved": "Настройки фильтра сохранены по умолчанию",
    "settings_develop_proxy_auth": "Включить режимы аутентификации через прокси",
    "settings_develop_proxy_auth_subtitle": "Включите расширенные методы Basic Auth и Bearer Token для использования с бэкендами без аутентификации за прокси-серверами, такими как Authentik.",
    "settings_server_auth_basic": "Базовая аутентификация",
    "settings_server_auth_bearer": "Токен носителя",
    "settings_server_auth_basic_desc": "Отправляет заголовок 'Authorization: Basic <base64(user:pass)>'.",
    "settings_server_auth_bearer_desc": "Отправляет заголовок 'Authorization: Bearer <token>'.",
    "images_filter_title": "Фильтровать изображения",
    "images_filter_saved": "Настройки фильтра сохранены по умолчанию"
  },
  "zh": {
    "scenes_filter_saved": "筛选偏好已保存为默认设置",
    "settings_develop_proxy_auth": "启用代理认证模式",
    "settings_develop_proxy_auth_subtitle": "启用高级 Basic Auth 和 Bearer Token 方法，以便在 Authentik 等代理背后的无认证后端中使用。",
    "settings_server_auth_basic": "基础认证",
    "settings_server_auth_bearer": "Bearer 令牌",
    "settings_server_auth_basic_desc": "发送 'Authorization: Basic <base64(user:pass)>' 请求头。",
    "settings_server_auth_bearer_desc": "发送 'Authorization: Bearer <token>' 请求头。",
    "images_filter_title": "过滤图片",
    "images_filter_saved": "筛选偏好已保存为默认设置"
  },
  "zh_Hans": {
    "scenes_filter_saved": "筛选偏好已保存为默认设置",
    "settings_develop_proxy_auth": "启用代理认证模式",
    "settings_develop_proxy_auth_subtitle": "启用高级 Basic Auth 和 Bearer Token 方法，以便在 Authentik 等代理背后的无认证后端中使用。",
    "settings_server_auth_basic": "基础认证",
    "settings_server_auth_bearer": "Bearer 令牌",
    "settings_server_auth_basic_desc": "发送 'Authorization: Basic <base64(user:pass)>' 请求头。",
    "settings_server_auth_bearer_desc": "发送 'Authorization: Bearer <token>' 请求头。",
    "images_filter_title": "过滤图片",
    "images_filter_saved": "筛选偏好已保存为默认设置"
  },
  "zh_Hant": {
    "scenes_filter_saved": "篩選偏好已儲存為預設設定",
    "settings_develop_proxy_auth": "啟用代理認證模式",
    "settings_develop_proxy_auth_subtitle": "啟用進階 Basic Auth 和 Bearer Token 方法，以便在 Authentik 等代理背後的無認證後端中使用。",
    "settings_server_auth_basic": "基礎認證",
    "settings_server_auth_bearer": "Bearer 權杖",
    "settings_server_auth_basic_desc": "發送 'Authorization: Basic <base64(user:pass)>' 請求頭。",
    "settings_server_auth_bearer_desc": "發送 'Authorization: Bearer <token>' 請求頭。",
    "images_filter_title": "過濾圖片",
    "images_filter_saved": "篩選偏好已儲存為預設設定"
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

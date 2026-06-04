{{- /* Shared webapp install + icon logic. Params (dict):
       name     display name (also the .desktop / icon basename)
       url      webapp URL
       icon     Dashboard Icons png basename (e.g. "gmail.png")
       mime     optional scheme handler (e.g. "x-scheme-handler/mailto")
       default  optional: present => register the .desktop as the mime default

   The icon is always refreshed directly so machines provisioned before the
   explicit-glyph fix still get the right icon; the .desktop guard only avoids
   reinstalling the webapp itself. Without an explicit icon the installer falls
   back to Google's favicon service, which returns a generic/low-res glyph. */ -}}
ICON_URL="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/{{ .icon }}"
ICON_PATH="$HOME/.local/share/applications/icons/{{ .name }}.png"

if [ ! -f "$HOME/.local/share/applications/{{ .name }}.desktop" ]; then
    omarchy webapp install "{{ .name }}" \
        "{{ .url }}" \
        "$ICON_URL"{{ if hasKey . "mime" }} \
        "" \
        "{{ .mime }}"{{ end }}
fi

mkdir -p "$(dirname "$ICON_PATH")"
curl -fsSL -o "$ICON_PATH" "$ICON_URL" || true
{{ if hasKey . "default" }}
xdg-mime default {{ .name }}.desktop {{ .mime }}
{{- end }}

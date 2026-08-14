{{- /* Shared webapp install logic. Params (dict):
       name     display name (also the .desktop basename)
       url      webapp URL
       icon     Dashboard Icons png basename (e.g. "gmail.png")
       mime     optional scheme handler (e.g. "x-scheme-handler/mailto")
       default  optional: present => register the .desktop as the mime default

   Passing an explicit icon URL matters: left to itself the installer scrapes
   the site, and several of these serve a low-res or generic glyph.

   Reinstalls when the launcher is missing or still carries an absolute Icon=
   path, which is how omarchy 3 wrote them. */ -}}
DESKTOP="$HOME/.local/share/applications/{{ .name }}.desktop"

if [ ! -f "$DESKTOP" ] || grep -q '^Icon=/' "$DESKTOP"; then
    omarchy webapp install "{{ .name }}" \
        "{{ .url }}" \
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/{{ .icon }}"{{ if hasKey . "mime" }} \
        "" \
        "{{ .mime }}"{{ end }}
fi
{{ if hasKey . "default" }}
xdg-mime default {{ .name }}.desktop {{ .mime }}
{{- end }}

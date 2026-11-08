{{- /* Shared webapp install logic. Params (dict):
       name     display name (also the .desktop basename)
       url      webapp URL
       icon     Dashboard Icons png basename (e.g. "gmail.png")
       mime     optional scheme handler, registered as this app's default

   Passing an explicit icon URL matters: left to itself the installer scrapes
   the site, and several of these serve a low-res or generic glyph. */ -}}
if [ ! -f "$HOME/.local/share/applications/{{ .name }}.desktop" ]; then
    omarchy webapp install "{{ .name }}" \
        "{{ .url }}" \
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/{{ .icon }}"{{ if hasKey . "mime" }} \
        "" \
        "{{ .mime }}"{{ end }}
fi
{{- if hasKey . "mime" }}
xdg-mime default "{{ .name }}.desktop" {{ .mime }}
{{- end }}

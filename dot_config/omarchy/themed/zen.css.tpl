/* Omarchy theme for Zen Browser, loaded at startup through chrome/omarchy.css.
   Overrides only the roots Zen derives its palette from (zen-theme.css), so
   Zen still computes its own hover and panel shades. Based on
   dragosol/omarchy-zen-theme and aonatsky/omarchy-zen-sync (MIT). */

/* Zen's theme picker sets several of these inline on the root and on each
   space; an !important rule beats an inline value set without it. */
:root,
zen-workspace {
  color-scheme: {{ mode }} !important;
  --toolbar-color-scheme: {{ mode }} !important;
  --tab-selected-color-scheme: {{ mode }} !important;

  --zen-primary-color: {{ accent }} !important;
  --zen-branding-bg: {{ background }} !important;
  --zen-branding-bg-reverse: {{ foreground }} !important;
  --toolbox-textcolor: {{ foreground }} !important;

  --zen-themed-toolbar-bg-transparent: {{ background }} !important;
  --zen-dialog-background: {{ dark_background }} !important;
  --zen-in-content-dialog-background: {{ dark_background }} !important;
  --zen-urlbar-background: {{ dark_background }} !important;
  --zen-colors-input-bg: {{ dark_background }} !important;

  --zen-colors-border: {{ mix background foreground 20% }} !important;
  --zen-colors-border-contrast: {{ mix background foreground 32% }} !important;
  --zen-input-border-color: {{ mix background foreground 25% }} !important;
}

/* The gradient generator writes the window background inline on these two
   elements, so the override has to sit on them; -old is its crossfade source. */
#zen-browser-background,
#zen-toolbar-background {
  --zen-main-browser-background: {{ background }} !important;
  --zen-main-browser-background-toolbar: {{ background }} !important;
  --zen-main-browser-background-old: {{ background }} !important;
  --zen-main-browser-background-toolbar-old: {{ background }} !important;
}

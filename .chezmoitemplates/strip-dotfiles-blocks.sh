# Drop any previously-applied `-- >>> dotfiles: ... >>>` block and trailing
# blank lines from stdin. Matching the marker prefix, not the title, means a
# renamed block still replaces its old copy.
awk '
  /^-- >>> dotfiles: .* >>>$/ { skip = 1; next }
  skip && /^-- <<< dotfiles: .* <<<$/ { skip = 0; next }
  !skip { lines[++n] = $0; if (NF) last = n }
  END { for (i = 1; i <= last; i++) print lines[i] }
'

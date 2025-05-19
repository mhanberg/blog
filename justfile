default:
  just --list

clean:
  rm -rf _site

serve:
  mix tableau.server

sync-og-images:
  backblaze-b2 sync priv/og/ b2://BlogOgImages/og/

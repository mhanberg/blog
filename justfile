default:
  @just --list

clean:
  rm -rf _site

serve:
  mix tableau.server

regenerate-og-images:
  rm -rf ./priv/og
  @just generate-og-images

generate-og-images:
  mix tableau.og.run

preview-og-images: generate-og-images
  cp -a ./priv/og extra
  @just serve

sync-og-images:
  backblaze-b2 sync priv/og/ b2://BlogOgImages/og/

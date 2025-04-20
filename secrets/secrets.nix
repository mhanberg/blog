let
  nublar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFqwZQR1Z5Y9Tss3HvBN/bEPx5FthMjTHSuZhjmh+lu";
in {
  "GOODREADS_KEY.age".publicKeys = [nublar];
  "NETLIFY_AUTH_TOKEN.age".publicKeys = [nublar];
  "NETLIFY_SITE_ID.age".publicKeys = [nublar];
}

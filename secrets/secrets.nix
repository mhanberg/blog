let
  nublar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFqwZQR1Z5Y9Tss3HvBN/bEPx5FthMjTHSuZhjmh+lu";
  mitchells-mini = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsjkEoGKgTmwAHSum/rlv5b14+0/HMYMcinsUA3Ksq4";
  machines = [nublar mitchells-mini];
in {
  "GOODREADS_KEY.age".publicKeys = machines;
  "NETLIFY_AUTH_TOKEN.age".publicKeys = machines;
  "NETLIFY_SITE_ID.age".publicKeys = machines;
}

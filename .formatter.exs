# Used by "mix format"
[
  import_deps: [:temple],
  plugins: [TailwindFormatter.Temple],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]

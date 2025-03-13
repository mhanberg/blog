---
layout: Blog.PostLayout
title: "Introducing lazyasdf: An Elixir-based TUI for the asdf version manager"
date: 2023-03-06 01:00:00 EST
categories: post
permalink: /introducing-lazyasdf-a-tui-for-the-asdf-version-manager/
---

![lazyasdf](https://res.cloudinary.com/mhanberg/image/upload/v1678034860/CleanShot_2023-03-04_at_14.44.18_2x.png)

[lazyasdf](https://github.com/mhanberg/lazyasdf) is my first real* attempt at making a TUI with [Elixir](https://elixir-lang.org)! 

[asdf](https://asdf-vm.com/) is normally used through a _command line interface_ (CLI), `lazyasdf` presents you with a _terminal user interface_ (TUI) for working with `asdf`.

I recently fell in love with [lazygit](https://github.com/jesseduffield/lazygit) and have since dreamed of writing my own TUI programs, but with Elixir.

The TUI provides a quick and intuitive interface for those familiar with the terminal and for those who prefer a graphical application, but the TUI is so much more approachable in my humble opinion when it comes to making your own 😄.

While I find `lazyasdf` to be an amazing achievement for myself, it isn't _super_ interesting on its own. Let's dive into the specifics of how I was able to build and distribute a TUI application with Elixir.

## Ratatouille

None of this would be possible if it weren't for the library [ratatouille](https://github.com/ndreynolds/ratatouille) by [Nick Reynolds](https://ndreynolds.com/).

I am not some genius when it comes to terminals or laying out text, this all comes from Ratatouille, which builds off of [termbox](https://github.com/nsf/termbox), which is a [n]curses alternative.

Ratatouille leverages the [Elm Architecture](https://guide.elm-lang.org/architecture/) of which many of us have grown familiar. Let's take a look at a small Ratatouille program that showcases most of its features.

![Tuido](https://res.cloudinary.com/mhanberg/image/upload/v1678037282/CleanShot_2023-03-05_at_12.27.43_2x.png)

```elixir
#!/usr/bin/env elixir

Mix.install([:ratatouille])

defmodule Todos do
  @behaviour Ratatouille.App

  import Ratatouille.View
  import Ratatouille.Constants, only: [color: 1, key: 1]

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  @space key(:space)

  @impl true
  def init(_) do
    %{
      todo: %{
        items: %{"buy eggs" => false , "mow the lawn" => true, "get a haircut" => false},
        cursor_y: 0
      }
    }
  end

  @impl true
  def update(model, msg) do
    case msg do
      {:event, %{key: @space}} ->
        {todo, _done} = Enum.at(model.todo.items, model.todo.cursor_y)

        update_in(model.todo.items[todo], & !&1)

      {:event, %{ch: ?j}} ->
        update_in(model.todo.cursor_y, &cursor_down(&1, model.todo.items))

      {:event, %{ch: ?k}} ->
        update_in(model.todo.cursor_y, &cursor_up/1)

      _ ->
        model
    end
  end

  defp cursor_down(cursor, rows) do
    min(cursor + 1, Enum.count(rows) - 1)
  end

  defp cursor_up(cursor) do
    max(cursor - 1, 0)
  end

  @impl true
  def render(model) do
    view do
      panel title: "TODO" do
        for { {t, done}, idx } <- Enum.with_index(model.todo.items) do
          row do
            column size: 12 do
              label if(idx == model.todo.cursor_y, do: @style_selected, else: []) do
                text content: "- ["
                done(done)
                text content: "] #{t}"
              end
            end
          end
        end
      end
    end
  end

  defp done(true), do: text(content: "x")
  defp done(false), do: text(content: " ")
end

Ratatouille.run(Todos)
```

You should be able to copy the above snippet into a file, make it executable (`chmod + x`) and run it!

Ratatouille calls for 3 callbacks in your TUI program, `init/1`, `update/2`, and `render/1`.

- When the program boots up, the `init/1` callback is called and the return value becomes your initial model state.

- Whenever the TUI receives user input, the `update/2` callback is executed with the message and your current model state.

- When that returns, the runtime will call the `render/1` callback with the new model state.

  The `render/1` callback is full of macros which translate to element structs, so it's just an ergonomic DSL. Typing out many structs by hand would be a PITA!

### Notes

You have probably observed that, while it is high level compared to raw `termbox`, Ratatouille is still sort of "low level" as an application framework.

We still have to manually track and move our cursor position, as well as index into our data structures to pull out the right data for that position.

## Burrito

Now the normal problem with Elixir apps is that you have to have Elixir and Erlang on your machine to run them, as well as keep track of the version of them you have installed to make sure they are compatible, as well as write aliases to run escripts and Mix tasks, yada yada.

This is where [Burrito](https://github.com/burrito-elixir/burrito) comes in!

Burrito utilizes [Zig](https://ziglang.org/) to bundle up your application, the BEAM, and the Runtime all into one tidy executable that you can distribute at your leisure!

In the end, once we run `MIX_ENV=prod mix release`, Burrito will create binaries for each of our specified target platforms, and you can just copy those onto your computer and run them

The Burrito project is lead by [Digit](https://twitter.com/doawoo/).

## Homebrew

To make any program useful, it is help to be able to install it easily.

Homebrew is the primary way of accomplishing this on MacOS (my preferred operating system) and you can easily host your own collection of Homebrew packages with your own Tap!

Since `lazyasdf` has some quirky dependencies, the formula (what Homebrew calls a package definition) is a little interesting.

```ruby
class Lazyasdf < Formula
  desc "TUI for the asdf version manager"
  homepage "https://github.com/mhanberg/lazyasdf"
  url "https://github.com/mhanberg/lazyasdf/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "787da19809ed714c569c8bd7df58d55d7389b69efdf1859e57f713d18e3d2d05"
  license "MIT"

  bottle do
    root_url "https://github.com/mhanberg/homebrew-tap/releases/download/lazyasdf-0.1.1"
    sha256 cellar: :any_skip_relocation, monterey: "f489e328c19954d62284a7154fbc8da4e7a1df61dc963930d291361a7b2ca751"
  end

  depends_on "elixir" => :build
  depends_on "erlang" => :build
  depends_on "gcc" => :build
  depends_on "make" => :build
  depends_on "python@3.9" => :build
  depends_on "xz" => :build

  depends_on "asdf"

  on_macos do
    on_arm do
      resource "zig" do
        url "https://ziglang.org/download/0.10.0/zig-macos-aarch64-0.10.0.tar.xz"
        sha256 "02f7a7839b6a1e127eeae22ea72c87603fb7298c58bc35822a951479d53c7557"
      end
    end

    on_intel do
      resource "zig" do
        url "https://ziglang.org/download/0.10.0/zig-macos-x86_64-0.10.0.tar.xz"
        sha256 "3a22cb6c4749884156a94ea9b60f3a28cf4e098a69f08c18fbca81c733ebfeda"
      end
    end
  end

  def install
    zig_install_dir = buildpath/"zig"
    mkdir zig_install_dir
    resources.each do |r|
      r.fetch

      system "tar", "xvC", zig_install_dir, "-f", r.cached_download
      zig_dir =
        if Hardware::CPU.arm?
          zig_install_dir/"zig-macos-aarch64-0.10.0"
        else
          zig_install_dir/"zig-macos-x86_64-0.10.0"
        end

      ENV["PATH"] = "#{zig_dir}:" + ENV["PATH"]
    end

    ENV["PATH"] = (Formula["python@3.9"].opt_libexec/"bin:") + ENV["PATH"]

    system "mix", "local.hex", "--force"
    system "mix", "local.rebar", "--force"

    ENV["BURRITO_TARGET"] = if Hardware::CPU.arm?
      "macos_m1"
    else
      "macos"
    end

    ENV["MIX_ENV"] = "prod"
    system "mix", "deps.get"
    system "mix", "release"

    if OS.mac?
      if Hardware::CPU.arm?
        bin.install "burrito_out/lazyasdf_macos_m1" => "lazyasdf"
      else
        bin.install "burrito_out/lazyasdf_macos" => "lazyasdf"
      end
    end
  end

  test do
    # this is required for homebrew-core
    system "true"
  end
end
```

Here we can see all of `lazyasdf`'s dependencies.

It requires

- Elixir/Erlang: self-explanatory
- asdf: self-explanatory
- gcc,make: used to compile the termbox NIF bindings
- Python 3.9: The termbox NIF uses a python script. For some reason it works with 3.9 and not 3.11, so I pinned it at 3.9 🤷‍♂️.
- zig,xz: Burrito uses these two.
  
  Burrito specifically uses Zig 0.10.0, not 0.10.1, so we have to specify it as a resource and download it from the Zig website. Luckily, they provide pre-compiled binaries for both our our target platforms, so we can just download, untar, and add them to our PATH!

The Python dependency is even more quirky. The termbox scripts use the unversioned `python` executable, but Homebrew does not link those by default, so we have to manually add the unversioned one to our PATH for it to work.

Voilà!

### Notes

Since this is a 3rd party Tap, the bottles that are generated are for an older version of Intel Mac, so those won't be very useful to anybody.

But if I were to merge this formula into homebrew-core, they would be bottled using the secret Homebrew GitHub Actions runners that can bottle it for all the OS's and architectures.

## The Future

Ratatouille is incredible as it is today, but there is a lot of room for improvement.

As time allows, I hope to:

- Contribute to Ratatouille to allow more complex UI features like scrollbars and dynamic size information for elements.
- Create bindings for termbox2 (the next iteration of termbox).
- Create a higher level toolkit for building TUIs with Ratatouille, including menus, inputs, dialogs, etc.

Thanks for reading!

---

\* Previously, I have made a [fzf](https://github.com/junegunn/fzf) clone using Ratatouille. You can find it in my [dotfiles](https://github.com/mhanberg/.dotfiles/blob/ab07f27041780d1b54704ad4799382f58548468e/bin/fxf).

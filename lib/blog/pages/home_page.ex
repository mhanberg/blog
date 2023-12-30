defmodule Blog.HomePage do
  use Tableau.Page,
    layout: Blog.RootLayout,
    permalink: "/",
    title: "Mitchell Hanberg"

  import Blog

  def template(assigns) do
    ~L"""
    <div class="flex flex-col h-full items-center md:flex-row-reverse">
      <div class="md:w-1/2 md:pl-4">
        <div class="max-w-md mx-auto">
          <img class="rounded shadow-xl" src="https://res.cloudinary.com/mhanberg/image/upload/v1574047220/Becca___Mitch-67_copy.jpg">
        </div>

      </div>

      <div class="mt-4 max-w-lg md:w-1/2 md:pr-4">
        <h1 class="text-center md:text-left mt-12 md:mt-auto md:text-3xl lg:text-4xl">Senior Software Engineer</h1>
    {{"
    My name is Mitchell Hanberg and I am a senior software engineer from Indianapolis, IN.

    Lately I've been building backend distributed systems and Elixir developer tooling.

    I am the leader and author of the [elixir-tools](https://github.com/elixir-tools) family of developer tool, the maintainer of [Wallaby](https://www.github.com/elixir-wallaby/wallaby), and the author of [Temple](https://www.github.com/mhanberg/temple).

    ### Get in touch

    You can find me on [Twitter](https://twitter.com/mitchhanberg), [GitHub](https://github.com/mhanberg), and by [email](mailto:contact@mitchellhanberg.com).
    " | markdownify }}
      </div>
    </div>
    """
  end
end

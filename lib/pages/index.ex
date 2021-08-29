defmodule Blog.Pages.Index do
  use Tableau.Page

  def permalink(), do: "/"

  render do
    div class: "flex flex-col h-full items-center md:flex-row-reverse" do
      div class: "md:w-1/2 md:pl-4" do
        div class: "max-w-md mx-auto" do
          img class: "rounded shadow-xl",
              src:
                "https://res.cloudinary.com/mhanberg/image/upload/v1574047220/Becca___Mitch-67_copy.jpg"
        end
      end

      div class: "mt-4 max-w-lg md:w-1/2 md:pr-4" do
        h1 class: "text-center md:text-left mt-12 md:mt-auto md:text-3xl lg:text-5xl",
           do: "Full Stack Developer"

        c Blog.Markdown,
          markdown: """
          Hello!

          My name is Mitchell Hanberg and I am a full stack developer from Indianapolis, IN.

          Lately I've been building web applications with a focus on team productivity, collaboration and good design.

          I currently maintain [Wallaby](https://www.github.com/elixir-wallaby/wallaby) and am the creator of [Temple](https://www.github.com/mhanberg/temple).

          Sometimes I tweet 🔥 tips on [Twitter](https://twitter.com/i/moments/1197346199378022401?s=13).

          Check out what software and tools I use on my [Wes Bos](https://wesbos.com/uses) inspired [Uses](/uses) page.

          ### Get in touch

          You can find me on [Twitter](https://twitter.com/mitchhanberg), [GitHub](https://github.com/mhanberg), and by [email](mailto:contact@mitchellhanberg.com).
          """
      end
    end
  end
end

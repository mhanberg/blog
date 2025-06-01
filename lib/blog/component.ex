defmodule Blog.Component do
  use Temple.Component

  defmacro __using__(_) do
    quote do
      import Temple
      import unquote(__MODULE__)
    end
  end

  def convertkit(_assigns) do
    temple do
      if Mix.env() == :prod do
        iframe width: "100%", height: "211px", src: "/convertkit"
      end
    end
  end

  def subscribe(_assigns) do
    temple do
      "<!-- newsletter -->"

      style do
        """
        .my-4 {
          margin-top: 1rem;
          margin-bottom: 1rem;
        }
        .mx-auto {
          margin-left: auto;
          margin-right: auto;
        }
        .flex {display: flex;}
        .justify-center{
          justify-content: center;
        }
        .flex-grow-inside > * {
          flex-grow: 1;
        }
        .w-full {
          width: 100%;
        }

        """
      end

      div class: "w-full my-4 mx-auto flex justify-center flex-grow-inside" do
        script async: true,
               "data-uid": "179cec943d",
               src: "https://dogged-composer-1540.kit.com/179cec943d/index.js"
      end

      "<!--/ newsletter -->"
    end
  end

  def date(assigns) do
    temple do
      span do
        Calendar.strftime(@date, "%b %d, %Y")
      end
    end
  end

  def reading_time(assigns) do
    temple do
      span do
        Blog.reading_time(@content)
        "minute read"
      end
    end
  end

  def tags(assigns) do
    temple do
      for tag <- @tags do
        a href: Path.join("/tags", tag) do
          "#" <> tag
        end
      end
    end
  end

  def prose(assigns) do
    temple do
      section class: "prose prose-invert prose-a:text-fallout-green max-w-4xl mx-auto" do
        slot @inner_block
      end
    end
  end

  def link(assigns) do
    temple do
      a href: @href, class: "text-fallout-green underline #{assigns[:class]}" do
        slot @inner_block
      end
    end
  end

  def search(assigns) do
    temple do
      svg xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewbox: "0 0 24 24",
          stroke_width: "2",
          stroke: "currentColor",
          class: @class do
        path stroke_linecap: "round",
             stroke_linejoin: "round",
             d: "m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" do
        end
      end
    end
  end

  def folder(assigns) do
    temple do
      svg xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewbox: "0 0 24 24",
          stroke_width: "1.5",
          stroke: "currentColor",
          class: @class do
        path stroke_linecap: "round",
             stroke_linejoin: "round",
             d:
               "M2.25 12.75V12A2.25 2.25 0 0 1 4.5 9.75h15A2.25 2.25 0 0 1 21.75 12v.75m-8.69-6.44-2.12-2.12a1.5 1.5 0 0 0-1.061-.44H4.5A2.25 2.25 0 0 0 2.25 6v12a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18V9a2.25 2.25 0 0 0-2.25-2.25h-5.379a1.5 1.5 0 0 1-1.06-.44Z" do
        end
      end
    end
  end

  def link_icon(assigns) do
    temple do
      svg xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewbox: "0 0 24 24",
          stroke_width: "1.5",
          stroke: "currentColor",
          class: @class do
        path stroke_linecap: "round",
             stroke_linejoin: "round",
             d:
               "M13.19 8.688a4.5 4.5 0 0 1 1.242 7.244l-4.5 4.5a4.5 4.5 0 0 1-6.364-6.364l1.757-1.757m13.35-.622 1.757-1.757a4.5 4.5 0 0 0-6.364-6.364l-4.5 4.5a4.5 4.5 0 0 0 1.242 7.244" do
        end
      end
    end
  end
end

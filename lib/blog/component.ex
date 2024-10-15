defmodule Blog.Component do
  use Temple.Component

  defmacro __using__(_) do
    quote do
      import Temple
      import unquote(__MODULE__)
    end
  end

  def subscribe(_assigns) do
    temple do
      "<!-- newsletter -->"

      div class: "my-4 mx-auto flex justify-center *:flex-grow" do
        script async: true,
               "data-uid": "179cec943d",
               src: "https://dogged-composer-1540.ck.page/179cec943d/index.js"
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
        Blog.Filters.reading_time(@content)
        "minute read"
      end
    end
  end

  def folder(_assigns) do
    temple do
      svg xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewbox: "0 0 24 24",
          stroke_width: "1.5",
          stroke: "currentColor",
          class: "size-6" do
        path stroke_linecap: "round",
             stroke_linejoin: "round",
             d:
               "M2.25 12.75V12A2.25 2.25 0 0 1 4.5 9.75h15A2.25 2.25 0 0 1 21.75 12v.75m-8.69-6.44-2.12-2.12a1.5 1.5 0 0 0-1.061-.44H4.5A2.25 2.25 0 0 0 2.25 6v12a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18V9a2.25 2.25 0 0 0-2.25-2.25h-5.379a1.5 1.5 0 0 1-1.06-.44Z" do
        end
      end
    end
  end
end

defmodule Blog.Footer do
  import Temple.Component

  render do
    footer class: "container mt-8" do
      p class: "text-center text-xs" do
        "built with"

        a href: "https://jekyllrb.com/",
          target: "_blank",
          rel: "noreferrer",
          class: "underline" do
          "Jekyll"
        end

        ","

        a href: "https://tailwindcss.com/",
          target: "_blank",
          rel: "noreferrer",
          class: "underline" do
          "TailwindCSS"
        end

        ", and"

        a href: "https://github.com/mhanberg/blog",
          target: "_blank",
          rel: "noreferrer",
          class: "text-red-light underline" do
          "♥"
        end
      end
    end
  end
end

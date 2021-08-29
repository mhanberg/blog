defmodule Blog.NavItems do
  import Temple.Component

  render do
    a! class: "py-3 tracking-wide no-underline hover:underline", href: "/articles" do
      "Articles"
    end

    a! class: "py-3 tracking-wide no-underline hover:underline", href: "/projects" do
      "Projects"
    end

    a! class: "py-3 tracking-wide no-underline hover:underline", href: "/bookshelf" do
      "Bookshelf"
    end

    a! class: "py-3 tracking-wide no-underline hover:underline", href: "/newsletter" do
      "Newsletter"
    end
  end
end

defmodule Blog.Markdown do
  import Temple.Component

  import Phoenix.HTML

  render do
    raw(Earmark.as_html!(@markdown))
  end
end

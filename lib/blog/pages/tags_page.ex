defmodule Blog.TagsPage do
  use Tableau.Page,
    layout: Blog.SidebarLayout,
    permalink: "/tags",
    title: "Tags"

  use Blog.Component

  def template(assigns) do
    tags = Enum.sort_by(assigns.tags, fn {_, p} -> length(p) end, :desc)
    assigns = Map.put(assigns, :tags, tags)

    temple do
      c &prose/1 do
        h1 class: "text-4xl", do: "Tags"

        ul do
          for {tag, posts} <- @tags do
            li do
              a href: tag.permalink do
                tag.tag
              end

              span do
                "- #{length(posts)}"
              end
            end
          end
        end
      end
    end
  end
end

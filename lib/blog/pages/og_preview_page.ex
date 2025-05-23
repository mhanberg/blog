if Mix.env() == :dev do
  defmodule Blog.OgPreviewPage do
    use Tableau.Page,
      layout: Blog.SidebarLayout,
      permalink: "/og-preview",
      title: "OG Preview"

    use Blog.Component

    def template(assigns) do
      # run the follow
      # `cp -a ./priv/og extra`
      og_images = Path.wildcard("./extra/og/**/*.png")

      assigns = Map.put(assigns, :og_images, og_images)

      temple do
        c &prose/1 do
          h1 class: "text-4xl", do: "OG Preview"

          ul do
            for path <- @og_images do
              li do
                img src: String.replace_prefix(path, "extra", "")
              end
            end
          end
        end
      end
    end
  end
end

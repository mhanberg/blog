defmodule Blog.RootLayout do
  use Tableau.Layout
  use Blog.Component

  def template(assigns) do
    temple do
      "<!DOCTYPE html>"

      html lang: "en", class: "scroll-smooth" do
        head do
          title do
            @page.title <> " | Mitchell Hanberg"
          end

          meta name: "viewport", content: "width=device-width, initial-scale=1.0"
          meta charset: "utf-8"

          link type: "application/rss+xml",
               rel: "alternate",
               href: "https://www.mitchellhanberg.com/feed.xml",
               title: "Mitchell Hanberg"

          link rel: "stylesheet", href: "/css/site.css"
          link rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png"
          link rel: "icon", type: "image/png", sizes: "32x32", href: "/favicon-32x32.png"
          link rel: "icon", type: "image/png", sizes: "16x16", href: "/favicon-16x16.png"

          script type: "module", src: "/js/index.js"

          meta name: "twitter:card", content: "summary_large_image"

          meta property: "og:image", content: @page.permalink |> Blog.og_image_url()
          # meta property: "twitter:image", content: @page.seo.image
          # meta property: "twitter:title", content: @page.title
          meta name: "twitter:site", content: "@mitchhanberg"
          meta name: "twitter:creator", content: "@mitchhanberg"
        end

        body class: "font-mono bg-black text-white text-[16px]" do
          main do
            render(@inner_content)
          end

          if Mix.env() == :prod do
            "<!-- Plausible Analytics -->"
            script defer: true, "data-domain": "mitchellhanberg.com", src: "/js/foo.js"
            "<!-- / Plausible -->"
          end

          if Mix.env() == :dev do
            c &Tableau.live_reload/1
          end
        end
      end
    end
  end
end

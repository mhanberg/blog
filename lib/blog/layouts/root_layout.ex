defmodule Blog.RootLayout do
  use Tableau.Layout
  use Blog.Component

  def template(assigns) do
    temple do
      "<!DOCTYPE html>"

      html lang: "en" do
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

          # link rel: "stylesheet", href: "https://rsms.me/inter/inter.css"
          link rel: "preconnect", href: "https://fonts.googleapis.com"
          link rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true

          link href: "https://fonts.googleapis.com/css2?family=Jersey+25&display=swap",
               rel: "stylesheet"

          link href:
                 "https://fonts.googleapis.com/css2?family=Fira+Code:wght@300..700&display=swap",
               rel: "stylesheet"

          ~s|<link href="https://fonts.googleapis.com/css2?family=VT323&display=swap" rel="stylesheet">|

          link rel: "stylesheet", href: "/css/site.css"
          link rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png"
          link rel: "icon", type: "image/png", sizes: "32x32", href: "/favicon-32x32.png"
          link rel: "icon", type: "image/png", sizes: "16x16", href: "/favicon-16x16.png"

          script type: "module", src: "/js/index.js"

          meta name: "twitter:card", content: "summary_large_image"

          meta property: "og:image", content: @page.permalink |> Blog.Filters.og_image_url()
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

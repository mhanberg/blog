defmodule Blog.RootLayout do
  use Tableau.Layout
  use Blog.Component
  import Tableau.Document.Helper

  def template(assigns) do
    temple do
      html lang: "en" do
        head do
          title do
            @page.title
          end

          meta name: "viewport", content: "width=device-width, initial-scale=1.0"
          meta charset: "utf-8"

          link type: "application/rss+xml",
               rel: "alternate",
               href: "https://www.mitchellhanberg.com/feed.xml",
               title: "Mitchell Hanberg"

          link rel: "stylesheet", href: "https://rsms.me/inter/inter.css"
          link rel: "stylesheet", href: "/css/site.css"
          link rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png"
          link rel: "icon", type: "image/png", sizes: "32x32", href: "/favicon-32x32.png"
          link rel: "icon", type: "image/png", sizes: "16x16", href: "/favicon-16x16.png"

          script src: "/js/site.js"

          script src: "https://cdn.jsdelivr.net/gh/alpinejs/alpine@v2.3.5/dist/alpine.min.js",
                 defer: true

          script src:
                   "https://cdn.jsdelivr.net/npm/algoliasearch@4.0.0/dist/algoliasearch-lite.umd.js",
                 integrity: "sha256-MfeKq2Aw9VAkaE9Caes2NOxQf6vUa8Av0JqcUXUGkd0=",
                 crossorigin: "anonymous"

          script src:
                   "https://cdn.jsdelivr.net/npm/instantsearch.js@4.0.0/dist/instantsearch.production.min.js",
                 integrity: "sha256-6S7q0JJs/Kx4kb/fv0oMjS855QTz5Rc2hh9AkIUjUsk=",
                 crossorigin: "anonymous"

          meta name: "twitter:card", content: "summary_large_image"

          meta property: "og:image", content: @page.permalink |> Blog.Filters.og_image_url()
          # meta property: "twitter:image", content: @page.seo.image
          # meta property: "twitter:title", content: @page.title
          meta name: "twitter:site", content: "@mitchhanberg"
          meta name: "twitter:creator", content: "@mitchhanberg"
        end

        body class: "" do
          div id: "the-universe", class: "" do
            c &header/1

            main class: "container" do
              render(@inner_content)
            end

            c &footer/1
          end

          if Mix.env() == :prod do
            c &analytics/1
          end

          if Mix.env() == :dev do
            c &Tableau.live_reload/1
          end
        end
      end
    end
  end

  defp header _assigns do
    temple do
    end
  end

  defp footer _assigns do
    temple do
    end
  end

  defp analytics(_assigns) do
    temple do
    end
  end
end

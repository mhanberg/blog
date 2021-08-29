defmodule Blog.Layouts.App do
  use Tableau.Layout

  render do
    "<!DOCTYPE html>"

    html lang: "en" do
      head do
        meta charset: "utf-8"
        meta http_equiv: "X-UA-Compatible", content: "IE=edge"
        meta name: "viewport", content: "width=device-width, initial-scale=1.0"

        link rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png"
        link rel: "icon", type: "image/png", sizes: "32x32", href: "/favicon-32x32.png"
        link rel: "icon", type: "image/png", sizes: "16x16", href: "/favicon-16x16.png"

        link rel: "stylesheet", href: "https://rsms.me/inter/inter.css"
        link rel: "stylesheet", href: "/css/site.css"

        script! src: "/js/site.js"

        script! src: "https://cdn.jsdelivr.net/gh/alpinejs/alpine@v2.3.5/dist/alpine.min.js",
               defer: true

        script! src:
                 "https://cdn.jsdelivr.net/npm/algoliasearch@4.0.0/dist/algoliasearch-lite.umd.js",
               integrity: "sha256-MfeKq2Aw9VAkaE9Caes2NOxQf6vUa8Av0JqcUXUGkd0=",
               crossorigin: "anonymous"

        script! src:
                 "https://cdn.jsdelivr.net/npm/instantsearch.js@4.0.0/dist/instantsearch.production.min.js",
               integrity: "sha256-6S7q0JJs/Kx4kb/fv0oMjS855QTz5Rc2hh9AkIUjUsk=",
               crossorigin: "anonymous"
      end

      body class: "font-sans" do
        div id: "the-universe" do
          c Blog.Header

          main class: "container" do
            slot :default
          end

          c Blog.Footer
        end
      end

      # if Mix.env() == :prod do
      #   c Blog.Analytics
      # end

      # c Blog.Search

      if Mix.env() == :dev do
        c Tableau.Components.LiveReload
      end
    end
  end
end

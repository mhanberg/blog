defmodule Blog.RootLayout do
  import Blog
  use Tableau.Layout

  def template(assigns) do
    ~L"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <title>{{ page.title }}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta charset="utf-8" />
        <link type="application/rss+xml" rel="alternate" href="https://www.mitchellhanberg.com/feed.xml" title="Mitchell Hanberg" />
        <link rel="stylesheet" href="https://rsms.me/inter/inter.css" />
        <link rel="stylesheet" href="/css/site.css" />

        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />

        <script src="/js/site.js"></script>

        <script
          src="https://cdn.jsdelivr.net/gh/alpinejs/alpine@v2.3.5/dist/alpine.min.js"
          defer
        ></script>
        <script
          src="https://cdn.jsdelivr.net/npm/algoliasearch@4.0.0/dist/algoliasearch-lite.umd.js"
          integrity="sha256-MfeKq2Aw9VAkaE9Caes2NOxQf6vUa8Av0JqcUXUGkd0="
          crossorigin="anonymous"
        ></script>
        <script
          src="https://cdn.jsdelivr.net/npm/instantsearch.js@4.0.0/dist/instantsearch.production.min.js"
          integrity="sha256-6S7q0JJs/Kx4kb/fv0oMjS855QTz5Rc2hh9AkIUjUsk="
          crossorigin="anonymous"
        ></script>
        <meta name="twitter:card" content="{{ page.twitter.card | default: site.twitter.card | default: "summary_large_image" }}" />

        <meta property="og:image" content="{{ page.permalink | og_image_url }}" />
        <meta property="twitter:image" content="{{ page.seo.image }}" />

        <meta property="twitter:title" content="{{ page.title }}" />
        <meta name="twitter:site" content="@mitchhanberg" />
        <meta name="twitter:creator" content="@mitchhanberg" />
      </head>
      <body>
        <div id="the-universe">
          {% render "header" %}
          <main class="container">{{ inner_content | render }}</main>
          {% render "footer" %}
        </div>

        {% if tableau.environment == 'prod' %}
        {% render "analytics" %}
        {% endif %}
        {% render "search" %}
        {{ tableau.environment | reload }}
      </body>
    </html>
    """
  end
end

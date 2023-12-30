defmodule Blog.ArticlesPage do
  use Tableau.Page,
    layout: Blog.RootLayout,
    permalink: "/articles",
    title: "Articles | Mitchell Hanberg"

  import Blog

  def template(assigns) do
    ~L"""
    <section class="max-w-2xl mx-auto mb-8">
      <h1 class="md:text-5xl">Articles</h1>

      <p class="text-sm md:mb-8 mt-2">
        Subscribe to my mailing list <a href="/newsletter">mailing list</a> or
        <a href="/feed.xml">RSS</a> feed to stay notified of new articles.
      </p>

      {% for post in posts %}
      <article class="mt-8">
        <a
          class="block text-xl md:text-2xl text-white no-underline"
          href="{{ post.permalink }}"
        >
          {{ post.title }}
        </a>
        <div class="text-sm italic mb-4">
          {{ post.date | date: "%b %d, %Y" }} • {{ post | reading_time }}
        </div>
      </article>
      {% endfor %}
    </section>
    """
  end
end

defmodule Blog.NewsletterPage do
  use Tableau.Page,
    layout: Blog.RootLayout,
    permalink: "/newsletter",
    title: "Newsletter | Mitchell Hanberg"

  import Blog

  def template(assigns) do
    ~L"""
    <div class="max-w-2xl mx-auto">
      <h1 class="md:text-5xl md:mb-8">Newsletter</h1>

    {{"
    I like to work, talk, and write about Elixir, compilers, productivity, building awesome teams, and shipping great products.

    **If any of that resonates with you, sign up for my newsletter and follow along!**
    " | markdownify}}

      <p class="text-sm">I seldom send emails quite, and I will <strong class="font-semibold">never</strong> share your email address with anyone else.</p>

      <div class="bg-evergreen-800 px-4 pt-4 rounded mt-4">
        {% render "subscribe" %}
      </div>
    </div>
    """
  end
end

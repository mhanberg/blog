defmodule Blog.UsesPage do
  use Tableau.Page,
    layout: Blog.RootLayout,
    permalink: "/uses",
    title: "Uses | Mitchell Hanberg"

  import Blog

  def template(assigns) do
    ~L"""
    <section class="max-w-2xl m-auto">
      <h1>Uses</h1>

      <p>
        No one ever asks me what font or syntax theme I use, but nevertheless here
        we are.
      </p>

      {% for category in data.uses %}
      <h2>{{ category.name }}</h2>
      <ul class="px-1">
        {% for entry in category.entries %}
        <li class="list-none">
          <div class="pl-5">
            <span id="{{ entry.name | slugify }}" class="text-white font-semibold">
              <a href="{{entry.link}}" target="_blank">{{ entry.name }}</a>
            </span>
          </div>
        </li>
        {% endfor %}
      </ul>
      {% endfor %}
    </section>
    """
  end
end

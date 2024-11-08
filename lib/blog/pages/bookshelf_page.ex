defmodule Blog.BookshelfPage do
  use Tableau.Page,
    layout: Blog.RootLayout,
    permalink: "/bookshelf",
    title: "Bookshelf | Mitchell Hanberg"

  import Blog

  def template(assigns) do
    ~L"""
    <div class="max-w-2xl mx-auto">
      <h1 class="md:text-5xl" >Bookshelf</h1>
    {{ "
    Reading has been one of my favorite hobbies ever since I was a kid. If you have any book suggestions or want to know how I felt about a book, hit me up on [Twitter](https://twitter.com/mitchhanberg)!

    I pull this data from my [Goodreads](https://www.goodreads.com/review/list/69703261) account once a day.
    " | markdownify }}
    </div>
    {% assign currently_reading = data.books | where: "currently_reading", true %}
    <h2 class="text-center underline mt-16">Currently Reading</h2>
    <div class="book-grid mt-8">
    {% for book in currently_reading %}
      <div class="p-4 rounded bg-evergreen-700 flex flex-col justify-between">
        <div class="flex justify-between">
          <div class="max-w-xs2">
            <span> {{ book.title }} </span>
            <div class="text-sm italic">{{ book.author }}</div>
          </div>
        </div>
        <div class="flex justify-between mt-4">
          <a class="text-sm text-white font-normal"
             href="{{ book.link | default: "#" }}" target="_blank">
            View on Goodreads
          </a>
        {% assign post = book.id | get_review: posts %}
        {% if post %}
        <a class="text-sm text-white font-normal" href="{{ post.url }}">Read my review</a>
        {% endif %}
        </div>
      </div>
    {% endfor %}
    </div>

    {% assign years = data.books | where: "currently_reading", false | group_by_year %}
    {% for year in years %}
      <h2 class="text-center underline mt-16">{{ year[0] }}</h2>

      <div class="book-grid mt-8">
        {% for book in year[1] %}
            <div class="p-4 rounded bg-evergreen-700 flex flex-col justify-between">
              <div class="flex justify-between">
                <div class="max-w-xs2">
                  <span> {{ book.title }} </span>
                  <div class="text-sm italic">{{ book.author }}</div>
                  <div class="text-sm italic">Read {{ book.date_read | date_to_string: "ordinal", "US" }}</div>
                </div>
              </div>
              <div class="flex justify-between mt-4">
                <a class="text-sm text-white font-normal"
                   href="{{ book.link | default: "#" }}" target="_blank">
                  View on Goodreads
                </a>
              {% assign post = book.id | get_review: posts %}
              {% if post %}
              <a class="text-sm text-white font-normal" href="{{ post.url }}">Read my review</a>
              {% endif %}
              </div>
            </div>
          {% endfor %}
        </div>
    {% endfor %}
    """
  end
end

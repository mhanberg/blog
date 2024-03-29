defmodule Blog.BookReviewLayout do
  import Blog
  use Tableau.Layout, layout: Blog.PostLayout

  def template(assigns) do
    ~L"""
    <div class="flex flex-col-reverse sm:flex-row justify-around">
      <span class="sm:w-1/2 px-4 mt-4 md:mt-auto">
        <img
          src="{{ '/images/' | append: page.book.cover }}"
          alt="{{ page.book.cover_alt }}"
        />
      </span>
      <div class="px-4">
        <h3>
          <a href="{{ data.links | book_url: page.book.goodreads_id }}">
            {{ page.book.title }}
          </a>
        </h3>
        <h4>By {{ page.book.author }}</h4>
        <p>ISBN: {{ page.book.isbn }}</p>
        <br />
        <span>Recommendation:</span><b> {{ page.book.recommendation }} </b>
      </div>
    </div>

    <hr />

    {{ inner_content | render }}
    """
  end
end

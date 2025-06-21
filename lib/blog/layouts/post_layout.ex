defmodule Blog.PostLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout
  use Blog.Component
  import MDEx.Sigil

  def template(assigns) do
    temple do
      c &prose/1 do
        h1 class: "text-3xl" do
          @page.title
        end

        div class: "flex flex-wrap gap-4 text-white text-sm" do
          c &date/1, date: @page.date
          c &reading_time/1, content: @page.body
          c &tags/1, tags: @page[:tags] || []
        end

        if @page[:reviewers] do
          p do
            "Thank you to #{Blog.array_to_sentence_string(@page.reviewers)} for reviewing this article."
          end
        end

        hr class: "!w-full border-fallout-green"

        if @page[:book] do
          ~MD"""
          **Title**: [<%= @page.book.title %>](https://goodreads.com/book/show/<%= @page.book.goodreads_id %>)

          **Author**: <%= @page.book.author %>

          **Recommendation**: <%= @page.book.recommendation %>
          """HTML
        end

        render(@inner_content)

        hr class: "!w-full"

        div class: "text-center mx-auto" do
          c &convertkit/1
        end
      end
    end
  end
end

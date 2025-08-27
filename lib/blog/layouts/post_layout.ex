defmodule Blog.PostLayout do
  use Tableau.Layout, layout: Blog.SidebarLayout
  use Blog.Component
  import MDEx.Sigil

  defp toc(assigns) do
    temple do
      style do
        """
        #toc {
          ol {
            counter-reset: index;
            list-style-type: none;
          }

          li::before {
            counter-increment: index;
            content: counters(index, ".", decimal) " ";
          }
        }
        """
      end

      if @toc != [] do
        details id: "toc", class: "mt-4" do
          summary class: "font-fancy text-lg marker:text-fallout-green" do
            "Table of Contents"
          end

          c &toc_list/1, headings: @toc
        end
      end
    end
  end

  defp toc_list(assigns) do
    temple do
      ol do
        for {heading, children} <- @headings do
          li do
            a href: "##{heading.anchor}" do
              heading.text
            end

            if children != [] do
              c &toc_list/1, headings: children
            end
          end
        end
      end
    end
  end

  def template(assigns) do
    temple do
      c &prose/1, id: "article" do
        h1 class: "text-3xl" do
          @page.title
        end

        div class: "flex flex-wrap gap-4 text-sm text-white" do
          c &date/1, date: @page.date
          c &reading_time/1, content: @page.body
          c &tags/1, tags: @page[:tags] || []
        end

        if @page[:reviewers] do
          p do
            "Thank you to #{Blog.array_to_sentence_string(@page.reviewers)} for reviewing this article."
          end
        end

        c &toc/1, toc: @page.toc

        hr class: "!w-full border-fallout-green"

        if @page[:book] do
          ~MD"""
          **Title**: <a href="https://goodreads.com/book/show/<%= @page.book.goodreads_id %>"><%= @page.book.title %></a>

          **Author**: <%= @page.book.author %>

          **Recommendation**: <%= @page.book.recommendation %>
          """HTML
        end

        render(@inner_content)

        hr class: "!w-full"

        div class: "mx-auto text-center" do
          c &convertkit/1
        end
      end
    end
  end
end

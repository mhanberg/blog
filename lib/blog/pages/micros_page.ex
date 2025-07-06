defmodule Blog.MicrosPage do
  use Tableau.Page,
    layout: Blog.PageLayout,
    permalink: "/micros",
    title: "Micros"

  use Blog.Component

  def template(assigns) do
    temple do
      section class: "mx-auto mb-8" do
        Blog.markdownify("""
        # Micros

        I rolled my own X dot com, but it's write-only and no one will ever read it (no ads or scams though).

        If you _really_ want to read it, you can subscribe to the [RSS feed](/micros.xml) of _only_ the yapping.
        """)

        hr()

        div class: "mx-auto max-w-2xl" do
          for post <- @posts, "micro-post" in (post[:tags] || []) do
            article class:
                      "micro px-4 py-4 prose-headings:first:mt-0 prose-p:last:mb-0 border border-fallout-green border-t-0 first:border-t" do
              div class: "flex m-0 gap-4 items-start" do
                img src:
                      "https://res.cloudinary.com/mhanberg/image/upload/v1574047220/Becca___Mitch-67_copy.jpg",
                    class: "!m-0 object-contain size-8 rounded-full"

                div class: "w-full" do
                  div class: "flex justify-between gap-4 text-sm" do
                    div class: "flex items-center gap-4" do
                      div do
                        "Mitchell Hanberg"
                      end

                      div title: Calendar.strftime(post.date, "%B %d, %Y %H:%M %Z"),
                          class: "italic text-zinc-400 timeago",
                          datetime: DateTime.to_unix(post.date, :millisecond)
                    end

                    a href: post.permalink do
                      c &share/1, class: "size-6 text-white hover:text-fallout-green"
                    end
                  end

                  div do
                    Blog.markdownify(post.body)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

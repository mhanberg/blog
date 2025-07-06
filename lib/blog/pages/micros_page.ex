defmodule Blog.MicrosPage do
  use Tableau.Page,
    layout: Blog.SidebarLayout,
    permalink: "/micros",
    title: "Micros"

  use Blog.Component

  def template(assigns) do
    temple do
      c &prose/1, container: false do
        section class: "mx-auto mb-8" do
          div class: "container" do
            Blog.markdownify("""
            # Micros

            I rolled my own X dot com, but it's write-only and no one will ever read it (no ads or scams though).

            If you _really_ want to read it, you can subscribe to the [RSS feed](/micros.xml) of _only_ the yapping.
            """)
          end

          hr()

          div class: "mx-auto w-full sm:max-w-2xl" do
            for post <- @posts, "micro-post" in (post[:tags] || []) do
              article class:
                        "micro border-fallout-green border border-x-0 border-t-0 px-1 py-4 first:border-t first:prose-headings:mt-0 last:prose-p:mb-0 sm:border-x-1 sm:px-4" do
                div class: "m-0 flex items-start gap-4" do
                  img src:
                        "https://res.cloudinary.com/mhanberg/image/upload/v1574047220/Becca___Mitch-67_copy.jpg",
                      class: "!m-0 size-8 rounded-full object-contain"

                  div class: "w-full" do
                    div class: "flex justify-between gap-4 text-sm" do
                      div class: "flex w-full items-center gap-2 sm:gap-4" do
                        div do
                          "Mitchell Hanberg"
                        end

                        div title: Calendar.strftime(post.date, "%B %d, %Y %H:%M %Z"),
                            class: "timeago italic text-zinc-400",
                            datetime: DateTime.to_unix(post.date, :millisecond)
                      end

                      a href: post.permalink do
                        c &share/1, class: "size-6 text-white hover:text-fallout-green"
                      end
                    end

                    div class: "text-sm sm:text-base" do
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
end

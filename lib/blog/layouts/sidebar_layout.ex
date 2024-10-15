defmodule Blog.SidebarLayout do
  use Tableau.Layout, layout: Blog.RootLayout
  use Blog.Component

  def is_current_page(posts, "/articles", path) do
    path == "/articles" or path in Enum.map(posts, & &1.permalink)
  end

  def is_current_page(_posts, pattern, path) do
    pattern == path
  end

  def nav assigns do
    temple do
      aside id: "nav",
            class: [{@class, true}, "lg:mt-8 lg:sticky lg:top-8 lg:self-start pb-4": true] do
        h2 class: "text-2xl mb-2 flex gap-1" do
          div class: "flex-shrink-0", do: "Mitchell Hanberg > "

          div class: "flex bg-black flex-1 w-full flex-grow" do
            div id: "terminal", class: "outline-none caret-transparent", contenteditable: true

            div class: "animate-pulse w-full flex-1", onclick: "terminal.focus()", do: "▌"
          end
        end

        ul class: [{@item_width, true}, "text-2xl lg:text-lg": true] do
          for item <- @data["sidebar"] do
            li class: [
                 "border-l-4 pl-2": true,
                 "border-hacker bg-[#2B332D]":
                   is_current_page(@posts, item["permalink"], @page.permalink),
                 "border-transparent":
                   not is_current_page(@posts, item["permalink"], @page.permalink)
               ] do
              a href: item["permalink"] do
                item["name"]
              end
            end
          end
        end
      end
    end
  end

  def template(assigns) do
    temple do
      div class: "fixed lg:hidden top-6 right-6 z-50" do
        button type: "button",
               onclick:
                 "mobilenav.classList.toggle('hidden'); mobilenav.classList.toggle('fixed')" do
          c &folder/1
        end
      end

      # div id: "mobilenav", class: "hidden bg-black z-40 w-screen px-8" do
      #   c &nav/1,
      #     page: @page,
      #     posts: @posts,
      #     data: @data,
      #     class: "w-full",
      #     item_width: "w-full"
      # end

      div class: "min-h-screen container flex" do
        div class: "hidden lg:block" do
          c &nav/1,
            page: @page,
            posts: @posts,
            data: @data,
            class: "w-[400px]",
            item_width: "max-w-[200px]"
        end

        main class: "min-h-screen grid grid-rows-[auto_1fr_auto] grid-cols-[100%] flex-1" do
          div class: "h-8" do
          end

          div do
            render(@inner_content)
          end

          c &footer/1
        end
      end
    end
  end

  def footer _assigns do
    temple do
      footer class: "text-center my-16" do
        p class: "text-xs" do
          "built with"

          a href: "https://github.com/elixir-tools/tableau",
            target: "_blank",
            rel: "noreferrer",
            class: "underline" do
            "Tableau"
          end

          ","

          a href: "https://tailwindcss.com/",
            target: "_blank",
            rel: "noreferrer",
            class: "underline" do
            "TailwindCSS"
          end

          ", and"

          a href: "https://github.com/mhanberg/blog",
            target: "_blank",
            rel: "noreferrer",
            class: "text-red-light underline" do
            "♥"
          end

          #  this is a hidden thing to identify me on mastodon 
          a class: "hidden", rel: "me", href: "https://hachyderm.io/@mitchhanberg" do
            "Mastodon"
          end
        end
      end
    end
  end
end

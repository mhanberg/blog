defmodule Blog.SidebarLayout do
  use Tableau.Layout, layout: Blog.RootLayout
  use Blog.Component

  def is_current_page(posts, "/articles", path) do
    path == "/articles" or path in Enum.map(posts, & &1.permalink)
  end

  def is_current_page(_posts, pattern, path) do
    pattern == path
  end

  defp encode_data(data) do
    Jason.encode!(data)
  end

  def nav assigns do
    temple do
      aside id: "nav",
            "x-data": "sidebar",
            "@keydown.ctrl.p.window": "terminal.focus()",
            class:
              "lg:mt-8 lg:sticky lg:top-8 lg:self-start pb-4 border border-hacker rounded p-1" do
        h2 class: "font-mono mb-2 flex gap-1 border-b border-zinc-500 py-1" do
          div class: "flex-shrink-0", do: "~/mitchell-hanberg/"

          div class: "flex bg-black flex-1 w-full flex-grow" do
            input "x-model": "search",
                  id: "terminal",
                  "x-effect": "items = fzf.find(search)",
                  "@keyup.enter": "location.assign(items.at(selected_row).item.permalink)",
                  "@keydown.escape.prevent": "search = ''; terminal.blur();",
                  "@keydown.up.prevent": "selected_row = Math.max(selected_row - 1, 0)",
                  "@keydown.down.prevent":
                    "selected_row = Math.min(selected_row + 1,  items.length - 1)",
                  type: "text",
                  class:
                    "bg-black caret-hacker w-full outline-none peer hover:cursor-pointer -ml-1"

            div class: "animate-pulse absolute left-[19.5ch] peer-focus:hidden z-0",
                "x-show": "search == ''",
                do: "▌"

            div class: "font-mono text-sm self-center", "x-text": "`${items.length}/5`"
          end
        end

        ul class: "text-2xl lg:text-lg" do
          template "x-for": "(entry, idx) in items", ":key": "entry.item.name" do
            li ":id": "entry.item.name",
               ":data-selected": "idx == selected_row",
               class:
                 "border-l-4 pl-2 data-[selected]:border-hacker data-[selected]:bg-[#2B332D] border-transparent" do
              a ":href": "entry.item.permalink", class: "font-mono lowercase text-sm" do
                template "x-for": "(char, i) in entry.item.name.split('')",
                         ":key": "i" do
                  span "x-text": "char", ":class": "{'text-hacker': entry.positions.has(i)}"
                end
              end
            end
          end
        end
      end

      script do
        """
        document.addEventListener("alpine:init", () => {
          const sidebar_items = #{encode_data(@data["sidebar"])};
          const posts = #{encode_data(Enum.map(@posts, & &1.permalink))};
          const current_permalink = '#{@page.permalink}';
          Alpine.data("sidebar", () => ({
            init() {
              this.search = '';
              this.$watch('search', (_) => { this.selected_row = 0; });
              this.fzf = new Fzf(sidebar_items, {selector: (item) => item.name});
              this.items = this.fzf.find('');
              this.selected_row = this.items.findIndex((entry) => this.is_current_page(entry.item.permalink));
            },
            is_current_page(permalink) {
              if (permalink == "/articles") {
                return current_permalink == "/articles" || posts.includes(current_permalink)
              } else {
                return current_permalink == permalink;
              }
            }
          }));
        });
        """
      end
    end
  end

  def template(assigns) do
    temple do
      div class:
            "min-h-[100dvh] mx-4 grid grid-cols-1 sm:grid-cols-[auto_1fr] justify-between lg:gap-x-4" do
        div class: "hidden lg:block max-w-lg" do
          c &nav/1, page: @page, posts: @posts, data: @data
        end

        main class:
               "lg:grid lg:grid-rows-[auto_1fr_auto] lg:grid-cols-[100%] w-full flex-1 lg:flex-auto" do
          div "x-data": "{open: false}",
              ":data-open": "open",
              class: "group grid grid-rows-[auto_1fr_auto] grid-cols-[100%] lg:hidden w-full z-50" do
            div class: "py-4 flex items-center justify-between sticky top-0 bg-black" do
              h2 class: "text-2xl", do: "~/mitchell-hanberg/"

              button type: "button",
                     "@click": "open = !open" do
                c &folder/1, class: "size-6"
              end
            end

            div id: "mobilenav",
                class: "hidden group-[[data-open]]:block bg-black w-full" do
              ul class: "text-2xl" do
                for item <- @data["sidebar"] do
                  li class:
                       "border-l-4 p-2 data-[selected]:border-hacker data-[selected]:bg-[#2B332D] border-transparent",
                     "data-selected": is_current_page(@posts, item["permalink"], @page.permalink) do
                    a href: item["permalink"],
                      class: "font-mono lowercase" do
                      item["name"] <> "/"
                    end
                  end
                end
              end
            end

            div class: "contents group-[[data-open]]:hidden" do
              div class: "lg:hidden" do
                render(@inner_content)
              end

              div class: "lg:hidden" do
                c &footer/1
              end
            end
          end

          div class: "hidden lg:block lg:h-8"

          div class: "hidden lg:flex justify-center" do
            render(@inner_content)
          end

          div class: "hidden lg:block" do
            c &footer/1
          end
        end

        div()
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

defmodule Blog.SidebarLayout do
  use Tableau.Layout, layout: Blog.RootLayout
  use Blog.Component

  def is_current_page(posts, "/articles", path) do
    path == "/articles" or path in Enum.map(posts, & &1.permalink)
  end

  def is_current_page(_posts, pattern, path) do
    pattern == path
  end

  defp encode_data(pages) do
    items =
      for %{title: title, permalink: permalink} <- pages do
        %{"name" => title, "permalink" => permalink}
      end

    Jason.encode!(items)
  end

  def template(assigns) do
    temple do
      div class: "min-h-[100dvh]" do
        div class: "grid grid-rows-[auto_1fr_auto] grid-cols-[100%] container w-full" do
          div "x-data": "{open: false}", ":data-open": "open", class: "sticky top-0 group z-10" do
            div class: "py-4 flex items-center justify-between bg-black" do
              h2 class: "text-2xl" do
                a href: "/" do
                  "/mitch"
                end
              end

              nav class: "hidden lg:block" do
                ul class: "flex items-center gap-2" do
                  li do: a(href: "/articles", do: "articles/")
                  li do: a(href: "/bookshelf", do: "bookshelf/")
                  li do: a(href: "/newsletter", do: "newsletter/")
                  li do: a(href: "/uses", do: "uses/")
                  li do: a(href: "/feed.xml", do: "rss/")
                end
              end

              button type: "button", class: "lg:hidden", "@click": "open = !open" do
                c &folder/1, class: "size-6"
              end
            end

            div id: "mobilenav", class: "hidden group-[[data-open]]:block bg-black w-full" do
              ul class: "text-2xl" do
                for item <- @data["sidebar"] do
                  li class:
                       "border-l-4 p-2 data-[selected]:border-hacker data-[selected]:bg-[#2B332D] border-transparent",
                     "data-selected": is_current_page(@posts, item["permalink"], @page.permalink) do
                    a href: item["permalink"], class: "font-mono lowercase" do
                      item["name"] <> "/"
                    end
                  end
                end
              end
            end
          end

          div class: "" do
            render(@inner_content)
          end

          div class: "" do
            c &footer/1
          end
        end
      end

      c &nav/1, page: @page, posts: @posts, data: @data, graph: @graph, site: @site
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
            class: "text-hacker underline" do
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

  def nav assigns do
    temple do
      aside id: "nav",
            "x-data": "sidebar",
            "x-show": "focused",
            "x-cloak": true,
            "x-trap.noscroll": "focused",
            "@keydown.ctrl.p.window": "focused = true; terminal.focus();",
            class:
              "absolute z-[100] inset-1 max-h-[75dvh] max-w-4xl mx-auto bg-black mt-8 p-1 border border-hacker rounded" do
        h2 class: "font-mono mb-2 flex gap-1 border-b border-zinc-500 py-1" do
          div class: "flex-shrink-0" do
            "/mitch/"
          end

          div class: "flex bg-black flex-1 w-full flex-grow" do
            input "x-model": "search",
                  id: "terminal",
                  "x-effect": "items = fzf.find(search)",
                  "@keyup.enter": "location.assign(items.at(selected_row).item.permalink)",
                  "@keydown.escape.prevent.window": "search = ''; focused = false;",
                  "@keydown.ctrl.c.prevent.window": "search = ''; focused = false;",
                  "@keydown.up.window": "up",
                  "@keydown.down.window": "down",
                  type: "text",
                  class:
                    "bg-black caret-hacker w-full outline-none peer hover:cursor-pointer -ml-1"

            div class: "animate-pulse absolute left-[19.5ch] peer-focus:hidden z-0",
                "x-show": "search == ''",
                do: "▌"

            div class: "font-mono text-sm self-center",
                "x-text": "`${items.length}/${total_items_length}`"
          end
        end

        ul class: "text-2xl lg:text-lg max-h-[calc(75dvh-46px)] overflow-y-auto pb-2",
           id: "fzf_results" do
          template "x-for": "(entry, idx) in items", ":key": "entry.item.name" do
            li ":id": "'fzfitem' + idx",
               ":data-selected": "idx == selected_row",
               class:
                 "border-l-4 pl-2 py-1 outline-none data-[selected]:border-hacker data-[selected]:bg-[#2B332D] border-transparent" do
              a ":href": "entry.item.permalink", class: "font-mono lowercase text-sm" do
                div do
                  template "x-for": "(char, i) in entry.item.name.split('')",
                           ":key": "i" do
                    span "x-text": "char", ":class": "{'text-hacker': entry.positions.has(i)}"
                  end
                end

                div "x-text": "entry.item.permalink", class: "text-slate-200 text-xs"
              end
            end
          end
        end
      end

      script do
        """
        function scrollIntoViewIfNotVisible(target) { 
          let bounding_rect = target.getBoundingClientRect();
          let fzf_bounding_rect = fzf_results.getBoundingClientRect();
          if (bounding_rect.bottom > fzf_bounding_rect.bottom) {
            fzf_results.scrollBy({top: bounding_rect.height})

          } else if (bounding_rect.top < fzf_bounding_rect.top) {
            fzf_results.scrollBy({top: -bounding_rect.height})
          } 
        }
        window.scrollIntoViewIfNotVisible = scrollIntoViewIfNotVisible;
        document.addEventListener("alpine:init", () => {
          const sidebar_items = #{encode_data(@site.pages)};
          const current_permalink = '#{@page.permalink}';
          Alpine.data("sidebar", () => ({
            init() {
              this.search = '';
              this.focused = false;
              this.total_items_length = sidebar_items.length;
              this.$watch('search', (_) => { this.selected_row = 0; });
              this.fzf = new Fzf(sidebar_items, {selector: (item) => item.name});
              this.items = this.fzf.find('');
              this.selected_row = 0;
            },
            selected_result() {
              return document.getElementById(`fzfitem${this.selected_row}`);
            },
            up(event) {
              if (this.focused) {
                event.preventDefault();
                this.selected_row = Math.max(this.selected_row - 1, 0)
                scrollIntoViewIfNotVisible(this.selected_result())
              }
            },
            down() {
              if (this.focused) {
                event.preventDefault();
                this.selected_row = Math.min(this.selected_row + 1,  this.items.length - 1)
                scrollIntoViewIfNotVisible(this.selected_result())
              }
            },
          }));
        });
        """
      end
    end
  end
end

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
      div class: "grid-rows-[auto_1fr_auto] grid-cols-[100%] min-h-[100dvh] grid" do
        div "x-data": "{open: false}",
            ":data-open": "open",
            class: "group container sticky top-0 z-10" do
          div class: "flex items-center justify-between bg-black py-4" do
            h2 class: "text-lg" do
              a href: "/" do
                "/mitch"
              end
            end

            nav class: "hidden lg:block" do
              ul class: "flex items-center gap-2" do
                for n <- @data["nav"] do
                  li do: a(href: n["permalink"], do: n["name"])
                end

                button type: "button",
                       class: "cursor-pointer",
                       "@click": """
                       const store = Alpine.store('site')
                       if (store.focused) {
                         window.dispatchEvent(new KeyboardEvent('keydown', {'key': 'escape'}));
                       } else {
                         window.dispatchEvent(new KeyboardEvent('keydown', {'key': 'p', ctrlKey: true}));
                       }
                       """ do
                  c &search/1, class: "size-5"
                end
              end
            end

            div class: "lg:hidden" do
              button type: "button",
                     class: "cursor-pointer",
                     "@click": """
                     const store = Alpine.store('site')
                     if (store.focused) {
                       window.dispatchEvent(new KeyboardEvent('keydown', {'key': 'escape'}));
                     } else {
                       window.dispatchEvent(new KeyboardEvent('keydown', {'key': 'p', ctrlKey: true}));
                     }
                     """ do
                c &search/1, class: "size-6"
              end

              button type: "button", "@click": "open = !open" do
                c &folder/1, class: "size-6"
              end
            end
          end

          div id: "mobilenav", class: "hidden w-full bg-black group-[[data-open]]:block" do
            ul class: "text-lg" do
              for item <- @data["nav"] do
                li class:
                     "border-l-4 border-transparent p-2 data-[selected]:border-fallout-green data-[selected]:bg-[#2B332D]",
                   "data-selected": is_current_page(@posts, item["permalink"], @page.permalink) do
                  a href: item["permalink"], class: "font-mono lowercase" do
                    item["name"]
                  end
                end
              end
            end
          end
        end

        div class: "scroll-p-4" do
          render(@inner_content)
        end

        c &footer/1, data: @data
      end

      c &nav/1, page: @page, posts: @posts, data: @data, graph: @graph, site: @site
    end
  end

  def footer assigns do
    temple do
      footer class: "container" do
        hr class: "my-8"

        ul class: "list-disc pl-6" do
          for n <- @data["footer"] do
            li do: c(&link/1, href: n["permalink"], do: n["name"])
          end
        end

        p class: "my-8 text-center text-xs" do
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
            class: "text-fallout-green underline" do
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
            "x-show": "$store.site.focused",
            "x-cloak": true,
            "x-trap.noscroll": "$store.site.focused",
            "@click.outside": "close();",
            "@keydown.ctrl.p.window": "$store.site.focus(); terminal.focus();",
            class:
              "z-[100] max-h-[75dvh] border-fallout-green fixed inset-1 mx-auto mt-12 max-w-4xl border-4 bg-black p-1 md:mt-8" do
        h2 class: "font-mono mb-2 flex gap-1 border-b border-zinc-500 py-1" do
          div class: "flex-shrink-0" do
            "/mitch/"
          end

          div class: "flex w-full flex-1 flex-grow bg-black" do
            input "x-model": "search",
                  id: "terminal",
                  "x-effect": "items = fzf.find(search); console.log(items);",
                  "@keyup.enter": "location.assign(items.at(selected_row).item.permalink)",
                  "@keydown.escape.prevent.window": "close();",
                  "@keydown.ctrl.c.prevent.window": "close();",
                  "@keydown.up.window": "up",
                  "@keydown.down.window": "down",
                  "@keydown.ctrl.p.window": "up",
                  "@keydown.ctrl.n.window": "down",
                  type: "text",
                  class:
                    "caret-fallout-green peer -ml-1 w-full bg-black outline-none hover:cursor-pointer"

            div class: "left-[19.5ch] absolute z-0 animate-pulse peer-focus:hidden",
                "x-show": "search == ''",
                do: "▌"

            div class: "font-mono self-center text-sm",
                "x-text": "`${items.length}/${total_items_length}`"
          end
        end

        ul class: "max-h-[calc(75dvh-55px)] z-[99] overflow-y-scroll pb-2 text-2xl lg:text-lg",
           id: "fzf_results" do
          template "x-for": "(entry, idx) in items", ":key": "entry.item.permalink" do
            li ":id": "'fzfitem' + idx",
               ":data-selected": "idx == selected_row",
               class:
                 "border-l-4 border-transparent py-1 pl-2 outline-none data-[selected]:border-fallout-green data-[selected]:bg-[#2B332D] hover:bg-[#2B332D]" do
              a ":href": "entry.item.permalink", class: "font-mono text-sm lowercase" do
                div do
                  template "x-for": "(char, i) in entry.item.name.split('')",
                           ":key": "i" do
                    span "x-text": "char",
                         ":class": "{'text-fallout-green': entry.positions.has(i)}"
                  end
                end

                div "x-text": "entry.item.permalink", class: "text-xs text-slate-200"
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
              this.total_items_length = sidebar_items.length;
              this.$watch('search', (_) => { this.selected_row = 0; });
              this.fzf = new Fzf(sidebar_items, {selector: (item) => item.name});
              this.items = this.fzf.find('');
              this.selected_row = 0;
              this.store = Alpine.store('site');
            },
            open() {
              terminal.focus();
              this.store.focus();
            },
            close() {
              this.search = '';
              this.store.unfocus();
            },
            selected_result() {
              return document.getElementById(`fzfitem${this.selected_row}`);
            },
            up(event) {
              if (this.store.focused) {
                event.preventDefault();
                this.selected_row = Math.max(this.selected_row - 1, 0)
                scrollIntoViewIfNotVisible(this.selected_result())
              }
            },
            down() {
              if (this.store.focused) {
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

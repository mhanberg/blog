defmodule Blog.Header do
  import Temple.Component

  render do
    header class: "container sticky top-0 bg-evergreen-900 pt-8 z-20", x_data: "{open: false}" do
      div class: "flex items-center justify-between" do
        div class: "flex items-end justify-between" do
          div class: "flex items-end" do
            a class: "text-white no-underline", href: "/", aria_label: "Home button" do
              c Blog.Logo
            end

            div class: "ml-4 md:ml-8 flex-shrink-0" do
              a class: "text-white no-underline", href: "/", aria_label: "Home button" do
                div! class: "text-xl font-bold leading-none", do: "Mitchell Hanberg"
              end

              div class: "hidden md:block md:mt-3" do
                div class: "text-sm hidden md:block mr-2", style: "word-spacing: 1rem;" do
                  c Blog.NavItems
                end
              end
            end
          end
        end

        button type: "button", id: "searchbtn", class: "hidden md:block" do
          Phoenix.HTML.raw("""
          <svg class="h-6 w-6 fill-current text-evergreen-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M12.9 14.32a8 8 0 1 1 1.41-1.41l5.35 5.33-1.42 1.42-5.33-5.34zM8 14A6 6 0 1 0 8 2a6 6 0 0 0 0 12z"/></svg>
          """)
        end

        button id: "hamburger",
               class: "md:hidden",
               "@click": "open = true",
               "x_bind:class": "{'hidden': open}" do
          Phoenix.HTML.raw("""
          <svg class="fill-current h-6 w-6" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z"/></svg>
          """)
        end

        button id: "close",
               class: "hidden",
               "@click": "open = false",
               "x_bind:class": "{hidden: !open}" do
          Phoenix.HTML.raw("""
          <svg class="fill-current h-6 w-6" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z"/></svg>
          """)
        end
      end

      div id: "menu",
          class: "mobile-nav closed flex flex-col items-end my-4 text-evergreen-500",
          "x_bind:class": "{closed: !open}" do
        c Blog.NavItems

        button type: "button", id: "searchbtn", class: "font-semibold hover:underline py-3" do
          "Search"
        end
      end
    end
  end
end

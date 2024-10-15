defmodule Blog.UsesPage do
  use Tableau.Page,
    layout: Blog.SidebarLayout,
    permalink: "/uses",
    title: "Uses | Mitchell Hanberg"

  use Blog.Component

  def template(assigns) do
    temple do
      section class: "prose-lg prose-invert m-auto" do
        h1 do: "Uses"

        p do
          "No one ever asks me what font or syntax theme I use, but nevertheless here we are."
        end

        for category <- @data["uses"] do
          h2 do: category["name"]

          ul do
            for entry <- category["entries"] do
              li class: "list-disc" do
                span id: Blog.Filters.slugify(entry["name"]),
                     class: "text-whtie font-semibold" do
                  a href: entry["link"], target: "_blank", do: entry["name"]
                end
              end
            end
          end
        end
      end
    end

    # ~L"""
    # <section class="prose-lg prose-invert max-w-2xl m-auto">
    #   <h1>Uses</h1>
    #
    #   <p>
    #     No one ever asks me what font or syntax theme I use, but nevertheless here
    #     we are.
    #   </p>
    #
    #   {% for category in data.uses %}
    #   <h2>{{ category.name }}</h2>
    #   <ul class="px-1">
    #     {% for entry in category.entries %}
    #     <li class="list-none">
    #       <div class="pl-5">
    #         <span id="{{ entry.name | slugify }}" class="text-white font-semibold">
    #           <a href="{{entry.link}}" target="_blank">{{ entry.name }}</a>
    #         </span>
    #       </div>
    #     </li>
    #     {% endfor %}
    #   </ul>
    #   {% endfor %}
    # </section>
    # """
  end
end

defmodule Blog.Og.Layout do
  use Tableau.Layout
  import Temple

  def template(assigns) do
    temple do
      render(@inner_content)
    end
  end
end

defmodule Blog.Og do
  # use Tableau.Page,
  #   layout: Blog.Og.Layout,
  #   permalink: "/og/preview",
  #   title: "Some kind of page title",
  #   date: DateTime.utc_now()

  use Blog.Component

  def template(assigns) do
    temple do
      html lang: "en" do
        head do
          style do
            File.read!("_site/css/site.css")
          end
        end

        body class: "bg-black font-mono text-white h-screen w-screen" do
          div class: "flex flex-col h-full justify-between" do
            div class: "flex justify-between items-center gap-4 p-8" do
              div class: "p-1" do
                "MH"
              end

              span class: "text-3xl -mt-0.5 font-semibold" do
                "Mitchell Hanberg"
              end
            end

            div class: "flex justify-end items-center p-8" do
              span class: "text-3xl font-semibold" do
                if @page[:date] do
                  Calendar.strftime(@page.date, "%B %d, %Y")
                end
              end
            end
          end

          div class:
                "grid justify-center items-center h-screen w-screen absolute top-0 border-fallout-green border-[15px]" do
            div class: "flex items-end px-12" do
              div class: "text-7xl font-bold leading-[125%]" do
                String.replace_suffix(@page.title, " | Mitchell Hanberg", "")
              end
            end
          end

          # if Mix.env() == :dev do
          #   c &Tableau.live_reload/1
          # end
        end
      end
    end
  end
end

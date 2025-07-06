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

        body class: "font-mono h-screen w-screen bg-black text-white" do
          div class: "flex h-full flex-col justify-between" do
            div class: "flex items-center justify-between gap-4 p-8" do
              div class: "p-1" do
                "MH"
              end

              span class: "-mt-0.5 text-3xl font-semibold" do
                "Mitchell Hanberg"
              end
            end

            div class: "flex items-center justify-end p-8" do
              span class: "text-3xl font-semibold" do
                if @page[:date] do
                  Calendar.strftime(@page.date, "%B %d, %Y")
                end
              end
            end
          end

          div class:
                "border-fallout-green border-[15px] absolute top-0 grid h-screen w-screen items-center justify-center" do
            div class: "flex items-end px-12" do
              div class: "leading-[125%] text-7xl font-bold" do
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

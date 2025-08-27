defmodule Blog.PresentationLayout do
  use Tableau.Layout, layout: Blog.RootLayout
  use Blog.Component

  def template(assigns) do
    temple do
      div class: "h-dvh mx-auto overflow-hidden p-8",
          "x-data": "slide",
          "@keydown.h.window": "previousSlide",
          "@keydown.left.window": "previousSlide",
          "@keydown.l.window": "nextSlide",
          "@keydown.right.window": "nextSlide",
          "@keydown.space.window": "nextSlide" do
        div id: "slide" do
          render(@inner_content)
        end
      end

      script do
        """
        document.addEventListener("alpine:init", () => {
          Alpine.data("slide", () => ({
            init() {
              let slide = window.location.toString()

              // in case the url ends with a slash
              if (slide.endsWith("/")) {
                slide = slide.slice(0, slide.length - 1);
              }
              slide = slide.split("/")
              this.slide = parseInt(slide[slide.length - 1])
              this.permalink = slide.slice(0, slide.length - 1).join("/")

              const slideNode = document.getElementById("slide");
              const titles = document.querySelectorAll(".blog-slide-col-title h1");

              titles.forEach(title => {
                fitty(title, {
                  minSize: 48,
                  maxSize: 700 * 0.8,
                  observeMutations: false,
                  observeWindow: false
                });
              });
              const subtitles = document.querySelectorAll(".blog-slide-col-subtitle h2");

              subtitles.forEach(title => {
                fitty(title, {
                  maxSize: 48,
                  observeMutations: false,
                  observeWindow: false
                });
              });
            },
            nextSlide() {
              let nextSlide = this.slide + 1;
              if (nextSlide <= #{@page.length}) {
                window.location = `${this.permalink}/${nextSlide}`;
              }
            },
            previousSlide() {
              let previousSlide = this.slide - 1;
              if (previousSlide >= 1) {
                window.location = `${this.permalink}/${previousSlide}`;
              }
            }

          }));
        });
        """
      end
    end
  end
end

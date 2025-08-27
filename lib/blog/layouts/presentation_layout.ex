defmodule Blog.PresentationLayout do
  use Tableau.Layout, layout: Blog.RootLayout
  use Blog.Component

  def template(assigns) do
    temple do
      div class: "h-dvh aspect-video mx-auto overflow-hidden p-8",
          "x-data": "slide",
          "@keydown.h.window": "previousSlide",
          "@keydown.left.window": "previousSlide",
          "@keydown.l.window": "nextSlide",
          "@keydown.right.window": "nextSlide",
          "@keydown.space.window": "nextSlide",
          "@keydown.cmd.enter.window": "document.body.requestFullscreen()" do
        div id: "slide",
            class: "" do
          render(@inner_content)
        end
      end

      script do
        """
        document.addEventListener("alpine:init", () => {
          Alpine.data("slide", () => ({
            init() {
              const slide = window.location.toString().split("/")
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
              //
              // const codes = document.querySelectorAll(".blog-slide-col-body-content pre");
              //
              // codes.forEach(code => {
              //   fitty(code, {
              //     // minSize: 24,
              //     // maxSize: 48,
              //     observeMutations: false,
              //     observeWindow: false
              //   });
              // }); 
            },
            nextSlide() {
              window.location = `${this.permalink}/${this.slide + 1}`;
            },
            previousSlide() {
              window.location = `${this.permalink}/${Math.max(0, this.slide - 1)}`;
            }

          }));
        });
        """
      end
    end
  end
end

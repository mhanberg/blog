defmodule Blog.Layouts.Post do
  use Tableau.Layout

  layout Blog.Layouts.App

  render do
    section class: "mt-4 max-w-2xl mx-auto" do
      div class: "border-b pb-4" do
        h1! class: "text-2xl md:text-3xl mb-4" do
          @post.frontmatter["title"]
        end

        div! class: "text-sm italic" do
          # format this date
          Blog.Pages.Articles.post_date(@post)

          if @post.frontmatter["updated"] do
            "• Updated on #{Blog.Pages.Articles.updated_on_date(@post)}"
          end

          "• #{Blog.Pages.Articles.reading_time(@post)}"
        end

        if length(@post.frontmatter["tags"] || []) > 0 do
          div class: "mt-4 text-sm" do
            "Tags:"
            # tag stuff goes here
            # span do: page.tags | tags | h }}</span>
          end
        end
      end

      if @post.frontmatter["img"] do
        p class: "mt-4 py-4 mb-16" do
          img class: "mx-auto bg-transparent",
              # src: "{{ page.img | absolute_url }}",
              alt: "Pointless hero image, reminiscent of medium posts"

          p class: "text-center text-xs" do
            @post.frontmatter["image_desc"]
          end
        end
      end

      article class: ["post mx-auto": true, "my-4": !@post.frontmatter["img"]] do
        slot :default
      end

      div class: "mt-16" do
        hr()

        div class: "bg-evergreen-800 p-4 rounded mb-4" do
          p do
            "If you want to stay current with what I'm working on and articles I write, join my mailing list!"
          end

          p class: "text-sm" do
            "I seldom send emails, and I will"
            strong class: "text-white", do: "never"
            "share your email address with anyone else."
          end

          c Blog.Subscribe
        end
      end
    end

    script do
      "Mitch.anchorifyHeaders();"
    end
  end
end

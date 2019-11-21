module Jekyll
  module UrlFilter
    def post_url(post)
      post["external_url"] || post["url"]
    end

    def post_target(post)
      if post["external_url"]
        "_blank"
      else
        "_self"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::UrlFilter)

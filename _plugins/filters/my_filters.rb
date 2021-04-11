module Jekyll
  module MyFilters
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

    def book_url(links, goodreads_id)
      links.find { |link|
        link["id"].to_s == goodreads_id.to_s
      }.then { |link|
        link.fetch("link", "https://amazon.com/s?k=#{CGI.escape(link["title"])}")
      }
    end

    def get_review(goodreads_id)
      site.posts.docs.find do |post|
        get_goodreads_id(post).to_s == goodreads_id.to_s
      end
    end

    def group_by_year(books)
      books ? books.group_by do |book|
          book["date_read"].year
         end : Hash.new
    end

    def reading_time(post)
      number_of_words(post["content"]).then do |words|
        "#{words < 360 ?  1 : words / 180} minute read"
      end
    end

    def tags(tags)
      tags.map {|tag| "#".concat(tag)}.join(" ")
    end

    private

    def site
      @site ||= @context.registers[:site]
    end

    def get_goodreads_id(post)
      return {} if post["book"].nil?

      post["book"]["goodreads_id"]
    end
  end
end

Liquid::Template.register_filter(Jekyll::MyFilters)

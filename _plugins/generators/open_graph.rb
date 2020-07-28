class OpenGraphGenerator < Jekyll::Generator
  safe true

  def generate(site)
    site.posts.docs.each do |post|
      site.pages << OpenGraphPage.new(site, site.source, post)
    end
  end
end

class OpenGraphPage < Jekyll::Page
  def initialize(site, base, post)
    dir = site.config['open_graph_dir'] || 'open_graph'

    @site = site
    @base = base
    @dir  = File.join(dir, post.data["title"])
    @name = 'index.html'

    self.process(@name)

    self.data = Hash.new
    self.data["layout"] = "open_graph"
    self.data['title'] = post.data["title"]
    self.data["post_url"] = post.url
  end
end

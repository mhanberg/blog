Jekyll::Hooks.register(:site, :post_write) do |site|
  if ENV["JEKYLL_ENV"] == "production"
    raise PurgeCssNotFoundError unless File.file?("./node_modules/.bin/purgecss")

    raise PurgeCssRuntimeError unless system("./node_modules/.bin/purgecss --config ./purgecss.config.js --out _site/css/") 
  end
end

class PurgeCssNotFoundError < RuntimeError; end
class PurgeCssRuntimeError < RuntimeError; end

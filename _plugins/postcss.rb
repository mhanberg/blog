require "open3"

module Jekyll
  class PostCssConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /^\.css$/i
    end

    def output_ext(ext)
      ".css"
    end

    def convert(content)
      raise PostCssNotFoundError unless File.file?("./node_modules/.bin/postcss")

      compiled_css, status = Open3.capture2("./node_modules/.bin/postcss", :stdin_data => content)

      raise PostCssRuntimeError unless status.success? 

      compiled_css
    end
  end
end

class PostCssNotFoundError < RuntimeError; end
class PostCssRuntimeError < RuntimeError; end

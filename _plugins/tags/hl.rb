# frozen_string_literal: true

module Jekyll
  module Tags
    class HlBlock < Liquid::Block
      include Liquid::StandardFilters

      # The regular expression syntax checker. Start with the language specifier.
      # Follow that by zero or more space separated options that take one of three
      # forms: name, name=value, or name="<quoted list>"
      #
      # <quoted list> is a space-separated list of numbers
      # SYNTAX = %r!^([a-zA-Z0-9.+#_-]+)((\s+\w+(=(\w+|"([0-9]+\s)*[0-9]+"))?)*)$!.freeze

      def initialize(tag_name, markup, tokens)
        super
        options = markup.split(" ")
        @lang = options.shift.downcase
        @highlight_options = parse_options(options)
      end

      LEADING_OR_TRAILING_LINE_TERMINATORS = %r!\A(\n|\r)+|(\n|\r)+\z!.freeze

      def render(context)
        prefix = context["highlighter_prefix"] || ""
        suffix = context["highlighter_suffix"] || ""
        code = super.to_s.gsub(LEADING_OR_TRAILING_LINE_TERMINATORS, "")

        output =
          case context.registers[:site].highlighter
          when "rouge"
            render_rouge(code)
          else
            render_codehighlighter(code)
          end

        rendered_output = add_code_tag(output)
        prefix + rendered_output + suffix
      end

      private

      def parse_options(input)
        return options if input.empty?

        input.reduce({}) do |acc, opt| 
          key, value = opt.split("=", 2) 

          value.delete_prefix!('"')
          value.delete_suffix!('"')

          acc.merge(key.to_sym => value)
        end
      end

      def render_rouge(code)
        require "rouge"
        initial_formatter = 
          if @highlight_options[:linenos]
            ::Rouge::Formatters::HTMLLineTable.new(
              ::Rouge::Formatters::HTML.new(),
              :table_class    => "highlight",
              :gutter_class => "gutter",
              :code_class   => "code"
            )
          else
            ::Rouge::Formatters::HTMLTable.new(
              ::Rouge::Formatters::HTML.new(),
              :wrap         => false,
              :table_class    => "highlight",
              :gutter_class => "gutter",
              :code_class   => "code"
            )
          end

        highlight_lines = @highlight_options[:hl].split(",").flat_map do |x|
            if matchdata = x.match(/(\d+)\-(\d+)/)
              Range.new(matchdata[1].to_i, matchdata[2].to_i).to_a
            else
              Array(x.to_i)
            end
          end

        formatter = ::Rouge::Formatters::HTMLLineHighlighter.new(
          ::Rouge::Formatters::HTML.new(),
          highlight_lines: highlight_lines
        )
        lexer = ::Rouge::Lexer.find_fancy(@lang, code) || Rouge::Lexers::PlainText
        formatter.format(lexer.lex(code))
      end

      def render_codehighlighter(code)
        h(code).strip
      end

      def add_code_tag(code)
        code_attributes = [
          "class=\"language-#{@lang.to_s.tr("+", "-")}\"",
          "data-lang=\"#{@lang}\"",
        ].join(" ")
        "<div class=\"highlight\"><pre><code #{code_attributes}>"\
        "#{code.chomp}</code></pre></div>"
      end
    end
  end
end

Liquid::Template.register_tag("hl", Jekyll::Tags::HlBlock)


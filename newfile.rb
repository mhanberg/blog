raise 'Missing argument: Filename' if ARGV.empty?

require 'Date'

post_title = ARGV.join(' ')
post_date = Date.today.to_s
post_time = '09:00:00 -04:00'
file_path = "./_posts/#{post_date}-#{ARGV.join('-').downcase}.md"

raise 'File already exists' if File.exists? file_path

front_matter = """---
layout: post
title: #{post_title}
date: #{post_date} #{post_time}
categories: post
desc: An amazing blog post, truly one of the best! PS CHANGEME
permalink: /:categories/:year/:month/:day/:title/
---
"""

File.open file_path, "w+" do |file|
  file.puts front_matter
end

puts "Succesfully created #{file_path}!"

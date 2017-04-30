require 'fileutils'
require 'nokogiri'
require 'yaml'
require 'net/http'
require 'pp'
require 'json'
require 'minidown'

config = YAML.load(File.read 'contents.yml')

for i, book in config
    chapter = 1
    puts "Book Index: #{i}"
    html = ''
    for link in book

        file = "#{i}/#{chapter}.json"
        if File.exists? file
          json = JSON.parse File.read file
          post = json[0]['data']['children'][0]['data']
          md = post['selftext']
          title = post['title']
          html += "<h1>#{title}</h1>"
          html += Minidown.render md
        end
        chapter += 1
    end

    File.open("#{i}.html", 'w') { |file| file.write(html) }
    puts "[html] Generated HTML file for #{i}"
    if File.exists? "#{i}.png"
      `pandoc -S -o #{i}.epub --epub-metadata=#{i}.xml --epub-cover-image=#{i}.png #{i}.html`
    else
      `pandoc -S -o #{i}.epub --epub-metadata=#{i}.xml #{i}.html`
    end
    puts "[epub] Generated EPUB file for #{i}"
    `ebook-convert #{i}.epub #{i}.mobi`
    puts "[mobi] Generated MOBI file for #{i}"
end
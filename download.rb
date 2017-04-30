require 'fileutils'
require 'yaml'
require 'bitly'

Bitly.configure do |config|
  config.api_version = 3
  config.access_token = ENV['BITLY_KEY']
end
config = YAML.load(File.read 'contents.yml')

for i, book in config
    FileUtils.mkdir_p(i)
    chapter_index = 1
    puts "Book Index: #{i}"
    for link in book
        unless File.exists? "#{i}/#{chapter_index}.json"
            puts "Chapter #{chapter_index} downloading from #{link}"
            json_path = Bitly.client.expand(link).long_url + '.json'
            `wget --no-clobber "#{json_path}" --output-document "#{i}/#{chapter_index}.json" -o /dev/null`
        end
        chapter_index += 1
    end
end
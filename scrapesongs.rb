require 'rubygems'
require 'nokogiri'
require 'open-uri'
#url = "http://music.cbc.ca/#!/The-Radio-2-Top-20"
url = "http://music.cbc.ca/modularpages/dynamicPage.aspx?pageUrl=The-Radio-2-Top-20&permalink=The-Radio-2-Top-20"
@doc = Nokogiri::HTML(open(url))
#result = @doc.css("iframe") # => "<name>The A-Team</name>"
results = @doc.xpath('//iframe/@src')

puts "Testing #{results.count} links"
results.each do |r|
  if ( r.value =~ /youtube.com/ )
    puts "found a youtube link: #{r.value}"
  end
end


# working example of preserving metadata.  Seems to break if song title has Ampersand chars in it.
#youtube-dl -i -x --audio-format mp3 --embed-thumbnail --add-metadata --metadata-from-title "%(artist)s - %(title)s"  https://youtu.be/JP1bfczrg-s

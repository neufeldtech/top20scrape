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

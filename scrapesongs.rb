require 'rubygems'
require 'nokogiri'
require 'open-uri'

def alreadyDownloaded(log, link)
  File.open(log).each_line do |line|
    if (line.chomp.split("/")[-1] == link.chomp.split("/")[-1])
      return true
    end
  end
  return false
end

#url = "http://music.cbc.ca/#!/The-Radio-2-Top-20"
url = "http://music.cbc.ca/modularpages/dynamicPage.aspx?pageUrl=The-Radio-2-Top-20&permalink=The-Radio-2-Top-20"
#url = "http://music.cbc.ca/blogs/blogpost.aspx?modPageName=The-Radio-2-Top-20&year=2015&month=8&title=Radio-2-Top-20-Aug-7-Alessia-Cara-Wilco-debut-Harpoonist-The-Axe-Murderer-still-killing-it&permalink=/The-Radio-2-Top-20/blogs/2015/8/Radio-2-Top-20-Aug-7-Alessia-Cara-Wilco-debut-Harpoonist-The-Axe-Murderer-still-killing-it"

@doc = Nokogiri::HTML(open(url))
#result = @doc.css("iframe") # => "<name>The A-Team</name>"
results = @doc.xpath('//iframe/@src')
logfile = "downloaded_songs.txt"
if !(File.exist?(logfile))
  system "touch #{logfile}"
end

puts "Testing #{results.count} links"
results.each do |r|
  if ( r.value =~ /youtube.com/ )
    puts "found a youtube link: #{r.value}"
    if (! alreadyDownloaded(logfile, r.value))
      if (system "youtube-dl -i -x --audio-format mp3 --embed-thumbnail --add-metadata --metadata-from-title '%(artist)s - %(title)s' --exec 'eyeD3 -A CBCrips {} && mv {} ./songs/' #{r.value}")
        file = open(logfile, 'a')
        file.write("#{r.value}\n")
        file.close
      end #end if the download finished successfully (exiting with true status)
    else
      puts "#{r.value} has already been processed and will be ignored."
    end #end if not already downloaded
  end #end if it was a youtube link
end #end for each result found on the page

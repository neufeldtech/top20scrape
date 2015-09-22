require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'yt'
require 'colorize'

def alreadyDownloaded(log, link)
  File.open(log).each_line do |line|
    if (line.chomp.split("/")[-1] == link.chomp.split("/")[-1])
      return true
    end
  end
  return false
end

logfile = "downloaded_songs.txt"
if !(File.exist?(logfile))
  system "touch #{logfile}"
end
if !(Dir.exist?('songs'))
  system "mkdir songs"
end

#puts "Argument 0: #{ARGV[0]} Argument 1: #{ARGV[1]}"
#options for radio shows
# radio_show = "Tempo"
# radio_show = "Nightstream"
# radio_show = "Radio 2 Drive"
# radio_show = "Radio 2 Morning"
#day = "2014-08-29"
radio_show = "#{ARGV[0]}"
day = ARGV[1]

byDateUrl = "http://music.cbc.ca/broadcastlogs/broadcastlogs.aspx?broadcastdate=#{day}"
todayUrl = "http://music.cbc.ca/broadcastlogs/broadcastlogs.aspx?network=$1&permalink=/radio2/playlogs"

#youtube API Setup
server_key =  File.open('api_key.txt').readlines[0].chomp
Yt.configure do |config|
  config.api_key = server_key
end
videos = Yt::Collections::Videos.new

#if day argument is given, parse it and use the specific day url
todaysDate = Time.new

if (day)
  url = byDateUrl
  begin
    date = Time.new(day.split("-")[0], day.split("-")[1], day.split("-")[2])
    if (date.saturday?)
      puts "You chose a Saturday.  Please choose a valid weekday, then try again".red
      exit
    elsif (date.sunday?)
      puts "You chose a Sunday.  Please choose a valid weekday, then try again".red
      exit
    else
      puts"=> Using supplied date #{date.year}-#{date.month}-#{date.day}".blue
    end
  rescue
    puts "Error parsing date. Please use format YYYY-MM-DD.".yellow
    puts"=> Using today's date #{todaysDate.year}-#{todaysDate.month}-#{todaysDate.day}".blue
    #fall back to today's date and use that URL
    url = todayUrl
  end
else
  puts "No date specified. Please use format YYYY-MM-DD if you wish to include one.".yellow
  puts "=> Using Today's date #{todaysDate.year}-#{todaysDate.month}-#{todaysDate.day}".blue
  url = todayUrl
  today = Time.new
  if (today.saturday? || today.sunday?)
    puts "Today is a weekend. Cannot parse on a weekend!".red
    exit
  end
end

#main
begin

  @doc = Nokogiri::HTML(open(url))
  show_query = "h2:contains('#{radio_show}')"

  #main check to see if we find our playlist on the particular page
  begin
  logShowEntries =  @doc.at("#{show_query}").next_element.css('div.logShowEntry')
  rescue
    puts "Could not find playlogs for #{radio_show.inspect} for date specified".red
    exit
  end

  logShowEntries.each do |entry|
    begin
      title = entry.css('h3').text.strip.gsub("'","")
      prettyTitle = entry.css('h3').text.strip.downcase
      puts "Title : #{title}"
      artist = entry.css('dd')[0].text.strip.gsub("'","")
      prettyArtist = entry.css('dd')[0].text.strip.downcase
      puts "Artist: #{artist}"
      #searching youtube for the title ordering by highest view count
      topHit = videos.where(q: "#{artist} #{title}", order: 'viewCount', safe_search: 'none').first  
      puts "Youtube hit: #{topHit.title}".green
      prettyTitle = topHit.title.downcase
      embedUrl = "https://www.youtube.com/embed/#{topHit.id}"

      if (! alreadyDownloaded(logfile, embedUrl))
        #attempt to download the file, saving as Artist-Title-CBCrip
        if (system "youtube-dl -i -x --audio-format mp3 --embed-thumbnail --id #{embedUrl}")
          #tack on the ID3 tags
          system "eyeD3 -A CBCrips -a '#{artist}' -t '#{title}' #{topHit.id}.mp3 && mv #{topHit.id}.mp3 './songs/#{artist.capitalize} - #{title.capitalize}.mp3'"
          file = open(logfile, 'a')
          file.write("#{embedUrl}\n")
          file.close
        end #end if the download finished successfully (exiting with true status)
      else
        puts "#{embedUrl} has already been processed and will be ignored."
      end #end if not already downloaded
    rescue => error
      puts "error processing #{embedUrl}\n#{error}".red
    end #end begin/rescue inside each song loop
  end #end each iteration of song

rescue => error
  puts "An Error occurred:"
  puts error
end

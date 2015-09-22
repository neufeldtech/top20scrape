require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'yt'
require 'colorize'

#filesystem setup
logfile = "downloaded_songs.txt"
if !(File.exist?(logfile))
  system "touch #{logfile}"
end
if !(Dir.exist?('songs'))
  system "mkdir songs"
end

def alreadyDownloaded(log, link)
  File.open(log).each_line do |line|
    if (line.chomp.split("/")[-1] == link.chomp.split("/")[-1])
      return true
    end
  end
  return false
end

def youtubeSearch(artist, title, limit)
  counter = 0
  videos = Yt::Collections::Videos.new
  searchResults = videos.where(q: "#{artist} #{title}", order: 'viewCount', safe_search: 'none')
  searchResults.each do |result|
    resultTitle = result.title.downcase
      if ( resultTitle =~ /#{title}/ && resultTitle =~ /#{artist}/ )
        puts "[HIT]: #{resultTitle}".green
        return result
      else
        puts "[MISS]: #{resultTitle}".magenta
       counter = counter + 1
      end #end if hit or miss
     if (counter >= limit)
       puts "No matches in first #{counter} results.".red
       return false
     end #end if counter is up
  end #end looping through search results
end #end function

#input variables
radio_show = "#{ARGV[0]}"
day = ARGV[1]

byDateUrl = "http://music.cbc.ca/broadcastlogs/broadcastlogs.aspx?broadcastdate=#{day}"

#youtube API Setup
server_key =  File.open('api_key.txt').readlines[0].chomp
Yt.configure do |config|
  config.api_key = server_key
end

#if day argument is given, parse it and use the specific day url
todaysDate = Time.new
if (day)
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
    #fallback to todays date if we couldn't parse it
    day = " #{todaysDate.year}-#{todaysDate.month}-#{todaysDate.day}"
  end
else
  puts "No date specified. Please use format YYYY-MM-DD if you wish to include one.".yellow
  puts "=> Using Today's date #{todaysDate.year}-#{todaysDate.month}-#{todaysDate.day}".blue
  day = " #{todaysDate.year}-#{todaysDate.month}-#{todaysDate.day}"
  if (todaysDate.saturday? || todaysDate.sunday?)
    puts "Today is a weekend. Cannot parse on a weekend!".red
    exit
  end
end

#main
begin
  @doc = Nokogiri::HTML(open(byDateUrl))
  show_query = "h2:contains('#{radio_show}')"

  #main check to see if we find our playlist on the particular page
  begin
  playlogEntries =  @doc.at("#{show_query}").next_element.css('div.logShowEntry')
  rescue
    puts "Could not find playlogs for #{radio_show.inspect} for date specified".red
    exit
  end

  playlogEntries.each do |entry|
    begin
      title = entry.css('h3').text.strip.gsub("'","")
      prettyTitle = entry.css('h3').text.strip.downcase
      puts "\nTitle : #{prettyTitle.capitalize}"
      artist = entry.css('dd')[0].text.strip.gsub("'","")
      prettyArtist = entry.css('dd')[0].text.strip.downcase
      puts "Artist: #{prettyArtist.capitalize}"
      #searching youtube for the title ordering by highest view count
      #topHit = videos.where(q: "#{artist} #{title}", order: 'viewCount', safe_search: 'none').first

      # perform the youtube Search, return only best match (if applicable)
      topHit = youtubeSearch(prettyArtist, prettyTitle, 15)

      #if topHit is false, skip this song
      if (! topHit)
        puts "Skipping...".red
        next
      end

      #if we get a hit, and the file has not already been downloaded
      if (! alreadyDownloaded(logfile, "https://www.youtube.com/embed/#{topHit.id}"))

        embedUrl = "https://www.youtube.com/embed/#{topHit.id}"
        #attempt to download the file, saving as Artist-Title-CBCrip
        if (system "youtube-dl -i -x --audio-format mp3 --embed-thumbnail --id #{embedUrl}")
          #tack on the ID3 tags
          system "eyeD3 -A CBCrips -a '#{artist}' -t '#{title.capitalize}' #{topHit.id}.mp3 && mv #{topHit.id}.mp3 './songs/#{artist.capitalize} - #{title.capitalize}.mp3'"
          file = open(logfile, 'a')
          file.write("#{embedUrl}\n")
          file.close
        end #end if the download finished successfully (exiting with true status)
      else
        puts "[ALREADY_EXIST] #{topHit.title}".yellow
      end #end if not already downloaded
    rescue => error
      puts "[ERROR] processing #{embedUrl}\n#{error}".red
    end #end begin/rescue inside each song loop
  end #end each iteration of song

rescue => error
  puts "[ERROR] An Error occurred:".red
  puts "#{error}".red
end

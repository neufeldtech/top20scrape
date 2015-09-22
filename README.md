# top20scrape
This project evolved from when it started and the title is not-so-relevant anymore.
This project hits a desired CBC Radio 2 playlog and scrapes it for song info.  It then will search youtube for each song, download it with youtube-dl and convert it to an MP3 and add appropriate ID3 tags.

### Dependencies
  - Ruby (tested with ruby version 2.2)
  - Bundler (`gem install bundler`)
  - [Youtube-DL](https://rg3.github.io/youtube-dl/)
  - A Google/Youtube API Key (see [Building](#api-key))
  - [avconv or ffmpeg](https://libav.org/download/) libraries for the MP3 conversion done by youtube-dl
  - [eyeD3](http://eyed3.nicfit.net/cli.html) (On Ubuntu/Debian it is available via `sudo apt-get install eyed3`)

----
### Building
Install all dependencies indicated above

Clone the repository and run bundle install to install the required Gems.

    git clone https://github.com/neufeldtech/top20scrape.git
    cd ./top20scrape
    bundle install


#### Api-Key
Follow the instructions [HERE](https://github.com/Fullscreen/yt/blob/master/README.md#configuring-your-app)  to obtain a Youtube API key.  There are multiple kinds of Youtube API keys - you only need the one that 'does not require user interactions'.  Once you have this key save it in the file api_key.txt replacing the text `API_KEY_HERE`.  Your API key should be the ONLY thing present in the file.

----
### Running the script
The main script `playlog_scrape.rb` takes 2 command line parameters.  

The first parameter is the title of the [radio show](http://music.cbc.ca/#!/broadcastlogs/broadcastlogs.aspx?broadcastdate=2015-09-21) you wish to scrape.  Current valid options. are the following:

- `Radio 2 Morning`
- `Shift`
- `Radio 2 Drive`
- `Canada Live`
- `Tonic`
- `The Signal`
- `A Propos`

The second parameter is the desired date you wish to scrape the playlog for. The date format is `YYYY-MM-DD`.

**Note**: scraping on weekend dates is currently disabled as the radio show schedule differs.

The script will dump finished MP3 downloads into the ./songs directory, and will write the youtube  link it used in `downloaded_songs.txt`. `downloaded_songs.txt` is checked before each download to avoid duplicates.

#### Examples:
`ruby playlog_scrape.rb 'Radio 2 Morning'`

In the above example no date was given as the second argument, so the script will scrape today's page for the 'Radio 2 Morning' show.

`ruby playlog_scrape.rb 'Radio 2 Drive' 2015-09-21`

The above example will scrape the 'Radio 2 Drive' playlogs for September 21st, 2015.

# top20scrape

This project visit the current CBC Radio 2 top 20 music page and collects the listed youtube songs (usually a few from each week).  It then will attempt to download them via youtube-dl and convert them to an MP3.

### Dependencies
  - Ruby
  - Bundler
  - Youtube-DL (can be found at https://rg3.github.io/youtube-dl/)
  - avconv or ffmpeg libraries for the MP3 conversion done by youtube-dl
  - eyeD3 (sudo apt-get install eyed3)
### Build instructions
```sh
git clone https://github.com/neufeldtech/top20scrape.git
cd ./top20scrape
bundle install
ruby scrapesongs.rb
```

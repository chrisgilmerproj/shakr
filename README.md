Shakr is an arduino based earthquake notifier.  It reads the USGS RSS feed, parses it with python, sends the magnitude to the arduino causing it to light up and shake equal to the magnitude of the earthquake.

Upon startup Shakr will process all the earthquakes for the last hour.  After it has processed the feed it will check every 30 seconds for updates.  When a new earthquake is posted to the feed it will light up and shake again.

Find more about the available USGS RSS feeds at http://earthquake.usgs.gov/earthquakes/catalogs/.

To use this project you will need to install the following:

    $ pip install feedparser
    $ pip install pyserial

IMPORTANT NOTE: This project is not intended to make light of the devastating effects of earthquakes.  Instead it is intended to help the user become more aware of the world through a unique form of interaction.


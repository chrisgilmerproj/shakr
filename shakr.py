#! /opt/local/bin/python

import binascii, feedparser, glob, pprint, serial, struct, sys, time

# USGS Earthquake Feeds
USGS_1h_M1  = 'http://earthquake.usgs.gov/earthquakes/catalogs/eqs1hour-M1.xml'
USGS_1h_M0  = 'http://earthquake.usgs.gov/earthquakes/catalogs/eqs1hour-M0.xml'
USGS_1d_M25 = 'http://earthquake.usgs.gov/earthquakes/catalogs/eqs1day-M2.5.xml'
USGS_1d_M1  = 'http://earthquake.usgs.gov/earthquakes/catalogs/eqs1day-M1.xml'
USGS_1d_M0  = 'http://earthquake.usgs.gov/earthquakes/catalogs/eqs1day-M0.xml'
USGS_7d_M7  = 'http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M7.xml'
USGS_7d_M5  = 'http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M5.xml'
USGS_7d_M25 = 'http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M2.5.xml'
USGS_30d    = 'http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml'

def scanports():
	return glob.glob('/dev/tty*')

if __name__ == '__main__':
	PORT = None #'/dev/tty.usbserial-A9007PVR'
	BAUD = 19200
	TIMEOUT = 1

	THRESHOLD = 0.0
	DEBUG = False

	# Scan the ports if none given
	if not PORT:
		for port in scanports():
			if 'usbserial' in port:
				PORT = port

	# Connect to serial port and wait for arduino reboot
	try:
		ser = serial.Serial(PORT,BAUD,timeout=TIMEOUT)
		time.sleep(1.5)
	except:
		sys.exit()

	events = {}

	while 1:
		# Parse the USGS Feed
		feed = feedparser.parse(USGS_1h_M0)
		if len(feed.entries):
			for entry in feed.entries:
				# Pull out the title and summary
				title = entry.title
				summary = entry.summary
				
				# Only notify if summary not in keys
				if summary not in events.keys():
					print title, summary 
					# Get the magnitude from the feed
					
					mag = float(title.split(',')[0].split()[1])
					if mag >= THRESHOLD:
						# Pack up the value and send it
						packed = struct.pack('f', mag)
						if DEBUG:
							print val, binascii.hexlify(packed)
						ser.write(packed)

						# Delay before next notification
						time.sleep(5)
	
						# Confirm that value was received
						confirm = ser.readline()
						if confirm:
							# Add this event to the dictionary
							events[summary] = title
		if DEBUG:
			pprint.pprint(events)
		
		# Wait 30 seconds for update
		time.sleep(30)


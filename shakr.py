#! /opt/local/bin/python

import binascii
import datetime
import feedparser
import glob
import optparse
import pprint
import serial
import struct
import sys
import time

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

	usage = 'usage: shakr [options]'
	parser = optparse.OptionParser(usage=usage)

	parser.add_option("-p", "--port",
                      dest="port",
                      default = None,
                      type="string",
                      help="the serial connection port [default: %default]",
                      metavar="PORT")
	parser.add_option("-b", "--baud",
                      dest="baud",
                      default=19200,
                      type="int",
                      help="the serial connection BAUD rate [default: %default]",
                      metavar="BAUD")
	parser.add_option("-t", "--timeout",
                      dest="timeout",
                      default=15,
                      type="int",
                      help="the serial connection TIMEOUT in seconds [default: %default]",
                      metavar="TIMEOUT")
	parser.add_option("-l", "--limit",
                      dest="limit",
                      default=0.0,
                      type="float",
					  help="the notification magnitude THRESHOLD limit [default: %default]",
                      metavar="THRESHOLD")
	parser.add_option("-d", "--debug",
                      action="store_true",
                      dest="debug",
                      default=False,
					  help="the debug setting to print more information [default: %default]")
	(options, args) = parser.parse_args()
	
	# Set up the options
	PORT      = options.port 
	BAUD      = options.baud
	TIMEOUT   = options.timeout
	THRESHOLD = options.limit
	DEBUG     = options.debug

	# Scan the ports if none given
	if not PORT:
		for port in scanports():
			if 'usbserial' in port:
				PORT = port
				break
		if not PORT:
			print 'Port not found, please connect device or set before running'
			sys.exit()

	# Connect to serial port and wait for arduino reboot
	try:
		ser = serial.Serial(PORT,BAUD,timeout=TIMEOUT)
		time.sleep(1.5)
	except e:
		print 'Serial connection could not be established:\n',e
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

				# Get the event time
				event_time = datetime.datetime.strptime(summary,'%B %d, %Y %H:%M:%S %Z')
				
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
						time.sleep(mag)
						time.sleep(5)
	
						# Confirm that value was received
						confirm = ser.readline()
						
						# If confirmed then add this event to the dictionary
						if confirm:
							events[summary] = title
		if DEBUG:
			pprint.pprint(events)
		
		# Wait 30 seconds for update
		time.sleep(30)


#! /opt/local/bin/python

import binascii, feedparser, glob, pprint, serial, struct, time

USGS = 'http://earthquake.usgs.gov/earthquakes/catalogs/eqs1hour-M0.xml'

def scanports():
	return glob.glob('/dev/tty*')

if __name__ == '__main__':
	PORT = None #'/dev/tty.usbserial-A9007PVR'
	BAUD = 19200
	TIMEOUT = 1

	# Scan the ports if none given
	if not PORT:
		for port in scanports():
			if 'usbserial' in port:
				PORT = port

	# Connect to serial port and wait for arduino reboot
	ser = serial.Serial(PORT,BAUD,timeout=TIMEOUT)
	time.sleep(1.5)

	events = {}

	while 1:
		# Parse the USGS Feed
		feed = feedparser.parse(USGS)
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
	
					# Pack up the value and send it
					packed = struct.pack('f', mag)
					#print val, binascii.hexlify(packed)
					ser.write(packed)

					# Delay before next notification
					time.sleep(10)
	
					# Confirm that value was received
					confirm = ser.readline()

					# Add this event to the dictionary
					events[summary] = title
			#pprint.pprint(events)
		
		# Wait 30 seconds for update
		time.sleep(30)


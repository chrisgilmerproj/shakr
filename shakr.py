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
		feed = feedparser.parse(USGS)
		if len(feed.entries):
			for entry in feed.entries:
				title = entry.title
				summary = entry.summary
				
				if summary not in events.keys():
					print title, summary 
					# Get the magnitude from the feed
					mag = title.split(',')[0].split()[1]
					val = float(mag)
	
					# Pack up the value for sending
					packed = struct.pack('f', val)
					#print val, binascii.hexlify(packed)
					ser.write(packed)
					time.sleep(val)
	
					# Confirm that value was received
					print ser.readline()
					events[summary] = title
			pprint.pprint(events)
		time.sleep(30)	

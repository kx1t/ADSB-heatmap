#!/bin/bash
# HEAT2OSM - a Bash shell script to render heatmaps from modified sock30003
# heatmap data
#
# Usage: ./heat2osm.sh [date]
#
# Copyright 2020 Ramon F. Kolb - licensed under the terms and conditions
# of GPLv3. The terms and conditions of this license are included with the Github 
# distribution of this package, and are also available here:
# https://github.com/kx1t/ADSB-heatmap/
#
# The package contains parts of, and modifications or derivatives to the following:
# Dump1090.Socket30003 by Ted Sluis: https://github.com/tedsluis/dump1090.socket30003
# Leaflet.heat: https://leaflet.github.io/Leaflet.heat
# Leaflet: https://github.com/Leaflet/
# OpenStreetMap: https://www.openstreetmap.org
# These packages may incorporate other software and license terms.


# start defining the input and output directories and file names
	HTMLDIR=/usr/share/dump1090-fa/html/heatmap/
	HEATDIR=/home/pi/sock30003/
	HISTFILE=$HTMLDIR/history.html

# get the friendly name for the target date from the command line, or, is there isn't any, we'll go for "yesterday".
	if [[ ! -z "$1" ]]
	then
		HEATDATE=$1
	else
		HEATDATE=yesterday
	fi

# we are generating an index file with the date embedded, for example May 4, 20202 = index-200504.html
	INDX=$HTMLDIR/index-`date -d $HEATDATE +"%y%m%d"`.html

# Call heatmap-osm.pl with the right arguments. The output will go to the HTML directory in a file called heatmapdata-200504.js
	$HEATDIR/heatmap-osm.pl -output $HTMLDIR -degrees 3.5 -maxpositions 200000 -resolution 10000 -override -file heatmapdata-`date -d $HEATDATE +"%y%m%d"`.js  -filemask dump*`date -d $HEATDATE +"%y%m%d"`.txt

# Now create the history file:
	# print HTML headers first:
	printf "<html>\n\t<head></head>\n\t<body>\n\t\t" > $HISTFILE
	printf "<p style=\"font: 16px/1.4 'Helvetica Neue', Arial, sans-serif; font-size:medium; text-align: center\">Historical data: <a href=\"index.html\" target=\"_top\">Latest</a> -  " >>$HISTFILE
	# First write a link to the latest heatmap:
	printf "<a href=\"index.html\" target=\"_top\">Latest</a> - " >>$HISTFILE
	# loop through the existing files. Note - if you change the file format, make sure to yodate the arguments in the line
	# right below. Right now, it lists all files that have the index-20* format (index200504.html, etc.), and then
	# picks the newest 7, reverses the strings to capture the characters 6-11 from the right, which contain the date (200504)
	# and reverses the results back so we get only a list of dates in the format yymmdd.
	# This is not really Y21 compliant, but someone can fix that in 80 years from now if they want :) 
	for d in `ls -1 $HTMLDIR/index-20*|tail -7|rev|cut -c6-11|rev`
	do
        	printf "<a href=\"%s\" target=\"_top\">%s</a> - " "index-`date -d $d +\"%y%m%d\"`.html" "`date -d $d +\"%d-%b-%Y\"`" >> $HISTFILE
	done
	printf "\n\t\t</p>\n\t</body>\n</html>" >> $HISTFILE

# Now stitch the index file together:
	cat $HTMLDIR/index.header1 > $INDX
	printf "<p style="text-align:center">Heatmap for %s</p>" "`date -d $HEATDATE +\"%d-%b-%Y\"`" >>$INDX
	cat $HTMLDIR/index.header2 >> $INDX
	printf "<script src=\"%s\"></script>\n" "heatmapdata-`date -d $HEATDATE +\"%y%m%d\"`.js" >> $INDX
	cat $HTMLDIR/index.footer >> $INDX

# Finally link index.html to the current index file
# Note that this will screw up the link if you run this script with an argument that is different than "" or "yesterday". 
# Future versions could change to add a command line argument to prevent linking unless today's or yesterday's date were selected,
# but for now, deal with it and fix the link manually if that's an issue
#
# Note - this isn't a problem if you use the catchup script to recursively invoke this app, as it will always run the latest available
# date last. So the problem self-corrects.
	ln -sf $INDX $HTMLDIR/index.html

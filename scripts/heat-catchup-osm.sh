#!/bin/bash
# HEAT-CATCHUP-OSM - a Bash shell script to render invoke 'heat2osm' recursively
#
# Usage: ./heat-catchup-osm.sh [date]
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

# The following determines the location of HEAT2OSM. You can change this into a hard coded oath
# if you want. If you make it to be "./", it assumes that HEAT2OSM is invoked from the same directory as
# this script.

	HEATPATH=/home/pi/socket30003/

# The following assumes that you didn't change the default log file location and format when you installed and
# invoke socket30003. If you did change something, you will have to update the line below.
# specifically, the line lists all files that conform to /tmp/dump10*.txt, and then
# selects the rightmost characters 5-10 only. These contain the date of the file in format 'yymmdd'.
# This script then recursively calls HEAT2OSM with each of the dates.

	for f in `ls -1 /tmp/dump10*.txt |rev|cut -c5-10|rev`
	do
		echo $f - processing
		$HEATPATH/heat2osm.sh $f
	done

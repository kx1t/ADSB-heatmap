# ADSB-heatmap
Collection of scripts and modifications to sock30003's heatmap utility to write a daily heatmap based on OpenStreetMap.
Copyright 2020 by Ramon F. Kolb - Licensed under GPL3.0 - see separate license file.

For an example, see http://ramonk.net/heatmap

## Attributions, inclusions, and prerequisites

1. You must have a Raspberry Pi with a working version of dump1090, dump1090-fa, dump1090-mutability, or the equivalent dump978 versions installed. If you don't have this, stop right here. It makes no sense to continue unless you understand the basic functions of the ADSB receiver for Raspberry Pi
2. The scripts in this repository use a slightly modified version of https://github.com/tedsluis/dump1090.socket30003, used and distributed under the GPLv3.0 license. 
3. The heatmap is based on a https://github.com/Leaflet/Leaflet.heat, which is a plugin to http://leafletjs.com. Leaflet.heat is used and distributed under the BSD 2-Clause "Simplified" License.
4. The heatmap is rendered on OpenStreetMaps. 

What does this mean for you? Follow the installation instructions and you should be good :)

## Installation

Follow the following steps in order.

### Prerequisites
1. These instructions assume that you already have a relatively standard installation of dump1090, dump1090-fa, dump1090-mutability, or the equivalent dump978 on your Raspberry Pi. If you don't have this, Google "FlightAware feeder", "Radarbox24 feeder", or something similar to get started. Get a RPi 3B+ or 4, an RTL-SDR dongle, an antenna, and come back here when you can access a map with aircraft flying over your home.
2. You should feel somewhat comfortable installing and configuring software on a Raspberry Pi or a similar Linux system using Github. You will be making modifications to your system, and there is a chance you screw things up. You do so at your own risk.

### Install Dump1090.Socket30003
Ted Sluis wrote a great set of Perl scripts to collect data and render a heatmap, but it assumes that you run a specially modified version of dump1090-mutability to render the maps. If you don't feel comfortable replacing your existing version of dump1090 with his version, you're here at the right spot. We will use his scripts, but render the heatmap separately using OpenStreetMap.

To install Dump1090.Socket30003, [go here](https://github.com/tedsluis/dump1090.socket30003) and follow the installation instructions from the start **UP TO INCLUDING** the section about adding a [Cron Job](https://github.com/tedsluis/dump1090.socket30003#add-socket30003pl-as-a-crontab-job).
Make sure to check that your lat/long has been correctly set to your approximate location in the `[common]` or `[heatmap]` section of `socket30003.cfg`. If they aren't, your heatmap won't work.

If you want the heatmap scripts to run as-is, then the instructions below will assume that you DON'T change the location or format of the log files. This means, that they are written as `/tmp/dump1090_127_0_0_1-yymmdd.txt` and `....log`.

### Install the scripts from this repository
1. Clone the repository. Log into you Raspberry Pi and give the following commands:

```
cd
mkdir git
cd git
git clone https://github.com/kx1t/ADSB-heatmap.git
cd ADSB-heatmap
```

### Make a heatmap directory in your existing HTML directory
Under normal circumstances, your FlightAware or dump1090 maps are rendered in this directory:
`/usr/share/dump1090-fa/html/` or `/usr/share/dump1090/html/`
Find them - figure out which one you actually use, and then do this:

```
sudo mkdir /usr/share/dump1090-fa/html/heatmap
sudo chmod a+rwx /usr/share/dump1090-fa/html/heatmap
```

Remember what you **heatmap directory** is, you will need to use it a few times below. For the rest of the installation instructions, we're assuming it is `/usr/share/dump1090-fa/html/heatmap`. You will have to substitute your **heatmap directory** name if it is different.

### Copy the utilities to the sock30003 directory
If you followed the `socket30003` install instructions to the letter and you didn't change any directories, then `socket30003` is installed in `/home/pi/sock30003`. We'll copy the scripts there.

```
cp scripts/* /home/pi/sock30003
chmod a+x /home/pi/sock30003/*.sh /home/pi/sock30003/*.pl
```

### Copy the web files to the heatmap directory
Remember that heatmap directory we talked about above? Here's where we use it. We are going to put a bunch of header and JavaScript files there. Modify the target if your FlightAware/dump1090 map is located at a different location:

```
cp webfiles/* /usr/share/dump1090-fa/html/heatmap
```

### Edit the script
If all the directories and file names exactly match up with what we wrote above, you can skip this step. If not, then let's make sure that the script can still find everything.

```
cd /home/pi/sock30003
nano heat2osm.sh
```

- Right on top, you see `HTMLDIR`. This should contain your heatmap directory name. If you have a different name, change it there
- Similarly, change the `HEATDIR` to the location of sock30003. Again, if you followed the instructions when installing Socket30003, you shouldn't have to change anything.
- By default, the top of the map shows `Aircraft flight patterns from my ADS-B Flight Receiver` with a link to your SkyAware website located one directory up from the heatmap directory.
  - To change "my" into something else (like "Ramón KX1T's"), change `ME=my` to `ME="Ram&oacute;n KX1T\'s"`. Make sure to escape any quotes or special characters you want to print by using a `\` in front of them.
  - To change the landing directory for your SkyAware or any other landing page you want to configure, change `LANDING=".."` to your desired website. For example, `LANDING="https://flightaware.com/adsb/stats/user/ramonk"`
- Exit with `CTRL-x` and save the changes if needed.

### Create a cron job
CRON is a Linux utility to schedule running a program at regular intervals. Since we want to make a heatmap daily based on the data from the previous day, let's schedule the heat2osm.sh script to be run every night at midnight:

```
crontab -e
```

If it asks you which editor to use, select `nano`.
Then add the following line to the end of the file. Make sure that you check that you're using the correct directory:

```
0 0 * * *    /home/pi/sock30003/heat2osm.sh
```

Exit with `CTRL-x` and save the changes.

### Configuring OpenStreetMap and heatmaps
Open the following file (replacing the directory name with yours, if needed):

```
nano /usr/share/dump1090-fa/html/heatmap/index.footer
```

Then, center the map around your location

Find this line and edit it:

```
var map = L.map('map').setView([42.405, -71.167], 9);
```

The format is `....setView([lat, long], zoom);`. Put in your own approximate longitude/latitude. You can zoom in/out the default view by changing the `zoom` parameter.

# Running the scripts manually
If you have made it through here, the heatmap should start rendering automatically every day at midnight. However, you can always run the scripts manually:

## heat2osm.sh
The script name stands for __**h**eat**m**ap to **O**pen**S**treet**M**ap__.
Format: `./heat2osm.sh [date]`
The `[date]` argument is optional; if omitted, the results will be the same as `./heat2osm.sh yesterday`. It can be in any "friendly" format that is accepted by the Linux `date` command. Examples:

```
./heat2osm.sh
./heat2osm.sh yesterday
./heat2osm.sh today
./heat2osm.sh 200504 # this is 2020-May-04
./heat2osm.sh 4-May-2020
```

## heat-catchup-osm.sh
This script will do a "catch-up" run. It will iterate through all `/tmp/dump1090*.txt` files and create heatmaps for them.
If you changed any directories, please make sure to update this script to reflect this.
The script must be run from the same directory where `heat2osm.sh` is located.
It takes no command line arguments. Use it simply as:

```
./heat-catchup-osm.sh
```

# Changing heatmap attributes
Open the following file (replacing the directory name with yours, if needed):

```
nano /usr/share/dump1090-fa/html/heatmap/index.footer
```

If you want to change the map opacity, the radius or intensity of the elements, etc., then find this line:

```
var heat = L.heatLayer(addressPoints, {minOpacity: 1, radius: 20, maxZoom: 10, blur: 25 }).addTo(map);
```

You can change these parameters, or add some additional ones. For more information about these parameters, their values, and the effects, see the [Leaflet.heat documentation](https://github.com/Leaflet/Leaflet.heat#reference).

When you are done editing, exit and save with `CTRL-x`.

# Seeing your heatmap
Once you have rendered at least 1 heatmap, you can find it at `http://<address_of_rpi>/heatmap`.
Replace `<address_of_rpi>` with whatever the address is you normally use to get to the SkyAware or Dump1090 map.
For reference, see http://ramonk.net/heatmap

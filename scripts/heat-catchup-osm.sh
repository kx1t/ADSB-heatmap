#!/bin/bash
for f in `ls -1 /tmp/dump10*.txt |rev|cut -c5-10|rev`; do echo $f - processing; ./heat2osm.sh $f; done

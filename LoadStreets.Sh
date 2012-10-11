#!/bin/bash

#need to send patch for the openblock python enviroment also.
mv /home/openblock/openblock/lib/python2.7/site-packages/django/contrib/gis/db/backends/postgis/adapter.py  /home/openblock/openblock/lib/python2.7/site-packages/django/contrib/gis/db/backends/postgis/adapter_orig.py
cp /home/ubuntu/opendataday_workshop/adapter.py  /home/openblock/openblock/lib/python2.7/site-packages/django/contrib/gis/db/backends/postgis/adapter.py 
chown openblock:openblock /home/openblock/openblock/lib/python2.7/site-packages/django/contrib/gis/db/backends/postgis/adapter.py 
chmod 664 /home/openblock/openblock/lib/python2.7/site-packages/django/contrib/gis/db/backends/postgis/adapter.py 

# we need to download city and county shapefiles
#get county streets
wget http://gisdownload.buncombecounty.org/streets.zip
unzip  streets.zip

ogr2ogr   -f "ESRI Shapefile" -t_srs "EPSG:4326" centerline_4326.shp centerline.shp 

#fix streets for importing into openblock
ogr2ogr   centerline_4326_a.shp centerline_4326.shp  -sql "SELECT *,CAST(STREET_POS as character(2)) as SPOS, CAST(STREET_PRE as character(2)   ) as PDIR,CAST(RIGHT_FROM as character(6)) as RFROM,CAST(RIGHT_TO_A as character(6)) as RTO,CAST(LEFT_FROM_  as character(6))as LFROM,  CAST(LEFT_TO_AD as character(6)) as LTO,cast(LCOMMCODE as character(2)) as STATE_R,cast(LCOMMCODE as character(2)) as STATE_L,LCOMMCODE,CAST(ROAD_CLASS as character(15))  as FCC FROM centerline_4326"  
ogr2ogr   centerline_4326_b.shp centerline_4326_a.shp  -sql "SELECT *  FROM  centerline_4326_a where RIGHT_FROM >0 and  LEFT_FROM_  > 0  and  RIGHT_TO_A > 0  and LEFT_TO_AD > 0"
ogr2ogr   centerline_4326_c.shp centerline_4326_b.shp  -sql "SELECT *  FROM  centerline_4326_b where LZIP=28801 or RZIP=28801"
ogr2ogr   hold.shp centerline_4326_c.shp   -sql "SELECT *  FROM  centerline_4326_c where STREET_TYP is not null"

#remove old files
rm -f centerline*
ogr2ogr    centerline.shp hold.shp -sql "SELECT *  FROM  hold where fid > 0"

#run the custom import for buncoombe county data
python /home/openblock/openblock/src/openblock/ebpub/ebpub/streets/blockimport/esri/importers/blocks.py centerline.shp  -v -c 'ASHE'

##fix in sql
psql -d openblock_myblock -U openblock << EOF
delete from blocks where right_zip is null;
delete from blocks where left_zip is null;
update blocks set "right_state" = 'NC';
update blocks set "left_state" = 'NC';
EOF

#update blocks intersections etc
populate_streets -v -v -v -v streets
populate_streets -v -v -v -v block_intersections
populate_streets -v -v -v -v intersections



#this is the end of the startup\setup script thre are some manual steps using QGIS here.  

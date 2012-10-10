x#!/bin/bash

#get the opendata_workshop opendata files from git hub.
git clone https://github.com/davecoa/opendataday_workshop.git

#replace the settings python script with the git hub copy the new python importer script from git hub repository
sudo chmod 664 /home/openblock/openblock/src/myblock/myblock/settings.py
sudo chmod 664 ~/opendataday_workshop/Import_blocks_opendataday.py
mv /home/openblock/openblock/src/myblock/myblock/settings.py /home/openblock/openblock/src/myblock/myblock/settings_orig.py
cp ~/opendataday_workshop/Import_blocks_opendataday.py /home/openblock/openblock/src/myblock/myblock/settings.py


#start openblock enviroment
sudo su - openblock
cd /home/openblock/openblock
source bin/activate
export DJANGO_SETTINGS_MODULE=myblock.settings


#setup super username yes this not secure but its demo  in  production you would want to make it something other than password!
django-admin.py createsuperuser
exit


# we need to download city and county shapefiles
#get county streets
wget http://gisdownload.buncombecounty.org/streets.zip
unzip  streets.zip

#get City Boundaries or jurisdictions
wget "http://opendataserver.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_active_jurisdictions&maxFeatures=1000000&outputFormat=SHAPE-ZIP"  -O coa_active_jurisdictions.zip
unzip coa_active_jurisdictions.zip

#get city of asheville neighborhoods
wget  "http://tomcatgis.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_asheville_neighborhoods&maxFeatures=1000000&outputFormat=SHAPE-ZIP" -O coa_asheville_neighborhoods.zip
unzip coa_asheville_neighborhoods.zip

#get crime data for city of asheville
wget "http://tomcatgis.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_crime_mapper_locations_view&maxFeatures=1000000&outputFormat=SHAPE-ZIP"  -O coa_crime_mapper_locations.zip
unzip  coa_crime_mapper_locations.zip

#get development data for city of asheville
wget "http://tomcatgis.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_development_locations_view&maxFeatures=1000000&outputFormat=SHAPE-ZIP" -O coa_development_locations.zip
unzip coa_development_locations.zip

#next open block likes data in different projections.
#like everything in data and IT there 100 ways to do the samething this is one.
# we need to get gdal first. GDAL is an open source command line program to translate spatuial information www.gdal.org
sudo apt-get install gdal-bin


#gdal includes a executable named ogr2ogr it can do some basic vector data aka shapefile modifcations
#we will use ogr2ogr to reproject the downloaded shapefiles from state plane to wgs84.

ogr2ogr   -f "ESRI Shapefile" -t_srs "EPSG:4326" centerline_4326.shp centerline.shp 
ogr2ogr   -f "ESRI Shapefile" -t_srs "EPSG:4326"  coa_active_jurisdiction_4326.shp coa_active_jurisdictions.shp
ogr2ogr   -f "ESRI Shapefile" -t_srs "EPSG:4326"  coa_asheville_neighborhoods_4326.shp coa_asheville_neighborhoods.shp
ogr2ogr   -f "ESRI Shapefile" -t_srs "EPSG:4326"  coa_crime_mapper_locations_view_4326.shp coa_crime_mapper_locations_view.shp
ogr2ogr   -f "ESRI Shapefile" -t_srs "EPSG:4326"  coa_development_locations_view_4326.shp coa_development_locations_view.shp

#fix streets for importing into openblock
ogr2ogr   centerline_4326_a.shp centerline_4326.shp  -sql "SELECT *,CAST(STREET_POS as character(2)) as SPOS, CAST(STREET_PRE as character(2)   ) as PDIR,CAST(RIGHT_FROM as character(6)) as RFROM,CAST(RIGHT_TO_A as character(6)) as RTO,CAST(LEFT_FROM_  as character(6))as LFROM,  CAST(LEFT_TO_AD as character(6)) as LTO,cast(LCOMMCODE as character(2)) as STATE_R,cast(LCOMMCODE as character(2)) as STATE_L,LCOMMCODE,CAST(ROAD_CLASS as character(15))  as FCC FROM centerline_4326"  
ogr2ogr   centerline_4326_b.shp centerline_4326_a.shp  -sql "SELECT *  FROM  centerline_4326_a where RIGHT_FROM >0 and  LEFT_FROM_  > 0  and  RIGHT_TO_A > 0  and LEFT_TO_AD > 0"
ogr2ogr   centerline_4326_c.shp centerline_4326_b.shp  -sql "SELECT *  FROM  centerline_4326_b where LZIP=28801 or RZIP=28801"
ogr2ogr   centerline_4326_hold.shp hold.shp  -sql "SELECT *  FROM  centerline_4326_c where fid > 0"

#remove old files
rm -f centerline*
gr2ogr  hold.shp  centerline.shp -sql "SELECT *  FROM  hold where fid > 0"

#run the custom import for buncoombe county data
 python ~/opendataday_workshop/Import_blocks_opendataday.py centerline.shp  -v -c 'ASHE'

#fix in sql
psql -d openblock_myblock -U openblock
delete from blocks where right_zip is null;
delete from blocks where left_zip is null;
update blocks set "right_state" = 'NC';
update blocks set "lett_state" = 'NC';
\q 

#set openblock enviroment again
sudo su - openblock
cd /home/openblock/openblock
source bin/activate
export DJANGO_SETTINGS_MODULE=myblock.settings

#update blocks intersections etc
populate_streets -v -v -v -v streets
populate_streets -v -v -v -v block_intersections
populate_streets -v -v -v -v intersections

#update the wsgi script so everything is updated and starts with changes 
touch /home/openblock/openblock/wsgi/myblock.wsgi

#this is the end of the startup\setup script thre are some manual steps using QGIS here.  

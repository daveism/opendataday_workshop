#!/bin/bash


#get City Boundaries or jurisdictions
wget "http://opendataserver.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_active_jurisdictions&maxFeatures=1000000&outputFormat=SHAPE-ZIP"  -O coa_active_jurisdictions.zip
unzip coa_active_jurisdictions.zip

#get city of asheville neighborhoods
wget  "http://opendataserver.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_asheville_neighborhoods&maxFeatures=1000000&outputFormat=SHAPE-ZIP" -O coa_asheville_neighborhoods.zip
unzip coa_asheville_neighborhoods.zip

##get crime data for city of asheville
wget "http://opendataserver.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_crime_mapper_locations_view&maxFeatures=1000000&outputFormat=SHAPE-ZIP"  -O coa_crime_mapper_locations.zip
unzip  coa_crime_mapper_locations.zip

#get development data for city of asheville
wget "http://opendataserver.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_development_locations_view&maxFeatures=1000000&outputFormat=SHAPE-ZIP" -O coa_development_locations.zip
unzip coa_development_locations.zip

##next open block likes data in different projections.
#like everything in data and IT there 100 ways to do the samething this is one.
# we need to get gdal first. GDAL is an open source command line program to translate spatuial information www.gdal.org
sudo apt-get install gdal-bin

#now we will add the fields to the shapefiles for calc values
#city
ogrinfo  coa_active_jurisdictions.shp -sql "ALTER TABLE  coa_active_jurisdictions add column cityname character(150) "

#crime
#elinate x and why = 0
ogrinfo  coa_crime_mapper_locations_view.shp -sql "SELECT * FROM coa_crime_mapper_locations_view WHERE x>0 and y>0"
ogrinfo  coa_crime_mapper_locations_view.shp -sql "SELECT * FROM coa_crime_mapper_locations_view WHERE agency='APD'"
ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column x numeric(12,10)"
ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column y numeric(12,10)"
ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column title character(150)"
ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column item_date character(150)"
ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column desc character(150)"

#developemnt
#elinate x and why = 0
ogrinfo  coa_development_locations_view.shp -sql "SELECT * FROM coa_development_locations_view WHERE x>0 and y>0"
ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column x numeric(12,10)"
ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column y numeric(12,10)"
ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column title character(150)"
ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column item_date character(150)"
ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column desc character(150)"



#gdal includes a executable named ogr2ogr it can do some basic vector data aka shapefile modifcations
#we will use ogr2ogr to reproject the downloaded shapefiles from state plane to wgs84.
unmark this if you want I had issues with conversion...
#ogr2ogr   -f "ESRI Shapefile" -t_srs "EPSG:4326"  coa_active_jurisdiction_4326.shp coa_active_jurisdictions.shp
#ogr2ogr   -f "ESRI Shapefile" -t_srs "EPSG:4326"  coa_asheville_neighborhoods_4326.shp coa_asheville_neighborhoods.shp
#ogr2ogr   -f "ESRI Shapefile" -t_srs "EPSG:4326"  coa_crime_mapper_locations_view_4326.shp coa_crime_mapper_locations_view.shp
#ogr2ogr   -f "ESRI Shapefile" -t_srs "EPSG:4326"  coa_development_locations_view_4326.shp coa_development_locations_view.shp
#this is the end of the startup\setup script thre are some manual steps using QGIS here.  

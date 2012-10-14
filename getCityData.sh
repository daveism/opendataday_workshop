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
sudo wget http://download.osgeo.org/proj/proj-4.8.0.tar.gz
sudo wget http://download.osgeo.org/proj/proj-datumgrid-1.5.tar.gz
tar xzf proj-4.8.0.tar.gz
cd proj-4.8.0/nad
tar xzf ../../proj-datumgrid-1.5.tar.gz
cd ..
./configure
make
sudo make install
cd ..
sudo ln -s /usr/lib/libproj.so.0 /usr/lib/libproj.so

#now we will add the fields to the shapefiles for calc values
#city
#ogrinfo  coa_active_jurisdictions.shp -sql "ALTER TABLE  coa_active_jurisdictions add column acityname character(150) "

ogr2ogr test.shp  coa_active_jurisdictions.shp -sql "SELECT *, cast(\"ASHEVILL\" as character(150) )as 'acityname'   FROM coa_active_jurisdictions"
rm coa_active_jurisdictions*
ogr2ogr  coa_active_jurisdictions.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr  test.shp coa_active_jurisdictions.shp -sql "SELECT * FROM coa_active_jurisdictions WHERE jurisdicti <> 'Buncombe County'"
rm coa_active_jurisdictions*
ogr2ogr  coa_active_jurisdictions.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

#crime
#eliminate x and y = 0
ogr2ogr test.shp coa_crime_mapper_locations_view.shp   -sql "SELECT * FROM coa_crime_mapper_locations_view WHERE x>0 or y>0"
rm coa_crime_mapper_locations_view*
ogr2ogr  coa_crime_mapper_locations_view.shp test.shp -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr test.shp  coa_crime_mapper_locations_view.shp -sql "SELECT * FROM coa_crime_mapper_locations_view WHERE agency='APD'"
rm coa_crime_mapper_locations_view*
ogr2ogr  coa_crime_mapper_locations_view.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr test.shp  coa_crime_mapper_locations_view.shp -sql "SELECT *, cast('offense' as character(150) )as 'title'   FROM coa_crime_mapper_locations_view WHERE agency='APD'"
rm coa_crime_mapper_locations_view*
ogr2ogr  coa_crime_mapper_locations_view.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr test.shp  coa_crime_mapper_locations_view.shp -sql "SELECT *, cast('address' as character(150) )as 'locname'   FROM coa_crime_mapper_locations_view WHERE agency='APD'"
rm coa_crime_mapper_locations_view*
ogr2ogr  coa_crime_mapper_locations_view.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr test.shp  coa_crime_mapper_locations_view.shp -sql "SELECT *, cast(concat('casenumber' , \"-\" , 'severity'  ,  \"-\" , 'offense'  , \"-\" , 'address') as character(254))  as 'desc' FROM coa_crime_mapper_locations_view WHERE agency='APD'"
rm coa_crime_mapper_locations_view*
ogr2ogr  coa_crime_mapper_locations_view.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr test.shp  coa_crime_mapper_locations_view.shp -sql "SELECT *,cast(concat(substr(cast('thedate' as character(150)),6,6),\"/\",substr(cast('thedate' as character(150)),1,4)) as character(150)) as item_date  FROM coa_crime_mapper_locations_view  "
rm coa_crime_mapper_locations_view*
ogr2ogr  coa_crime_mapper_locations_view.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

#ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column lat numeric(12,10)"
#ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column long numeric(12,10)"
#ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column title character(150)"
#ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column item_date character(150)"
#ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column desc character(150)"
#ogrinfo  coa_crime_mapper_locations_view.shp -sql "ALTER TABLE  coa_crime_mapper_locations_view add column locname character(150)"

#developemnt
#eliminate x and y = 0
ogr2ogr  test.shp coa_development_locations_view.shp -sql "SELECT * FROM coa_development_locations_view WHERE x>0 or y>0"
rm coa_development_locations_view*
ogr2ogr  coa_development_locations_view.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr test.shp  coa_development_locations_view.shp -sql "SELECT *, cast('name' as character(150) )as 'title'   FROM coa_development_locations_view"
rm coa_development_locations_view*
ogr2ogr  coa_development_locations_view.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr test.shp  coa_development_locations_view.shp -sql "SELECT *, cast('label' as character(150) )as 'locname'   FROM coa_development_locations_view"
rm coa_development_locations_view*
ogr2ogr  coa_development_locations_view.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr test.shp  coa_development_locations_view.shp -sql "SELECT *, cast('label' as character(150) )as 'locname'   FROM coa_development_locations_view"
rm coa_development_locations_view*
ogr2ogr  coa_development_locations_view.shp test1.shp  -sql "SELECT * FROM test WHERE fid>0"


ogr2ogr test.shp  coa_development_locations_view.shp -sql "SELECT *, cast(concat('label' , \"-\" , 'project_id'  ,  \"-\" , 'name'  , \"-\" , 'reason') as character(254) )as 'desc'   FROM coa_development_locations_view"
rm coa_development_locations_view*
ogr2ogr  coa_development_locations_view.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr test.shp  coa_crime_mapper_locations_view.shp -sql "SELECT *,cast(concat(substr(cast('thedate' as character(150)),6,6),\"/\",substr(cast('thedate' as character(150)),1,4)) as character(150)) as item_date  FROM coa_crime_mapper_locations_view  "
rm coa_crime_mapper_locations_view*
ogr2ogr  coa_crime_mapper_locations_view.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

#ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column lat numeric(12,10)"
#ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column long numeric(12,10)"
#ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column title character(150)"
#ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column item_date character(150)"
#ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column desc character(150)"
#ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column reason character(150)"
#ogrinfo  coa_development_locations_view.shp -sql "ALTER TABLE  coa_development_locations_view add column locname character(150)"



#gdal includes a executable named ogr2ogr it can do some basic vector data aka shapefile modifcations
#we will use ogr2ogr to reproject the downloaded shapefiles from state plane to wgs84.
#unmark this if you want I had issues with conversion...
ogr2ogr   -f "ESRI Shapefile" -s_srs "EPSG:2264"  -t_srs "EPSG:4326" coa_city_4326.shp coa_active_jurisdictions.shp
ogr2ogr   -f "ESRI Shapefile" -s_srs "EPSG:2264"  -t_srs "EPSG:4326" coa_hoods_4326.shp coa_asheville_neighborhoods.shp
ogr2ogr   -f "ESRI Shapefile" -s_srs "EPSG:2264"  -t_srs "EPSG:4326" coa_crime_4326.shp coa_crime_mapper_locations_view.shp
ogr2ogr   -f "ESRI Shapefile" -s_srs "EPSG:2264"  -t_srs "EPSG:4326" coa_development_4326.shp coa_development_locations_view.shp

#get lat long after wgs84 conversion

ogr2ogr test.shp  coa_crime_4326.shp -sql "SELECT *, cast(substr(OGR_GEOM_WKT,27,17) as numeric(12,10)) as lat, cast(substr(OGR_GEOM_WKT,8,19) as numeric(12,10)) as long FROM coa_crime_4326 WHERE agency='APD'"
rm coa_crime_4326*
ogr2ogr  coa_crime_4326.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*

ogr2ogr test.shp  coa_development_4326.shp -sql "SELECT *, cast(substr(OGR_GEOM_WKT,27,17) as numeric(12,10)) as lat, cast(substr(OGR_GEOM_WKT,8,19) as numeric(12,10)) as long FROM coa_development_4326"
rm coa_development_4326*
ogr2ogr  coa_development_4326.shp test.shp  -sql "SELECT * FROM test WHERE fid>0"
rm test.*


#create crime csv
ogr2ogr -f "CSV" coacrime.csv coa_crime_4326.shp

#create development csv
ogr2ogr -f "CSV" coa_development.csv coa_development_4326.shp

#zip neighborhoods for import.
zip -r coa_hoods.zip coa_hoods_*

#this is the end of the startup\setup script thre are some manual steps using QGIS here.  

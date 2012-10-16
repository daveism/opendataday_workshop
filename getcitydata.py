from osgeo import ogr
import sys
import string
import urllib2
import os,zipfile
from osgeo import osr
#this script should be run in the same directory
#as gdal is installed.
#installed gdal from 32bit http://vbkto.dyndns.org/sdk/Download.aspx?file=release-1400-gdal-1-9-mapserver-6-0\gdal-19-1400-core.msi
#or 64bit http://vbkto.dyndns.org/sdk/Download.aspx?file=release-1400-x64-gdal-1-9-mapserver-6-0\gdal-19-1400-x64-core.msi
#I had to copy the GDAL directory to c: to avoid issues with the space in program files directory
#this script is not yet ready for linux....

def getShapeName(zipFilename):
    theShpName = zipFilename.replace('zip','shp')
    return theShpName

def extractzip(zipFilename) :
    z = zipfile.ZipFile(zipFilename)
    z.extractall()
   
def getzip(url,thefile):
    thezip = urllib2.urlopen( url , thefile)
    if (os.path.exists(thefile)):
        os.unlink(thefile)
    output = open(thefile,'wb')
    output.write(thezip.read())
    output.close()
    extractzip(thefile)
    shpName = getShapeName(thefile)
    return shpName
 

def get_attributes(self):
    # Todo: control field order as param
    fields = self.queryset.model._meta.fields
    attr = [f for f in fields if not isinstance(f, GeometryField)]
    return attr

def deleteShapefile(shpfle):
    #remove temp file in case it exists
    pth = os.getcwd()
    theShpName = shpfle.replace('.shp','')
    for file in os.listdir(pth):    
        if file.startswith(theShpName): 
                if (os.path.exists(file)):
                   os.unlink(file)
                   
def makeopenblockshapes(inshp,sql):
    pth = os.getcwd()
    outshp = 'temp.shp'

    #remove temp file in case it exsists
    deleteShapefile(outshp)

    #create temp shapefile with sql filter
    cmd = 'ogr2ogr ' + pth + '/' + outshp +  ' ' + pth + '/'+inshp+' -sql \"' + sql  +'\"'
    print cmd
    result = os.system(cmd)
    print result

    #remove original shapefile
    if result == 0:
        deleteShapefile (inshp)

    #recreate orig
    theShpName = outshp.replace('.shp','')
    rsql = "SELECT * FROM "+theShpName+" WHERE fid>0"
    cmd = 'ogr2ogr ' + pth + '/' + inshp +  ' ' + pth + '/' + outshp + ' -sql \"' + rsql  +'\"'
    print cmd
    result = os.system(cmd)
    print result
    
    #remove temp cleanup
    if result == 0:
        deleteShapefile(outshp)


def makeashape(inshp,outshp,sql):
    pth = os.getcwd()
    #outshp = 'temp.shp'

    #remove temp file in case it exsists
    deleteShapefile(outshp)

    #create temp shapefile with sql filter
    cmd = 'ogr2ogr ' + pth + '/' + outshp +  ' ' + pth + '/'+inshp+' -sql \"' + sql  +'\"'
    print cmd
    result = os.system(cmd)
    print result

def makecsv(csv,shp):
    pth = os.getcwd()
    #outshp = 'temp.shp'

    #remove temp file in case it exsists
    deleteShapefile(csv+'.csv)

    #create temp shapefile with sql filter
    cmd = 'ogr2ogr -f "CSV" '+csv+'.csv '+shp+'.shp'
    print cmd
    result = os.system(cmd)
    print result
    

def copyshapefile(inshp,outshp):
    
    pth = os.getcwd()


    #remove temp file in case it exsists
    deleteShapefile(inshp)

    #create temp shapefile with sql filter
    cmd = 'ogr2ogr ' + inshp + ' ' + outshp
    print cmd
    result = os.system(cmd)
    print result
    return outshp


def mergeshapefile(inshp,addshp):
    pth = os.getcwd()

    theShpName = inshp.replace('.shp','')
    #create temp shapefile with sql filter
    cmd = 'ogr2ogr -update -append '+inshp+' '+addshp+' -nln ' + theShpName
    print cmd
    result = os.system(cmd)
    print result
    
def transform(fromepsg,toepsg,toshp,outshp)
    #remove temp file in case it exsists
    deleteShapefile(inshp)

    cmd = 'ogr2ogr   -f "ESRI Shapefile" -s_srs "EPSG:"'+fromepsg+'"  -t_srs "EPSG:'+toepsg+'" '+toshp+' '+outshp

    print cmd
    result = os.system(cmd)
    print result
#sql=""
#makeopenblock(shp,sql)


#get City Boundaries or jurisdictions
name = "coa_active_jurisdictions"
shp = getzip("http://opendataserver.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_active_jurisdictions&maxFeatures=1000000&outputFormat=SHAPE-ZIP",name+".zip")
sql = "SELECT * FROM "+name+" WHERE jurisdicti <> 'Buncombe County'"
makeopenblockshapes(shp,sql)

#get city of asheville neighborhoods
name = "coa_asheville_neighborhoods"
shp = getzip("http://opendataserver.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_asheville_neighborhoods&maxFeatures=1000000&outputFormat=SHAPE-ZIP",name+".zip")

#get crime data for city of asheville
name = "coa_crime_mapper_locations_view"
shp = getzip("http://opendataserver.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_crime_mapper_locations_view&maxFeatures=1000000&outputFormat=SHAPE-ZIP",name +  ".zip")

sql = "SELECT * FROM "+name+" WHERE x>0 or y>0"
makeopenblockshapes(shp,sql)
sql = "SELECT * FROM "+name+" WHERE agency='APD'"
makeopenblockshapes(shp,sql)
sql = "SELECT *, cast('offense' as character(150) )as 'title'   FROM "+name+" WHERE agency='APD'"
makeopenblockshapes(shp,sql)
sql = "SELECT *, cast('severity' as character(150) )as 'reason'   FROM "+name+" WHERE agency='APD'"
makeopenblockshapes(shp,sql)
sql = "SELECT *, cast('address' as character(150) )as 'locname'   FROM "+name+" WHERE agency='APD'"
makeopenblockshapes(shp,sql)
specchar = '\\"-\\"'
sql = "SELECT *, cast(concat('casenumber' , "+specchar+" , 'severity'  ,  "+specchar+" , 'offense'  , "+specchar+" , 'address') as character(254))  as 'desc' FROM "+name+" WHERE agency='APD'"
makeopenblockshapes(shp,sql)
specchar = '\\"/\\"'
sql="SELECT *,cast(concat(substr(cast('thedate' as character(150)),6,6),"+specchar+",substr(cast('thedate' as character(150)),1,4)) as character(150)) as item_date  FROM "+name+"  "
makeopenblockshapes(shp,sql)


#get development data for city of asheville
name = "coa_development_locations_view"
shp = getzip("http://opendataserver.ashevillenc.gov/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=coagis:coa_development_locations_view&maxFeatures=1000000&outputFormat=SHAPE-ZIP",name +  ".zip")

sql="SELECT * FROM "+name+" WHERE x>0 or y>0"
makeopenblockshapes(shp,sql)
sql="SELECT *, cast('name' as character(150) )as 'title'   FROM "+name
makeopenblockshapes(shp,sql)
sql="SELECT *, cast('label' as character(150) )as 'locname'   FROM "+name
makeopenblockshapes(shp,sql)
sql="SELECT *, cast('label' as character(150) )as 'locname'   FROM "+name
makeopenblockshapes(shp,sql)
specchar = '\\"-\\"'
sql="SELECT *, cast(concat('label' ,"+specchar+" , 'project_id'  ,  "+specchar+" , 'name'  , "+specchar+", 'reason') as character(254) )as 'desc'   FROM "+name
makeopenblockshapes(shp,sql)
specchar = '\\"/\\"'
sql="SELECT *,cast(concat(substr(cast('startdate' as character(150)),6,6),"+specchar+",substr(cast('startdate' as character(150)),1,4)) as character(150)) as item_date  FROM "+name
makeopenblockshapes(shp,sql)

outshp1="test1.shp"
escapedone='\\"Under Review\\"'
escapedtwo='\\"1\\"'
sql="SELECT *, cast("+escapedone+" as character(150) )as 'reason'   FROM "+name" where status="+escapedtwo
makeashape(shp,outshp1,sql)

outshp2="test2.shp"
escapedone='\\"Unknown\\"'
escapedtwo='\\"2\\"'
sql="SELECT *, cast("+escapedone+" as character(150) )as 'reason'   FROM "+name+" where status="+escapedtwo
makeashape(shp,outshp2,sql)


outshp3="test3.shp"
escapedone='\\"Project Approved\\"'
escapedtwo='\\"3\\"'
sql="SELECT *, cast("+escapedone+" as character(150) )as 'reason'   FROM "+name+" where status="+escapedtwo
makeashape(shp,outshp3,sql)


outshp4="test4.shp"
escapedone='\\"Denied\\"'
escapedtwo='\\"4\\"'
sql="SELECT *, cast("+escapedone+" as character(150) )as 'reason'   FROM "+name+" where status="+escapedtwo
makeashape(shp,outshp4,sql)


outshp5="test5.shp"
escapedone='\\"Project Completed\\"'
escapedtwo='\\"5\\"'
sql="SELECT *, cast("+escapedone+" as character(150) )as 'reason'   FROM "+name+" where status="+escapedtwo
makeashape(shp,outshp5,sql)


outshp6="test6.shp"
escapedone='\\"Application Withdrawn\\"'
escapedtwo='\\"5\\"'
sql="SELECT *, cast("+escapedone+" as character(150) )as 'reason'   FROM "+name+" where status="+escapedtwo
makeashape(shp,outshp6,sql)

ouputshp="temp.shp"
copyshapefile(ouputshp,outshp1)
mergeshapefile(ouputshp,outshp2)
mergeshapefile(ouputshp,outshp3)
mergeshapefile(ouputshp,outshp4)
mergeshapefile(ouputshp,outshp5)
mergeshapefile(ouputshp,outshp6)
    
deleteShapefile(outshp1)
deleteShapefile(outshp2)
deleteShapefile(outshp3)
deleteShapefile(outshp4)
deleteShapefile(outshp5)
deleteShapefile(outshp6)
#deleteShapefile(ouputshp)

#transform data
frme = '2264'
toe = '4326'
transform(frme,toe,'coa_city_4326.shp','coa_active_jurisdictions.shp')
transform(frme,toe,'coa_crime_4326.shp','coa_crime_mapper_locations_view.shp')
transform(frme,toe,'coa_hoods_4326.shp','coa_asheville_neighborhoods.shp')
transform(frme,toe,'coa_development_4326.shp','coa_development_locations_view.shp')

name="coa_crime_4326"
shp="coa_crime_4326.shp"
sql="SELECT *, cast(substr(OGR_GEOM_WKT,27,17) as numeric(12,10)) as lat, cast(substr(OGR_GEOM_WKT,8,19) as numeric(12,10)) as long FROM "+name+" WHERE agency='APD'"
makeopenblockshapes(shp,sql)

name="coa_development_4326"
shp="coa_development_4326.shp"
sql="SELECT *, cast(substr(OGR_GEOM_WKT,27,17) as numeric(12,10)) as lat, cast(substr(OGR_GEOM_WKT,8,19) as numeric(12,10)) as long FROM "+name
makeopenblockshapes(shp,sql)

makecsv('coa_crime','coa_crime_4326')
makecsv('coa_development','coa_development_4326')


##sql=""
##makeopenblock(shp,sql)
##sql=""
##makeopenblock(shp,sql)




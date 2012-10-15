from osgeo import ogr
import sys
import string
import urllib2
import os,zipfile
from osgeo import osr

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
    cmd = pth + '\\ogr2ogr.exe ' + pth + '\\' + outshp +  ' ' + pth + '\\'+inshp+' -sql \"' + sql  +'\"'
    print cmd
    result = os.system(cmd)
    print result

    #remove original shapefile
    if result == 0:
        deleteShapefile (inshp)

    #recreate orig
    theShpName = outshp.replace('.shp','')
    rsql = "SELECT * FROM "+theShpName+" WHERE fid>0"
    cmd = pth + '\\ogr2ogr.exe ' + pth + '\\' + inshp +  ' ' + pth + '\\' + outshp + ' -sql \"' + rsql  +'\"'
    print cmd
    result = os.system(cmd)
    print result
    
    #remove temp cleanup
    if result == 0:
        deleteShapefile(outshp)


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
##sql=""
##makeopenblock(shp,sql)
##sql=""
##makeopenblock(shp,sql)
##sql=""
##makeopenblock(shp,sql)
##sql=""
##makeopenblock(shp,sql)
##sql=""
##makeopenblock(shp,sql)
##sql=""
##makeopenblock(shp,sql)




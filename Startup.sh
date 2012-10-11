#!/bin/bash


##next open block likes data in different projections.
#like everything in data and IT there 100 ways to do the samething this is one.
# we need to get gdal first. GDAL is an open source command line program to translate spatuial information www.gdal.org
sudo apt-get install gdal-bin

#for setting path for running scripts
export PATH = "$PATH:~/opendataday_workshop"



#replace the settings python script with the git hub copy the new python importer script from git hub repository
sudo chmod 664 ~/opendataday_workshop/settings.py
sudo chmod 664 ~/opendataday_workshop/Import_blocks_opendataday.py
sudo mv /home/openblock/openblock/src/myblock/myblock/settings.py /home/openblock/openblock/src/myblock/myblock/settings_orig.py
sudo mv /home/openblock/openblock/lib/python2.7/site-packages/django/contrib/gis/db/backends/adapter.py  /home/openblock/openblock/lib/python2.7/site-packages/django/contrib/gis/db/backends/adapter_orig.py
sudo mv /home/openblock/openblock/src/openblock/ebpub/ebpub/streets/blockimport/esri/importers/blocks.py /home/openblock/openblock/src/openblock/ebpub/ebpub/streets/blockimport/esri/importers/blocks_orig.py
sudo cp  ~/opendataday_workshop/settings.py /home/openblock/openblock/src/myblock/myblock/settings.py
sudo cp ~/opendataday_workshop/Import_blocks_opendataday.py /home/openblock/openblock/src/openblock/ebpub/ebpub/streets/blockimport/esri/importers/blocks.py
sudo cp ~/opendataday_workshop/adapter.py  /home/openblock/openblock/lib/python2.7/site-packages/django/contrib/gis/db/backends/adapter.py 
sudo chown openblock:openblock /home/openblock/openblock/lib/python2.7/site-packages/django/contrib/gis/db/backends/adapter.py 
sudo chmod 664 /home/openblock/openblock/lib/python2.7/site-packages/django/contrib/gis/db/backends/adapter.py 
sudo chown openblock:openblock /home/openblock/openblock/src/myblock/myblock/settings.py
sudo chmod 664 /home/openblock/openblock/src/myblock/myblock/settings.py
sudo chown openblock:openblock /home/openblock/openblock/src/openblock/ebpub/ebpub/streets/blockimport/esri/importers/blocks.py
sudo chmod 664 /home/openblock/openblock/src/openblock/ebpub/ebpub/streets/blockimport/esri/importers/blocks.py

#start openblock enviroment this will have to be manually?
#sudo su - openblock
##cd /home/openblock/openblock
#source bin/activate
#xport DJANGO_SETTINGS_MODULE=myblock.settings

sudo touch /home/openblock/openblock/wsgi/myblock.wsgi


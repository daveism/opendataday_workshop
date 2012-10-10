#!/bin/bash

#start openblock enviroment
sudo su - openblock
cd /home/openblock/openblock
source bin/activate
export DJANGO_SETTINGS_MODULE=myblock.settings



#replace the settings python script with the git hub copy the new python importer script from git hub repository
sudo chmod 664 ~/opendataday_workshop/settings.py
sudo chmod 664 ~/opendataday_workshop/Import_blocks_opendataday.py
sudo mv /home/openblock/openblock/src/myblock/myblock/settings.py /home/openblock/openblock/src/myblock/myblock/settings_orig.py
sudo mv /home/openblock/openblock/src/openblock/ebpub/ebpub/streets/blockimport/esri/importers/blocks.py /home/openblock/openblock/src/openblock/ebpub/ebpub/streets/blockimport/esri/importers/blocks_orig.py
sudo cp  ~/opendataday_workshop/settings.py /home/openblock/openblock/src/myblock/myblock/settings.py
sudo cp ~/opendataday_workshop/Import_blocks_opendataday.py /home/openblock/openblock/src/openblock/ebpub/ebpub/streets/blockimport/esri/importers/blocks.py
sudo chown openblock /home/openblock/openblock/src/myblock/myblock/settings.py

sudo touch /home/openblock/openblock/wsgi/myblock.wsgi


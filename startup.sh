#!/bin/bash
LOG=/tmp/mylog
cat /dev/null > $LOG
exec >> $LOG
exec 2>&1

sudo apt-get install -y python
sudo apt-get install -y python-pip
cd test-parcel-app/django
pip install -r requirements.txt
cd notejam
sudo python manage.py -y syncdb
sudo python manage.py -y migrate
sudo python manage.py runserver 0.0.0.0:8000
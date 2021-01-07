#!/bin/bash
LOG=/tmp/mylog
cat /dev/null > $LOG
exec >> $LOG
exec 2>&1

sudo apt update
sudo apt install -y python
sudo apt install -y python-pip
cd test-parcel-app/django
pip install -r requirements.txt
cd notejam
python manage.py syncdb
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
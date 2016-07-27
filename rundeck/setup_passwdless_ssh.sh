#! /bin/bash
cd ~
echo -e  'y\n'|ssh-keygen -q -t rsa -N "" -f id_rsa

if [ ! -d ~/.ssh ]; then 

		mkdir ~/.ssh

fi

cp -f id_rsa.pub ~/.ssh/authorized_keys
cp -f id_rsa  /tmp
chmod 777 /tmp/id_rsa


mv id_rsa.pub ~/.ssh/
mv id_rsa  ~/.ssh/

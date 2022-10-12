#!/bin/bash
# checking linux distribution
dis=$(lsb_release -i | cut -f 2)
if [ $dis = Ubuntu ]
then
# installation

        echo "system is detected as ubuntu"
        echo "installing apache2 on your ubuntu machine"
        apt-get update -y
        apt install apache2 -y
        systemctl start apache2
        systemctl enable apache2
        echo "Success, apache installed successfully :)"
        systemctl status apache2 | grep active
        chmod 755 /var/www
        chown -R $USER:$USER /var/www

# creating a sample file

        cd /var/www/html
        echo "<h1>">>sample.html
        echo "Hello, it woked :)" >>sample.html
        echo "</h1>" >>sample.html
        echo " Hello user,you can view the samplepage on sample.html"


else
        echo "system is detected as RHEL"
        yum check-update
        yum update all -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "Success, apache installed successfully :)"

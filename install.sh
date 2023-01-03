#!/bin/bash
d=$(date |awk '{print $5}')
# checking linux distribution
cat /etc/os-release |sed -n 's|^ID="\([a-z]\{4\}\).*|\1|p' >distro.txt

function sample_file ()

{
        cd /var/www/html
        cp index.html index$d.html
        rm index.html
        echo "<h1>">>index.html
        echo "Hello, it woked :)" >>index.html
        echo "</h1>" >>index.html
        echo " Hello user,you can view the samplepage"
}

function wordpress_install ()

{
        echo "downloading latest  wordpress for you,please standby for a few moments"
        cd /var/www/html
        wget -c http://wordpress.org/latest.tar.gz
        tar -xzvf latest.tar.gz
        rsync -av wordpress/* /var/www/html/
        chown -R www-data:www-data /var/www/html/
        cp wp-config-sample.php wp-config.php
        sed -i "s/database_name_here/$db/;s/username_here/$user/;s/password_here/$pass/" wp-config.php
}
function mysql_db ()

{

                #read -p 'enter the mysql root password: ' password

                #if [ -z "$password" ] ;
                        #then
                        #echo "Please provide the root password"
                        #exit 1
                #fi
		echo "Enter the credentials for the new database"
                read -p 'enter the db name: ' db
                read -p 'enter the username: ' user
                read -p 'enter the password: ' pass
                mysql -e "CREATE DATABASE $db" -u root -p$password
                mysql -e "CREATE USER '$user'@'localhost' IDENTIFIED BY '$pass'" -u root -p$password
                mysql -e "GRANT ALL PRIVILEGES ON $db.* TO '$user'@'localhost'" -u root -p$password
                mysql -e "FLUSH PRIVILEGES" -u root -p$password
                echo "database $db is created successfully"
}

function final()
{
        echo "Success"
	echo
        echo "You can access your website in the browser, :)"

}

function wp_check ()
{
#echo "Please make sure that you have installed and configured MYSQL before proceeding"

 					if [ -f /var/www/html/wp-config.php ];
     						then
            						echo "Wordpress files found"
							echo
							read -p "Would you like to continue?,enter YES or NO: " wpfiles

            								if [ $wpfiles = NO ]
            									then
                    									echo "installation cancelled"
											exit 1
            									else
											{
											
											echo "reinstalling wordpress"
                    									cd /var/www/html

											db_bpk
                    									tar -czf backup.tar.gz *
                    									rm -rf wp-content wp-config.php index.php wp-activate.php wp-admin wp-blog-header.php wp-cron.php wp-load.php wp-login.php wp-settings.php
                        								
											read -p 'enter the mysql root password: ' password

                										if [ -z "$password" ] ;
                        									then
                        									echo "Please provide the root password"
                        									exit 1
               											fi
											
												mysql_db
												wordpress_install
												if [ -f /var/www/html/index.html ];
										                         then
                                        									mv index.html index$d.html
                        										 fi
                        										systemctl restart apache2
                        										final

												echo "Kindly proceed with finishing the installation"
												exit 1
											}
									fi

					  fi
					 

}

function db_bpk()

{
	read -p 'enter the mysql root password for taking database backup: ' password

                if [ -z "$password" ] ;
                        then
                        echo "Please provide the root password for taking database backup,unable to proceed..exiting"
                        exit 1
                fi

		dbb=$(cat wp-config.php | grep DB | awk '{print $3}'|head -n1|sed 's/^.//;s/.$//')

                mysqldump -u root -p$password $dbb > $dbb_$d.sql
}



#checking distribution

if [ -f /etc/debian_version ] ;
        then
        # installation (assuming the ubuntu version is 20.04 or above )

        echo "system is detected as ubuntu"
        echo "installing apache2 on your ubuntu machine"
        apt-get update -y
	apt install php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath
        apt install apache2 -y
        systemctl start apache2
        systemctl enable apache2
        echo "Success, apache installed successfully :)"
        systemctl status apache2 | grep active
        chmod 755 /var/www
        chown -R $USER:$USER /var/www
# creating a sample file
	read -p "would you like to install wordpress? enter YES or NO: " wp

		if [ $wp = NO ]
			then
				systemctl restart apache2
				final
				sample_file
			else 
			 	mysql --version 1>&2
				if [ $? -eq 0 ];
				then 
					echo "MYSQL installation found,proceeding"

				else
					echo "MYSQL not found, kindly proceed after configuring MYSQL"
					exit 1
				fi
				  
				wp_check            				
					 

		
	read -p 'enter the mysql root password: ' password

                if [ -z "$password" ] ;
                        then
                        	echo "Please provide the root password"
                        	exit 1
                fi


			mysql_db
			wordpress_install
				
			if [ -f /var/www/html/index.html ];
				 then
					mv index.html index$d.html
			fi	 
			systemctl restart apache2
			final
			echo "Kindly proceed with finishing the installation"
		fi		
elif  [ -f /etc/redhat-release ] ;
		then
			
			echo "system is detected as RHEL"
			yum check-update
			yum update all -y
			yum install epel-release -y 
			rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
			yum --enablerepo=remi-php74 install php -y
			yum install httpd -y
			systemctl start httpd
			systemctl enable httpd 
			echo "Success, apache installed successfully :)"
			systemctl status httpd | grep active
		        chmod 755 /var/www
		        chown -R $USER:$USER /var/www
read -p "would you like to install wordpress? enter YES or NO: " wp

		if [ $wp = NO ]
			then
				systemctl restart httpd
				final
				sample_file
			else 
				mysql --version 1>&2
				if [ $? -eq 0 ];
				then 
					echo "MYSQL installation found,proceeding"

				else
					echo "MYSQL not found, kindly proceed after configuring MYSQL"
					exit 1
				fi
				
				wp_check	 

		
	read -p 'enter the mysql root password: ' password

                if [ -z "$password" ] ;
                        then
                        	echo "Please provide the root password"
                        	exit 1
                fi


			mysql_db
			wordpress_install
				
			if [ -f /var/www/html/index.html ];
				 then
					mv index.html index$d.html
			fi	 
			systemctl restart httpd
			final
			echo "Kindly proceed with finishing the installation"
		fi	
		
		
elif [ -f distro.txt ];
then

                        echo "system is detected as amazon linux"
                        yum check-update
			amazon-linux-extras install php7.4 -y
                        yum update all -y
                        yum install httpd -y
                        systemctl start httpd
                        systemctl enable httpd
                        echo "Success, apache installed successfully :)"
                        systemctl status httpd | grep active
                        chmod 755 /var/www
                        chown -R apache:apache /var/www/html/*
read -p "would you like to install wordpress? enter YES or NO: " wp

                if [ $wp = NO ]
                        then
                                systemctl restart httpd
                                final
                                sample_file
                        else
                                mysql --version 1>&2
                                if [ $? -eq 0 ];
                                then
                                        echo "MYSQL installation found,proceeding"

                                else
                                        echo "MYSQL not found, kindly proceed after configuring MYSQL"
                                        exit 1
                                fi

                                wp_check


        read -p 'enter the mysql root password: ' password

                if [ -z "$password" ] ;
                        then
                                echo "Please provide the root password"
                                exit 1
                fi


                        mysql_db
                        wordpress_install

                        if [ -f /var/www/html/index.html ];
                                 then
                                        mv index.html index$d.html
                        fi
                        systemctl restart httpd
                        final
                        echo "Kindly proceed with finishing the installation"
                fi



else 
	echo -e "unsupported distribution"
fi

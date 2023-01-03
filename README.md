  Hello folks,
  
It is a very basic bash script to install apache and wordpress on the linux machine, initially the script will determine the linux distribution and then it will proceed with the installation.
Once apache is installed you can install wordpress on your server using this script if you need, you need to install and configure MYSQL before proceeding with the wordpress installtion.

Prerequisite

- user with root privileges
- server with git installed

 Use git clone to download the project files to your local system for execution
```
git clone https://github.com/antony-a-n/apache-wordpress-installation.git
 ```
- run the bash script with required privileges
```
cd apache-wordpress-installation
chmod 755 install.sh
./install.sh
```

# Setup Drupal in Azure Web apps – 
1.	Launch Azure web apps (PHP v8.1 runtime stack). If database is required please go with the `Try the new Web + Database experience` plan.
> Note that PHP version should be `8.1`

2.	For get the terminal of the Web apps go to the **Web app** > **Development** > **SSH**

3.	Install **git** and **zip** using the following command – 
``` bash
apt install -y git zip
```

4.   Vaidate the installed package and php version should be v**8.1**.
``` bash
php -v
git --help
zip --help
```

5.	Install composer by the following commands
```
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --install-dir=/home --filename=composer
php -r "unlink('composer-setup.php');"
```

6.	Validate the composer version after installing.
```
php /home/composer
```

7.	Install apigee kickstart project using the following command
``` bash
cd /home/site/wwwroot/
php /home/composer create-project apigee/devportal-kickstart-project:9.x-dev devportal --no-interaction
```

8.	Configure the nginx and add the root to the installation directory.
``` bash
cp /etc/nginx/sites-enabled/default /home/default
nano /home/default
# paste that line in the file 
root /home/site/wwwroot/devportal/web;
```

9.	In the web apps, data is not persistence accept the /home directory, so we will keep the nginx configuration inside it and copy the file into default ngnix configuration path after restarting the web server. so, for this go to the web apps configuration and paste the lines into there and save it. Web App > Configuration > General Settings > startup command
``` bash
cp /home/default /etc/nginx/sites-enabled/default; service nginx restart
```

10.	 After that create a private directory inside the web directory and change the permission of the directory
```
mkdir /home/site/wwwroot/devportal/private/
```

11.	 Configure the settings file in the web directory for the private file by the following command
```
cd /home/site/wwwroot/devportal/web/sites/default/
cp default.settings.php settings.php 
nano settings.php
#paste the below line in the line number 547
$settings['file_private_path'] = $app_root . '../private';
```

12.	Go to the database and change the below parameter in the tuning section of the database to communicate with the web apps and the parameter should be off require_secure_transport.
After tuning the options save the configuration and wait to redeploy the database. 

13.	After that hit the URL and then you will get the UI of the Drupal kickstart. Add the database parameter that is pre-configured in the configuration of the web apps with click on advance options. 

14.	Go to the Web apps and copy the database parameters and paste into the drupal portal

15.	After Saving the database parameter you will see the below screen

16.	Skip the `APIGEE Edge` configuration.

17.	Now add the username **email** and **password** of the organization.

18.	Now your setup is ready to go.


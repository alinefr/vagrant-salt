# This state file is installs and configures the base wordpress environment 

# this is the symlink to the virtual box sync folder WP will live in, the target needs to match 
# /var/www/html/wordpress:
#  file.symlink:
#   - target: /www_src

# This block creates the wordpress database, user and sets user access. 
# wordpress_db:
#  mysql_database.present:
#   - name: wordpress
#  mysql_user.present:
#   - name: wordpress
#   - password: password
#  mysql_grants.present:
#   - database: wordpress.*
#   - grant: ALL PRIVILEGES
#   - user: wordpress
#   - host: '%'

# This downloads wordpress from official site and untar's to our sync folder
get_wordpress:
 cmd.run:
  - name: 'wget http://wordpress.org/latest.tar.gz && tar xzf latest.tar.gz'
  - cwd: /srv/www/

# This downloads and installs WP-Cli which is needed for the following steps
get_wp-cli:
 cmd.run:
  - name: 'curl -sS https://raw.github.com/wp-cli/wp-cli.github.com/master/installer.sh | bash'
  - cwd: /home/{{ pillar['user'] }}/
  - user: {{ pillar['user'] }}

# symlink's the WP binary to /usr/local/bin so it's in the PATH
/usr/local/bin/wp:
 file:
  - symlink
  - target: /home/vagrant/.wp-cli/bin/wp

# This command tells wp-cli to create our wp-config.php, DB info needs to be the same as above
config_wordpress:
 cmd.run:
  - cwd: /srv/www/wordpress/
  - name:  (echo "\$this_domain = \$_SERVER['HTTP_HOST'];"; echo "define('WP_HOME',\"http://{\$this_domain}\");"; echo "define('WP_SITEURL',\"http://{\$this_domain}\");") | wp core config --dbname=wordpress --dbuser=wpuser --dbpass=wpuser --extra-php 
  - user: {{ pillar['user'] }}

# This command tells wp-cli to install wordpress, the --url needs to be the same as the IP you set for the 
# Private IP in the Vagrantfile 
install_wordpress:
 cmd.run:
  - cwd: /srv/www/wordpress/
  - name: '/usr/local/bin/wp core install --url=http://localhost --title=development --admin_user=admin --admin_password=password --admin_email=aline@alinefreitas.com.br' 
  - user: {{ pillar['user'] }}

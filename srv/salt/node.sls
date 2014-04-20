mysql-server:
  pkg.installed: []
  service.running:
    - name: mysql
    - enable: True
    - require:
      - pkg: mysql-server

set-mysql-root-password:
  cmd.run:
    - name: 'echo "update user set password=PASSWORD(''{{salt['pw_safe.get']('mysql.root')}}'') where User=''root'';flush privileges;" | /usr/bin/env HOME=/ mysql -uroot mysql'
    - onlyif: '/usr/bin/env HOME=/ mysql -u root'
    - require:
      - service: mysql-server

change-mysql-root-password:
  cmd.run:
    - name: 'echo "update user set password=PASSWORD(''{{salt['pw_safe.get']('mysql.root')}}'') where User=''root'';flush privileges;" | mysql -uroot mysql'
    - onlyif: '(echo | mysql -uroot) && [ -f /root/.my.cnf ] && ! fgrep -q ''{{salt['pw_safe.get']('mysql.root')}}'' /root/.my.cnf'
    - require:
      - cmd: set-mysql-root-password

/root/.my.cnf:
  file.managed:
    - user: root
    - group: root
    - mode: '0600'
    - contents: "# this file is managed by salt; changes will be overriden!\n[client]\npassword='{{salt['pw_safe.get']('mysql.root')}}'\n"
    - require:
      - cmd: change-mysql-root-password
  
mysql:
  service.running:
    - name: mysql
    - require:
      - pkg: mysql-server

python-mysqldb:
  pkg.installed

coffeescript:
  pkg.installed

dbconfig:
  mysql_user.present:
    - name: vagruser
    - password: devman
    - require:
      - service: mysql
      - pkg: python-mysqldb

  mysql_database.present:
    - name: workoutbot
    - require:
      - mysql_user: dbconfig

  mysql_grants.present:
    - grant: select,insert,update,delete
    - database: workoutbot.*
    - user: vagruser
    - require:
      - mysql_database: dbconfig 


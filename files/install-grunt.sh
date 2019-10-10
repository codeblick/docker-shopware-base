#!/usr/bin/with-contenv sh
set -e;

apt update
apt install -y nodejs npm
npm install -g grunt-cli

mkdir /etc/services.d/grunt

cat << EOF > /etc/services.d/grunt/run
#!/usr/bin/with-contenv sh

while :
do
  cd /var/www/html/var/cache/
  ./clear_cache.sh

  cd ../..
  ./bin/console sw:theme:dump:configuration

  cd themes/
  npm install

  grunt
done

EOF

chmod 755 /etc/services.d/grunt/run

apt autoremove -y
apt clean
rm -rf /var/lib/apt/lists/*

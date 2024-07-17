#/etc/bin/bash
path=$(pwd)
sudo apt install openssl
sudo apt build-dep squid
sudo apt install libssl-dev
mkdir ~/squid_build && cd ~/squid_build
sudo apt source squid
apt-get install devscripts
sed  '/ \--with-dedfault-user=proxy \\ /a \t\t--enable-ssl \\ \n
\t\t--enable-ssl-crtd \\ \n
\t\t--with-openssl' debian/rules
# sudo vi debian/rules

# --enable-ssl \
# --enable-ssl-crtd \
# --with-openssl

sudo debuild -d -uc -us
sudo dpkg -i ../squid*.deb
squid -v | grep ssl
mkdir /etc/squid/ssl
cd /etc/squid/ss
sudo openssl genrsa -out /etc/squid/ssl/squid.key
sudo openssl req -new -key /etc/squid/ssl/squid.key -out /etc/squid/ssl/squid.csr
sudo openssl x509 -req -days 3650 -in /etc/squid/ssl/squid.csr -signkey /etc/squid/ssl/squid.key -out /etc/squid/ssl/squid.pem
sudo openssl x509 -in /etc/squid/ssl/squid.pem -outform DER -out squid.der
chown -R proxy:proxy /etc/squid/ssl
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.save
sudo cp $path/squid.conf /etc/squid/
# sudo vi /etc/squid/squid.conf

# http_access allow all
# http_port 3128
# http_port 3129 intercept
# https_port 3130 intercept ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=4MB cert=/etc/squid/ssl/squid.pem key=/etc/squid/ssl/squid.key
# sslproxy_cert_error allow all
# sslproxy_flags DONT_VERIFY_PEER
# always_direct allow all
# ssl_bump server-first all
# ssl_bump none all
# sslcrtd_program /usr/lib/squid/security_file_certgen -s /var/lib/ssl_db -M 4MB
rm -rf /var/lib/ssl_db
/usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB
chown -R proxy:proxy /var/lib/ssl_db
echo 1 >> /proc/sys/net/ipv4/ip_forward
sudo systemctl restart squid

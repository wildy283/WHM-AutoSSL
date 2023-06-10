#!/bin/bash
read -p "Input ur Hostname" hostnames1

if ! command -V curl > /dev/null 2>&1; then
  echo "Curl not installed, install it and try again !"; exit
fi
if ! command -V socat > /dev/null 2>&1; then
  echo "Socat not installed, install it and try again !"; exit
fi

check_domain_ip=$( curl -s --ipv4 --url "https://api1.wildy.id/host2ip?domain=${hostnames1}")
geturip=$( curl -s --ipv4 --url "https://api1.wildy.id/myip" )

if [[ $check_domain_ip == $geturip ]]; then
  read -p "Email address : " emails
  wget -O -  https://get.acme.sh | sh -s email=$emails
  cd /root/.acme.sh
  /root/.acme.sh/acme.sh --listen-v4 --issue -d ${hostnames1} -w /var/www/html/
  hostname -b ${hostnames1}
  hostname > /etc/hostname
  crts="$(cat /root/.acme.sh/$(hostname)_ecc/$(hostname).cer | perl -MURI::Escape -ne 'print uri_escape($_)')"
  keys="$(cat /root/.acme.sh/$(hostname)_ecc/$(hostname).key | perl -MURI::Escape -ne 'print uri_escape($_)')"
  cas="$(cat /root/.acme.sh/$(hostname)_ecc/ca.cer | perl -MURI::Escape -ne 'print uri_escape($_)')"
  /usr/local/cpanel/bin/whmapi1 install_service_ssl_certificate service=cpanel crt="$crts" key="$keys" cabundle="$cas"
  /usr/local/cpanel/bin/whmapi1 install_service_ssl_certificate service=ftp crt="$crts" key="$keys" cabundle="$cas"
  /usr/local/cpanel/bin/whmapi1 install_service_ssl_certificate service=exim crt="$crts" key="$keys" cabundle="$cas"
  /usr/local/cpanel/bin/whmapi1 install_service_ssl_certificate service=dovecot crt="$crts" key="$keys" cabundle="$cas"
  systemctl restart cpanel
  clear; echo "Done !!!";
else
  echo "Invalid hostname, because hostname not pointed to ur server ip addresss"; exit
fi

if [[ $1 == 'renew' ]]; then
  /root/.acme.sh/acme.sh --listen-v4 --issue -d ${hostnames1} -w /var/www/html/
  hostname -b ${hostnames1}
  hostname > /etc/hostname
  crts="$(cat /root/.acme.sh/$(hostname)_ecc/$(hostname).cer | perl -MURI::Escape -ne 'print uri_escape($_)')"
  keys="$(cat /root/.acme.sh/$(hostname)_ecc/$(hostname).key | perl -MURI::Escape -ne 'print uri_escape($_)')"
  cas="$(cat /root/.acme.sh/$(hostname)_ecc/ca.cer | perl -MURI::Escape -ne 'print uri_escape($_)')"
  /usr/local/cpanel/bin/whmapi1 install_service_ssl_certificate service=cpanel crt="$crts" key="$keys" cabundle="$cas"
  /usr/local/cpanel/bin/whmapi1 install_service_ssl_certificate service=ftp crt="$crts" key="$keys" cabundle="$cas"
  /usr/local/cpanel/bin/whmapi1 install_service_ssl_certificate service=exim crt="$crts" key="$keys" cabundle="$cas"
  /usr/local/cpanel/bin/whmapi1 install_service_ssl_certificate service=dovecot crt="$crts" key="$keys" cabundle="$cas"
  systemctl restart cpanel
  echo "Done, ur certificate already renewed !"; exit
fi


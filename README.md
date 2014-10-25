# porthole-client

Opening views to new worlds

## Setting up an rPi

 * set time to UTC, lang to en_us UTF8
 * `sudo aptitude update`
 * `sudo aptitude upgrade`
 * `sudo aptitude install gnupg-curl libfile-mimeinfo-perl libnet-dbus-perl`
 * `sudo aptitude install ffmpeg autoconf automake bind9-host bison build-essential curl daemontools debian-keyring dnsutils ed git htop imagemagick iputils-tracepath libatlas-base-dev libcurl3 libcurl3-gnutls libcurl4-openssl-dev libevent-dev libglib2.0-dev libgsl0-dev libjpeg-dev libjpeg62 libmagickcore-dev libmagickwand-dev libmcrypt-dev libmysqlclient-dev libpng12-0 libpng12-dev libpq-dev libsqlite3-dev libssl-dev libxml2-dev libxslt-dev mercurial mysql-client netcat-openbsd nmap nodejs openjdk-6-jdk openjdk-6-jre-headless openssh-client openssh-server postgresql-client python-dev ruby rubygems screen socat sqlite3 telnet zlib1g-dev`
 * Something like this: `ffmpeg -f video4linux2 -i /dev/video0 -c:v libx264 -c:a nellymoser -f flv rtmp://localhost/myapp/mystream`

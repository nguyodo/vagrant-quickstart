# http://link2linux.blogspot.nl/2015/07/install-oracle-jdk-8-on-debian-81-jessie.html
# http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html
TOMCAT_VERSION="8.0.53"

echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
ls /etc/apt/sources.list.d/
cat /etc/apt/sources.list.d/webupd8team-java.list 
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
apt-get -y update
apt-get -y upgrade
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y install oracle-java8-installer
#
#
#
sudo adduser \
    --system \
    --shell /bin/bash \
    --gecos 'Tomcat Java Servlet and JSP engine' \
    --group \
    --disabled-password \
    --home /home/tomcat \
    tomcat
mkdir -p ~/tmp
cd ~/tmp
wget http://apache.mirror.gtcomm.net/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
tar xvzf ./apache-tomcat-$TOMCAT_VERSION.tar.gz
rm ./apache-tomcat-$TOMCAT_VERSION.tar.gz
sudo mkdir -p /usr/share/tomcat8
sudo mv ~/tmp/apache-tomcat-$TOMCAT_VERSION /usr/share/tomcat8
sudo rm -f /usr/share/tomcat
sudo ln -s /usr/share/tomcat8/apache-tomcat-$TOMCAT_VERSION /usr/share/tomcat
sudo chown -R tomcat:tomcat /usr/share/tomcat8
sudo chmod +x /usr/share/tomcat/bin/*.sh



cat > /etc/init.d/tomcat << "EOF"
#!/bin/bash
### BEGIN INIT INFO
# Provides:        tomcat
# Required-Start:  $network
# Required-Stop:   $network
# Default-Start:   2 3 4 5
# Default-Stop:    0 1 6
# Short-Description: Start/Stop Tomcat server
### END INIT INFO
PATH=/sbin:/bin:/usr/sbin:/usr/bin
start() {
  /bin/su - tomcat -c /usr/share/tomcat/bin/startup.sh
}
stop() {
  /bin/su - tomcat -c /usr/share/tomcat/bin/shutdown.sh 
}
case $1 in
  start|stop) $1;;
  restart) stop; start;;
  *) echo "Run as $0 <start|stop|restart>"; exit 1;;
esac
EOF

chmod 755 /etc/init.d/tomcat
update-rc.d tomcat defaults
service tomcat start

#!/usr/bin/env bash
# Download and install Silk+Yaf for a standalone installation
BASEDIR=$PWD
SENSOR_CONF="/data/sensors.conf"
SITE_CONF="/data/silk.conf"
LOCAL_NET=$2
LOCAL_NET_PH="LOCAL_NETWORK_ADDR"

if [ "$#" -lt 2 ]; then
    echo "usage: ./silk-yaf.sh <internal-ip-block> \nThe internal IP block should be the network address of the internal network to be monitored (ex. 192.168.1.0/24)\n"
else if [ "$#" -gt 2 ]; then
    echo "usage: ./silk-yaf.sh <internal-ip-block> \nThe internal IP block should be the network address of the internal network to be monitored (ex. 192.168.1.0/24)\n"
fi

### YAF
echo "[-] Installing YaF"
sudo apt-get -y install wget build-essential pkg-config libfixbuf3-dev libpcap0.8-dev python-dev glib2.0
wget https://tools.netsa.cert.org/releases/yaf-2.8.4.tar.gz
tar -xzf yaf-2.8.4.tar.gz && cd yaf-2.8.4
./configure --enable-applabel --enable-plugins
make
sudo make install
cd $BASEDIR

### SiLK
echo "[-] Installing SiLK"
wget https://tools.netsa.cert.org/releases/silk-3.15.0.tar.gz
tar -xzf silk-3.15.0.tar.gz && cd silk-3.15.0
./configure --with-python
make
sudo make install

sudo mkdir /data
sudo cp site/twoway/silk.conf /data/silk.conf
sudo cp src/rwflowpack/rwflowpack.init.d /etc/init.d/rwflowpack
sudo chmod +x /etc/init.d/rwflowpack
sudo cp src/rwflowpack/rwflowpack.conf /usr/local/etc/rwflowpack.conf

cd $HOME
cat <<EOF >>silk.conf
/usr/local/lib
/usr/local/lib/silk
EOF

sudo mv silk.conf /etc/ld.so.conf.d/silk.conf
sudo ldconfig
cd $BASEDIR

cp sensors.conf.template sensors.conf
sed -i "s|$LOCAL_NET_PH|$LOCAL_NET|" sensors.conf
sudo mv sensors.conf /data

sudo mv rwflowpack.conf.template /usr/local/etc/rwflowpack.conf
sudo chmod +x /usr/local/etc/rwflowpack.conf

sudo cp /usr/local/share/silk/etc/init.d/rwflowpack /etc/init.d
sudo sudo update-rc.d rwflowpack start 20 3 4 5 .
sudo service rwflowpack start


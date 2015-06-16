#!/bin/sh
#=========================================================

#=========================================================
echo "Install the packages..."
#=========================================================
sudo apt-get update
sudo apt-get -y install unzip vim default-jre rungetty firefox xvfb

#=========================================================
echo "Set autologin for the Vagrant user..."
#=========================================================
sudo sed -i '$ d' /etc/init/tty1.conf
sudo echo "exec /sbin/rungetty --autologin vagrant tty1" >> /etc/init/tty1.conf

#=========================================================
echo -n "Start X on login..."
#=========================================================
SCREEN_WIDTH=1360
SCREEN_HEIGHT=1020
SCREEN_DEPTH=24
DISPLAY=:99.0
GEOMETRY="$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"
PROFILE_STRING=$(cat <<EOF
xvfb-run --server-args="$DISPLAY -screen 0 $GEOMETRY -ac +extension RANDR" \
    java -jar selenium-server-standalone.jar -Dwebdriver.chrome.driver=./chromedriver
EOF
)
echo "${PROFILE_STRING}" >> .profile
echo "ok"

#=========================================================
echo "Download the latest chrome..."
#=========================================================
wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo rm google-chrome-stable_current_amd64.deb
sudo apt-get install -y -f

#=========================================================
echo "Download latest selenium server..."
#=========================================================
SELENIUM_VERSION=$(curl "https://selenium-release.storage.googleapis.com/" | perl -n -e'/.*<Key>([^>]+selenium-server-standalone[^<]+)/ && print $1')
wget "https://selenium-release.storage.googleapis.com/${SELENIUM_VERSION}" -O selenium-server-standalone.jar
chown vagrant:vagrant selenium-server-standalone.jar

#=========================================================
echo "Download latest chrome driver..."
#=========================================================
CHROMEDRIVER_VERSION=$(curl "http://chromedriver.storage.googleapis.com/LATEST_RELEASE")
wget "http://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
unzip chromedriver_linux64.zip
sudo rm chromedriver_linux64.zip
chown vagrant:vagrant chromedriver

#=========================================================
echo -n "Add host alias..."
#=========================================================
echo "192.168.33.1 host" >> /etc/hosts
echo "ok"

#=========================================================
echo "Reboot the VM"
#=========================================================
sudo reboot

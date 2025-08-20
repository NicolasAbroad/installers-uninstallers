TARGET_VERSION=0.12
URL=https://bitbucket.org/heldercorreia/speedcrunch/downloads/SpeedCrunch-${TARGET_VERSION}-linux64.tar.bz2
NAME=speedcrunch

wget -O $NAME.tar.bz2 $URL
sudo mkdir /opt/${NAME}
sudo tar -xjf ${NAME}.tar.bz2 -C /opt/${NAME}
sudo ln -s /opt/${NAME}/${NAME} /usr/local/bin/${NAME}
rm ${NAME}.tar.bz2

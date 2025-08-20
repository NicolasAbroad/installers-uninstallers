TARGET_VERSION=10.4.0
URL=https://github.com/peazip/PeaZip/releases/download/${TARGET_VERSION}/peazip_portable-${TARGET_VERSION}.LINUX.GTK2.x86_64.tar.gz
NAME=peazip

wget -O $NAME.tar.gz $URL
sudo mkdir /opt/${NAME}
sudo tar -xzf ${NAME}.tar.gz --strip-components=1 -C /opt/${NAME}
sudo ln -s /opt/${NAME}/${NAME} /usr/local/bin/${NAME}
rm ${NAME}.tar.gz

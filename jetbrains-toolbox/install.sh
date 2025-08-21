URL=https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-2.7.0.48109.tar.gz
NAME=jetbrains-toolbox

wget -O $NAME.tar.gz $URL
sudo mkdir /opt/${NAME}
sudo tar -xzf ${NAME}.tar.gz --strip-components=1 -C /opt/${NAME}
sudo ln -s /opt/${NAME}/bin/${NAME} /usr/local/bin/${NAME}
rm ${NAME}.tar.gz

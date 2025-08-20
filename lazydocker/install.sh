TARGET_VERSION=0.24.1
URL=https://github.com/jesseduffield/lazydocker/releases/download/v${TARGET_VERSION}/lazydocker_${TARGET_VERSION}_Linux_x86_64.tar.gz
NAME=lazydocker

wget -O $NAME.tar.gz $URL
sudo mkdir /opt/${NAME}
sudo tar -xzf ${NAME}.tar.gz -C /opt/${NAME}
sudo ln -s /opt/${NAME}/${NAME} /usr/local/bin/${NAME}
rm ${NAME}.tar.gz

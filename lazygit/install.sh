TARGET_VERSION=0.53.0
URL=https://github.com/jesseduffield/lazygit/releases/download/v${TARGET_VERSION}/lazygit_${TARGET_VERSION}_Linux_x86_64.tar.gz
NAME=lazygit

wget -O $NAME.tar.gz $URL
sudo mkdir /opt/${NAME}
sudo tar -xzf ${NAME}.tar.gz -C /opt/${NAME}
sudo ln -s /opt/${NAME}/${NAME} /usr/local/bin/${NAME}
rm ${NAME}.tar.gz

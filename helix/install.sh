TARGET_VERSION=25.07.1
URL=https://github.com/helix-editor/helix/releases/latest/download/helix-$TARGET_VERSION-x86_64-linux.tar.xz
NAME=hx

wget -O $NAME.tar.xz $URL
sudo mkdir /opt/${NAME}
sudo tar -xf ${NAME}.tar.xz --strip-components=1 -C /opt/${NAME}
sudo ln -s /opt/${NAME}/${NAME} /usr/local/bin/${NAME}
rm ${NAME}.tar.xz

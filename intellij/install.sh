TARGET_VERSION=2025.1
URL=https://download.jetbrains.com/idea/ideaIC-$TARGET_VERSION.tar.gz
NAME=intellij

wget -O $NAME.tar.gz $URL
sudo mkdir /opt/${NAME}
sudo tar -xzf ${NAME}.tar.gz --strip-components=1 -C /opt/${NAME}
sudo ln -s /opt/${NAME}/bin/idea /usr/local/bin/${NAME}
rm ${NAME}.tar.gz

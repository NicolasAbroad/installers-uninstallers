TARGET_VERSION=2025.04.30
URL=https://github.com/yt-dlp/yt-dlp/releases/download/${TARGET_VERSION}/yt-dlp_linux
NAME=yt-dlp

wget -O $NAME $URL
sudo mkdir /opt/${NAME}
sudo mv ${NAME} /opt/${NAME}/
sudo ln -s /opt/${NAME}/${NAME} /usr/local/bin/${NAME}

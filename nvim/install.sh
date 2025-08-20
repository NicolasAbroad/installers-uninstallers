URL=https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
NAME=nvim

wget -O $NAME.tar.gz $URL
sudo mkdir /opt/${NAME}
sudo tar -xzf ${NAME}.tar.gz --strip-components=1 -C /opt/${NAME}
sudo ln -s /opt/${NAME}/bin/${NAME} /usr/local/bin/${NAME}
rm ${NAME}.tar.gz

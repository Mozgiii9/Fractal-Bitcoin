#!/bin/bash

# Функция для отображения логотипа
display_logo() {
  echo -e '\e[40m\e[32m'
  echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ '
  echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
  echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
  echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
  echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
  echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
  echo -e '\e[0m'

  echo -e "\nПодписаться на канал may.crypto{🦅} чтобы быть в курсе самых актуальных нод - https://t.me/maycrypto\n"
}

# Функция для отображения статуса выполнения команды
status_message() {
  echo -e "\n\e[1;34m$1\e[0m"
}

# Отображение логотипа
display_logo
sleep 5

# Обновление и установка зависимостей
status_message "Обновление системы и установка зависимостей..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl build-essential pkg-config libssl-dev git wget jq make gcc chrony -y

# Загрузка и распаковка архива
status_message "Скачивание и распаковка архива..."
wget https://github.com/fractal-bitcoin/fractald-release/releases/download/v1.0.6/fractald-1.0.6-x86_64-linux-gnu.tar.gz
tar -zxvf fractald-1.0.6-x86_64-linux-gnu.tar.gz
rm -rf fractald-1.0.6-x86_64-linux-gnu.tar.gz
sleep 5

# Переход в директорию и копирование конфигурации
cd fractald-1.0.6-x86_64-linux-gnu || { echo "Не удалось перейти в директорию"; exit 1; }
status_message "Создание директории для данных и копирование конфигурации..."
mkdir data
cp ./bitcoin.conf ./data
sleep 5

# Создание и запуск сервиса
status_message "Настройка и запуск сервиса Fractal Node..."
sudo tee /etc/systemd/system/fractald.service > /dev/null <<EOF
[Unit]
Description=Fractal Node
After=network.target
[Service]
User=root
ExecStart=/root/fractald-1.0.6-x86_64-linux-gnu/bin/bitcoind -datadir=/root/fractald-1.0.6-x86_64-linux-gnu/data/ -maxtipage=504576000
Restart=always
RestartSec=3
LimitNOFILE=infinity
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable fractald
sudo systemctl start fractald
sleep 5

# Создание кошелька и сохранение приватного ключа
status_message "Создание кошелька и сохранение приватного ключа..."
cd bin || { echo "Не удалось перейти в директорию bin"; exit 1; }
./bitcoin-wallet -wallet=wallet -legacy create
sleep 5

echo -e "\n\e[1;34mСохраните Private Key от Вашего кошелька:\e[0m"
cd /root/fractald-1.0.6-x86_64-linux-gnu/bin || { echo "Не удалось перейти в директорию bin"; exit 1; }
./bitcoin-wallet -wallet=/root/.bitcoin/wallets/wallet/wallet.dat -dumpfile=/root/.bitcoin/wallets/wallet/MyPK.dat dump
cd ~
awk -F 'checksum,' '/checksum/ {print "Wallet Private Key:" $2}' .bitcoin/wallets/wallet/MyPK.dat
sleep 5

# Завершение установки и отображение логов
status_message "Установка ноды Fractal Bitcoin успешно завершена! Сейчас начнется отображение логов, используйте CTRL+C для выхода из отображения логов."
sleep 5
sudo journalctl -u fractald -fo cat

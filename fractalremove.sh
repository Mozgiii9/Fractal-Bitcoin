#!/bin/bash

# Функция для отображения статуса выполнения команды
status_message() {
  echo -e "\n\e[1;34m$1\e[0m"
}

# Остановка и удаление сервиса
status_message "Остановка и удаление сервиса Fractal Node..."
sudo systemctl stop fractald
sudo systemctl disable fractald
sudo rm /etc/systemd/system/fractald.service
sudo systemctl daemon-reload

# Удаление файлов программы и данных
status_message "Удаление файлов программы и данных..."
rm -rf /root/fractald-1.0.7-x86_64-linux-gnu
rm -f /root/.bitcoin/wallets/wallet/wallet.dat
rm -f /root/.bitcoin/wallets/wallet/MyPK.dat

# Очистка системных журналов
status_message "Очистка системных журналов..."
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s

status_message "Удаление ноды Fractal Bitcoin завершено!"

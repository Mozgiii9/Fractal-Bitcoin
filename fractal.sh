#!/bin/bash

# Путь для сохранения скрипта
SCRIPT_PATH="$HOME/Fractal Bitcoin.sh"

# Функция главного меню
function main_menu() {
    while true; do
        clear
        echo -e '\e[32m'
        echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ '
        echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
        echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
        echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
        echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
        echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
        echo -e '\e[0m'
        echo "Для выхода из скрипта нажмите Ctrl+C"
        echo "Выберите действие:"
        echo "1) Установить узел (версия 0.1.8)"
        echo "2) Просмотреть логи службы"
        echo "3) Создать кошелек"
        echo "4) Просмотреть приватный ключ"
        echo "5) Обновить скрипт (обновление с версии 0.1.7)"
        echo "6) Выход"
        echo -n "Введите опцию [1-6]: "
        read choice
        case $choice in
            1) install_node ;;
            2) view_logs ;;
            3) create_wallet ;;
            4) view_private_key ;;
            5) update_script ;;
            6) exit 0 ;;
            *) echo "Неверный выбор, попробуйте снова." ;;
        esac
    done
}

# Функция установки узла
function install_node() {
    echo "Начинаем обновление системы, обновляем пакеты и устанавливаем необходимые зависимости..."

    # Обновление списка пакетов
    sudo apt update

    # Обновление установленных пакетов
    sudo apt upgrade -y

    # Установка необходимых пакетов
    sudo apt install make gcc chrony curl build-essential pkg-config libssl-dev git wget jq -y

    echo "Система обновлена, пакеты обновлены и установлены."

    # Загрузка библиотеки fractald
    echo "Загрузка библиотеки fractald..."
    wget https://github.com/fractal-bitcoin/fractald-release/releases/download/v0.1.8/fractald-0.1.8-x86_64-linux-gnu.tar.gz

    # Извлечение библиотеки fractald
    echo "Извлечение библиотеки fractald..."
    tar -zxvf fractald-0.1.8-x86_64-linux-gnu.tar.gz

    # Переход в директорию fractald
    echo "Переход в директорию fractald..."
    cd fractald-0.1.8-x86_64-linux-gnu

    # Создание директории data
    echo "Создание директории data..."
    mkdir data

    # Копирование конфигурационного файла в директорию data
    echo "Копирование конфигурационного файла в директорию data..."
    cp ./bitcoin.conf ./data

    # Создание файла службы systemd
    echo "Создание файла службы systemd..."
    sudo tee /etc/systemd/system/fractald.service > /dev/null <<EOF
[Unit]
Description=Fractal Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/fractald-0.1.8-x86_64-linux-gnu
ExecStart=/root/fractald-0.1.8-x86_64-linux-gnu/bin/bitcoind -datadir=/root/fractald-0.1.8-x86_64-linux-gnu/data/ -maxtipage=504576000
Restart=always
RestartSec=3
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

    # Перезагрузка конфигурации менеджера systemd
    echo "Перезагрузка конфигурации менеджера systemd..."
    sudo systemctl daemon-reload

    # Запуск и установка службы на автозапуск
    echo "Запуск службы fractald и установка на автозапуск..."
    sudo systemctl start fractald
    sudo systemctl enable fractald

    echo "Установка узла завершена."
    
    # Ожидание нажатия клавиши для возврата в главное меню
    read -p "Нажмите любую клавишу для возврата в главное меню..."
}

# Функция просмотра логов службы
function view_logs() {
    echo "Просмотр логов службы fractald..."
    sudo journalctl -u fractald -fo cat
    
    # Ожидание нажатия клавиши для возврата в главное меню
    read -p "Нажмите любую клавишу для возврата в главное меню..."
}

# Функция создания кошелька
function create_wallet() {
    echo "Создание кошелька..."
    cd /root/fractald-0.1.8-x86_64-linux-gnu/bin && ./bitcoin-wallet -wallet=wallet -legacy create
    
    # Ожидание нажатия клавиши для возврата в главное меню
    read -p "Нажмите любую клавишу для возврата в главное меню..."
}

# Функция просмотра приватного ключа
function view_private_key() {
    echo "Просмотр приватного ключа..."
    
    # Переход в директорию fractald
    cd /root/fractald-0.1.8-x86_64-linux-gnu/bin
    
    # Использование bitcoin-wallet для экспорта приватного ключа
    ./bitcoin-wallet -wallet=/root/.bitcoin/wallets/wallet/wallet.dat -dumpfile=/root/.bitcoin/wallets/wallet/MyPK.dat dump
    
    # Анализ и вывод приватного ключа
    awk -F 'checksum,' '/checksum/ {print "Приватный ключ кошелька:" $2}' /root/.bitcoin/wallets/wallet/MyPK.dat
    
    # Ожидание нажатия клавиши для возврата в главное меню
    read -p "Нажмите любую клавишу для возврата в главное меню..."
}

# Функция обновления скрипта
function update_script() {
    echo "Начинаем обновление скрипта..."

    # Резервное копирование директории data
    echo "Резервное копирование директории data..."
    sudo cp -r /root/fractald-0.1.7-x86_64-linux-gnu/data /root/fractal-data-backup

    # Загрузка новой версии библиотеки fractald
    echo "Загрузка новой версии библиотеки fractald..."
    wget https://github.com/fractal-bitcoin/fractald-release/releases/download/v0.1.8/fractald-0.1.8-x86_64-linux-gnu.tar.gz

    # Извлечение новой версии библиотеки fractald
    echo "Извлечение новой версии библиотеки fractald..."
    tar -zxvf fractald-0.1.8-x86_64-linux-gnu.tar.gz

    # Переход в директорию новой версии fractald
    echo "Переход в директорию новой версии fractald..."
    cd fractald-0.1.8-x86_64-linux-gnu

    # Восстановление данных из резервной копии
    echo "Восстановление данных из резервной копии..."
    cp -r /root/fractal-data-backup /root/fractald-0.1.8-x86_64-linux-gnu/

    # Обновление файла службы systemd (если есть изменения)
    echo "Обновление файла службы systemd..."
    sudo tee /etc/systemd/system/fractald.service > /dev/null <<EOF
[Unit]
Description=Fractal Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/fractald-0.1.8-x86_64-linux-gnu
ExecStart=/root/fractald-0.1.8-x86_64-linux-gnu/bin/bitcoind -datadir=/root/fractald-0.1.8-x86_64-linux-gnu/data/ -maxtipage=504576000
Restart=always
RestartSec=3
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

    # Перезагрузка конфигурации менеджера systemd
    echo "Перезагрузка конфигурации менеджера systemd..."
    sudo systemctl daemon-reload

    # Запуск и установка службы на автозапуск
    echo "Запуск и включение службы fractald..."
    sudo systemctl enable fractald
    sudo systemctl start fractald

    echo "Обновление скрипта завершено."

    # Ожидание нажатия клавиши для возврата в главное меню
    read -p "Нажмите любую клавишу для возврата в главное меню..."
}

# Запуск главного меню
main_menu

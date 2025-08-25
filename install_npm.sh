#!/bin/bash
set -e

DOMAIN="yupiterpro.ru"
EMAIL="pshavlak@yandex.ru"

echo "=== Обновляем систему и ставим зависимости ==="
apt update && apt install -y curl docker.io docker-compose

echo "=== Создаём каталог для NPM ==="
mkdir -p /opt/npm
cd /opt/npm

echo "=== Скачиваем официальный docker-compose.yml ==="
curl -fsSL https://raw.githubusercontent.com/NginxProxyManager/nginx-proxy-manager/develop/docker/docker-compose.yml -o docker-compose.yml

echo "=== Настраиваем порты (80, 443, 81) ==="
sed -i "s|8080:80|80:80|g; s|4443:443|443:443|g; s|8181:81|81:81|g" docker-compose.yml

echo "=== Запускаем контейнеры ==="
docker-compose up -d

echo "=== Ждём запуск NPM (20 секунд) ==="
sleep 20

echo "=== Выпускаем SSL для $DOMAIN ==="
docker exec -i $(docker ps -qf name=nginx-app-1) \
  node ./build/index.js cert add \
  --domain "$DOMAIN" \
  --email "$EMAIL" \
  --provider letsencrypt \
  --letsencrypt-production

echo "=== Установка завершена! ==="
echo "Админ-панель: http://$DOMAIN:81"
echo "Логин: admin@example.com"
echo "Пароль: changeme"

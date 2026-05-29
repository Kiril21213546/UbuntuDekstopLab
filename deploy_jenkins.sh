#!/bin/bash
set -e

echo "КРОК 8. Створення volume для Jenkins..."
docker volume create jenkins_home || true

echo "Збірка кастомного образу Jenkins з Docker CLI..."
docker build -t custom-jenkins:lts -f Dockerfile.jenkins .

echo "КРОК 9. Запуск контейнера Jenkins..."
docker rm -f jenkins || true

docker run -d \
 --name jenkins \
 --user root \
 -p 8080:8080 -p 50000:50000 \
 -v jenkins_home:/var/jenkins_home \
 -v /var/run/docker.sock:/var/run/docker.sock \
 --restart unless-stopped \
 custom-jenkins:lts

echo "===================================================="
echo "Jenkins успішно запущено!"
echo "Відкрити Web UI: http://localhost:8080"
echo "Первинний пароль адміністратора з'явиться нижче:"
echo "===================================================="
sleep 10
docker logs jenkins | grep -A 5 "Jenkins initial setup is required" || docker logs jenkins | tail -n 20

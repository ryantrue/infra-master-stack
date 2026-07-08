# Настройка worker-ноды

Worker-нода нужна для будущего расширения инфраструктуры.

Она будет управляться с master-ноды через Portainer Agent.

## Что запускается на worker

- Portainer Agent

## Что не запускается на worker

- Traefik
- Portainer Server UI
- публичные HTTPS entrypoints

## Требования

Master должен иметь доступ к worker-ноде по порту:

    9001

Порт `9001` нельзя открывать в интернет. Только LAN/VPN/firewall.

## Автоматическая установка

На будущей worker-ноде:

    git clone https://github.com/ryantrue/infra-master-stack.git
    cd infra-master-stack
    scripts/install-worker.sh

Потом запустить:

    /srv/infra/scripts/deploy.sh

Скрипт `install-worker.sh` специально откажется запускаться на `infra-master`, если не передать `FORCE=1`.

## Ручная установка

Создать директории:

    sudo mkdir -p /srv/infra/{compose,scripts,secrets}

Скопировать файлы:

    cp compose/worker.compose.yml /srv/infra/compose/
    cp scripts/*.sh /srv/infra/scripts/
    cp .env.example /srv/infra/.env

В `/srv/infra/.env` указать:

    NODE_ROLE=worker

Запустить:

    /srv/infra/scripts/deploy.sh

## Подключение в Portainer

В Portainer на master:

    Environments
    Add environment
    Docker Standalone
    Agent

Адрес:

    worker-ip-or-dns:9001

Важно: без `http://` и без `https://`.

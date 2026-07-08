# infra-master-stack

Практичный Docker Compose стек для домашнего или малого Linux-сервера.

Сейчас стек рассчитан на Raspberry Pi / Debian, но без жёсткой привязки к Raspberry Pi. Основная идея простая: один мастер-сервер с Traefik и Portainer, а будущие worker-ноды подключаются как исполнители.

Без Kubernetes ради Kubernetes, без лишней магии, без хранения секретов в Git.

## Что внутри

- Traefik — reverse proxy и HTTPS entrypoint.
- Portainer CE — управление Docker-окружением.
- Portainer Agent — заготовка для будущих worker-нод.
- Скрипты для deploy/status/backup.
- Режимы нод: `master` и `worker`.

## Текущая схема

    master node:
      Traefik
      Portainer CE
      backups
      public HTTPS: 80/443

    worker node:
      Portainer Agent
      workloads
      internal/LAN access only

На текущем master-сервере worker-сервисы не запускаются.

## Структура

    compose/
      traefik.compose.yml
      portainer.compose.yml
      worker.compose.yml

    traefik/dynamic/
      middlewares.yml
      auth.example.yml

    scripts/
      backup.sh
      deploy.sh
      status.sh
      node-role.sh
      worker-join-info.sh
      install-worker.sh

    docs/
      node-roles.md
      worker-setup.md

    .env.example

## Что не хранится в Git

В репозиторий намеренно не попадают runtime-данные и секреты:

- `.env`
- `appdata/`
- `backups/`
- `secrets/`
- реальный `acme.json`
- реальный Traefik `auth.yml`
- база и ключи Portainer

## Роли нод

Роль задаётся в `/srv/infra/.env`:

    NODE_ROLE=master

Поддерживаемые роли:

    master
    worker

### master

Запускает:

- Traefik
- Portainer CE

Используется как публичная точка входа и центр управления.

### worker

Запускает:

- Portainer Agent

Worker-нода не должна публиковать Traefik/Portainer UI наружу.

## Быстрый старт master

Создать директории:

    sudo mkdir -p /srv/infra/{compose,scripts,secrets,appdata/traefik/dynamic,appdata/traefik/letsencrypt,appdata/portainer}

Скопировать файлы:

    cp compose/traefik.compose.yml /srv/infra/compose/
    cp compose/portainer.compose.yml /srv/infra/compose/
    cp scripts/*.sh /srv/infra/scripts/
    cp traefik/dynamic/middlewares.yml /srv/infra/appdata/traefik/dynamic/
    cp .env.example /srv/infra/.env

Создать реальный basic auth файл:

    cp traefik/dynamic/auth.example.yml /srv/infra/appdata/traefik/dynamic/auth.yml

Отредактировать:

    /srv/infra/.env
    /srv/infra/appdata/traefik/dynamic/auth.yml

Поставить роль:

    NODE_ROLE=master

Запустить:

    /srv/infra/scripts/deploy.sh

## Быстрый старт worker

На будущей worker-ноде:

    git clone https://github.com/ryantrue/infra-master-stack.git
    cd infra-master-stack
    scripts/install-worker.sh
    /srv/infra/scripts/deploy.sh

После этого в Portainer на master добавить Docker Standalone environment через Agent:

    worker-ip-or-dns:9001

Без `http://` и без `https://`.

Порт `9001` не должен торчать в интернет. Только LAN/VPN/firewall.

## Полезные команды

Статус:

    /srv/infra/scripts/status.sh

Деплой:

    /srv/infra/scripts/deploy.sh

Бэкап runtime-части:

    /srv/infra/scripts/backup.sh

Проверить роль:

    /srv/infra/scripts/node-role.sh

Информация по подключению worker:

    /srv/infra/scripts/worker-join-info.sh

## Безопасность

Минимальный набор правил:

- Не коммитить `.env`.
- Не коммитить `auth.yml`.
- Не коммитить `acme.json`.
- Не коммитить `appdata/portainer`.
- Не публиковать Portainer Agent `9001` в интернет.
- Доступ к Portainer и Traefik dashboard закрывать basic auth.
- Runtime backup хранить как приватный архив.

## Текущее назначение

Этот репозиторий — не универсальный фреймворк, а аккуратный шаблон для своей инфраструктуры:

- быстро восстановить master;
- подготовить worker;
- держать публичную конфигурацию отдельно от секретов;
- не держать весь сервер в голове.

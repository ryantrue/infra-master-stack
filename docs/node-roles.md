# Роли нод

Стек поддерживает две роли:

    master
    worker

Роль задаётся в `/srv/infra/.env`:

    NODE_ROLE=master

## master

Master-нода — это управляющий сервер и публичная точка входа.

Запускает:

- Traefik
- Portainer CE

Отвечает за:

- HTTPS entrypoint;
- reverse proxy;
- управление Docker через Portainer;
- runtime backups;
- будущую координацию worker-нод.

Ожидаемый путь:

    /srv/infra

Ожидаемое значение:

    NODE_ROLE=master

## worker

Worker-нода — будущая исполнительная нода.

Запускает:

- Portainer Agent

Не запускает:

- Traefik
- Portainer Server UI
- публичные HTTPS entrypoints

Ожидаемое значение:

    NODE_ROLE=worker

## Worker profile

Worker profile описан в:

    compose/worker.compose.yml

Он применяется только при:

    NODE_ROLE=worker

На текущем `infra-master` worker-сервисы запускаться не должны.

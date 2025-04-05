# .env を環境変数として参照する
set dotenv-load

# common ======================================================================

# コンテナを立ち上げる
up:
    docker compose up -d --remove-orphans

# コンテナを削除する
down:
    docker compose -f docker-compose.yml down
    docker compose -f docker-compose.dev.yml down

# コンテナのコンソールに入る
into container_name:
    docker compose exec {{container_name}} bash

# 開発用イメージをリビルド
rebuild-dev:
    docker compose -f docker-compose.dev.yml build --no-cache

# api =========================================================================


# app =========================================================================


# db ==========================================================================

migrate:
    docker run \
        --rm \
        --network codename-hoge_default \
        --volume $HOST_ROOT/db/migration:/flyway/sql \
        flyway/flyway:11 \
        -user=$DB_USER_NAME \
        -password=$DB_USER_PASS \
        -url=jdbc:postgresql://db:$DB_PORT/codename-hoge?currentSchema=plugin \
        migrate

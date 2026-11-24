# PHP-FPM 8.5 & Nginx on Alpine Linux

[![Build](https://github.com/mihailpolakov/php-nginx/actions/workflows/build.yaml/badge.svg)](https://github.com/mihailpolakov/php-nginx/actions/workflows/build.yaml)

Лёгкий базовый Docker-образ с **Nginx** и **PHP-FPM 8.5** на **Alpine Linux**, предназначенный для использования
в качестве основы (`FROM`) для PHP-приложений.

Основан на [TrafeX/docker-php-nginx](https://github.com/TrafeX/docker-php-nginx) (MIT).

- Alpine Linux 3.23, PHP 8.5, Nginx
- Процессы запускаются от непривилегированного пользователя `nobody`
- Логи Nginx и PHP-FPM пишутся в stdout/stderr
- Supervisord управляет nginx и php-fpm
- Встроенный `HEALTHCHECK` через `/fpm-ping`
- Мультиархитектурный: `linux/amd64`, `linux/arm64`

## Образ

```
ghcr.io/mihailpolakov/php-nginx
```

| Тег        | Что это                                              |
|------------|------------------------------------------------------|
| `latest`   | последний релиз (git-тег `v*.*.*`)                   |
| `8.5`      | последний релиз ветки PHP 8.5                        |
| `8.5.12`   | конкретный релиз                                     |
| `edge`     | последняя сборка ветки `main` (еженедельно пересобирается) |
| `sha-xxxx` | сборка конкретного коммита                           |

В продакшене рекомендуется закреплять конкретную версию (`8.5.12`) или `8.5`.

## Использование

### Как базовый образ

```Dockerfile
FROM ghcr.io/mihailpolakov/php-nginx:8.5

# Composer (при необходимости)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY --chown=nobody composer.json composer.lock /app/
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

COPY --chown=nobody . /app/
RUN composer dump-autoload --optimize
```

Корень сайта — `/app/public`, приложение лежит в `/app`.

### Запуск

```bash
docker run -p 8080:8080 ghcr.io/mihailpolakov/php-nginx:8.5
```

Откройте http://localhost:8080 — по умолчанию отдаётся `phpinfo()`. В своём образе замените `/app/public` содержимым приложения.

### Docker Compose

```yaml
services:
  app:
    image: ghcr.io/mihailpolakov/php-nginx:8.5
    ports:
      - "8080:8080"
    volumes:
      - ./:/app
```

## Настройка

Конфигурацию можно переопределить, скопировав свои файлы поверх стандартных:

| Файл в образе                       | Что настраивает            |
|-------------------------------------|----------------------------|
| `/etc/nginx/nginx.conf`             | общая конфигурация Nginx   |
| `/etc/nginx/conf.d/default.conf`    | server-блок                |
| `/etc/php85/php-fpm.d/www.conf`     | пул PHP-FPM                |
| `/etc/php85/conf.d/custom.ini`      | настройки PHP              |
| `/etc/supervisor/conf.d/*.conf`     | дополнительные процессы    |

Пример:

```Dockerfile
FROM ghcr.io/mihailpolakov/php-nginx:8.5
COPY config/nginx-server.conf /etc/nginx/conf.d/default.conf
COPY config/php.ini /etc/php85/conf.d/zz-app.ini
```

### Дополнительные расширения PHP

```Dockerfile
FROM ghcr.io/mihailpolakov/php-nginx:8.5
USER root
RUN apk add --no-cache php85-bcmath php85-pgsql php85-pdo_pgsql
USER nobody
```

### Установленные расширения

ctype, curl, dom, fileinfo, gd, iconv, intl, mbstring, mysqli, openssl, pdo, pdo_mysql, phar, redis,
session, simplexml, sodium, tokenizer, xml, xmlreader, xmlwriter, xsl, zip.

## Разработка

```bash
docker build -t php-nginx:test .
./run_tests.sh php-nginx:test
```

## Выпуск релиза

Публикация в GitHub Container Registry выполняется автоматически через GitHub Actions
([.github/workflows/build.yaml](.github/workflows/build.yaml)):

```bash
git tag v8.5.12
git push origin v8.5.12
```

После первой публикации откройте **Packages → php-nginx → Package settings** и сделайте пакет публичным
(**Change visibility → Public**), чтобы его можно было скачивать без авторизации.

## Лицензия

[MIT](LICENSE)

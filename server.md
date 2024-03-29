---
layout: default
permalink: /server
---

# Сервер
{:.no_toc}

* TOC
{:toc}


## [](#parameters)Системные параметры

Изменить системные параметры сервера можно в файле `server.json`, расположенном в папке `%ProgramData%\Telecontrol\SCADA Server`:

```
// Файл параметров Telecontrol SCADA Server.
// Допустимые переменные:
//   DIR_APP_DATA        - Папка Application Data в профиле пользователя.
//   DIR_LOCAL_APP_DATA  - Папка "Local Settings\Application Data" в профиле пользователя.
//   DIR_COMMON_APP_DATA - W2K, XP, W2K3: "C:\Documents and Settings\All Users\Application Data".
//                         Vista, W2K8 и выше: "C:\ProgramData".
//   DIR_EXE             - Папка, содержащая исполняемый файл сервера.
//   DIR_CURRENT         - Рабочая папка.
//   DIR_TEMP            - Временная папка.
//   DIR_PARAM           - Папка этого файла.

{
    // Конфигурационная база данных.
    "configuration": {
        // Драйвер конфигурационной базы данных: "SQLite" или "PostgreSQL".
        "driver": "SQLite",

        // Папка конфигурационной базы данных.
        // Если значение не задано или пустое, используется "${DIR_EXE}".
        "dir": "${DIR_PARAM}/Configuration"
    },

    // Архивы.
    "history": {
        // Архивная папка, содержащая все конфигурационные базы данных.
        // Если значение не задано или пустое, используется "${DIR_EXE}/historical-db".
        "dir": "${DIR_PARAM}/History"
    },

    // Клиентские сессии.
    "sessions": [
        // Локальный хост и порт для приема клиентских подключений через TCP/IP. "0.0.0.0" для приема
        // на всех локальных сетевых интерфейсах.
        "tcp;passive;host=0.0.0.0;port=2000",
    ],

    // Классический OPC.
    "opc": {
        // Клиент OPC.
        "client": {
            // Разрешить подключения к OPC-тегам и отображать структуру OPC в дереве узлов.
            "enabled": false
        }
    },

    // Сервер OPC UA.
    "opcua": {
        // Разрешить подключения OPC UA.
        "enabled": false,

        // Адрес сервера OPC UA.
        "url": "opc.tcp://localhost:4840",

        // Закрытый ключ OPC UA.
        "server_private_key": "${DIR_PARAM}/Certificates/ServerPrivateKey.pem",

        // Сертификат OPC UA.
        "server_certificate": "${DIR_PARAM}/Certificates/ServerCertificate.pem",

        // Диагностика: "error", "warning", "system", "info", "debug", "content", "all", "none".
        "trace": "none"
    },

    // Статические данные.
    "filesystem": {
      // Разрешить статические данные.
      "enabled": true,

      // Папка статических данных.
      "dir": "${DIR_PARAM}/FileSystem",
    },

    // Интеграция с ОИК Видикон.
    "vidicon": {
      "enabled": false,
    },

    // Логи.
    "log": {
        // Папка логов.
        // Если значение не задано или пустое, используется "${DIR_EXE}/logs".
        "dir": "${DIR_PARAM}/Logs",

        // Максимальный размер файла в мегабайтах для создания нового файла.
        "max_file_size": 10,

        // Максимальный размер всех файлов в мегабайтах для удаления устаревших файлов.
        "max_total_size": 100,

        // Максимальное количество файлов.
        "max_count": 1000,
    }
}
```


## [](#console) Запуск в режиме консоли

Сервер может быть запущен в консольном режиме. Для этого следует остановить службу *Telecontrol SCADA Server*, и использовать пиктограмму *Сервер (консоль)* на рабочем столе, либо через меню *Пуск - ОИК Телеконтроль*.

Внимание: при отсутствии у текущего пользователя Windows административных прав работа Сервера может быть нарушена.

## Конфигурационная БД

Для хранения конфигурации используется отдельная БД, расположенная в папке `%ProgramData%\Telecontrol\SCADA Server\Configuration`. Это расположение можно изменить через параметр `configuration/dir` в файле `server.json`.

Поддерживаются БД в формате [SQLite](https://www.sqlite.org/index.html).

### [](#migration)Миграция конфигурационной БД GigaBASE

Поддержка GigaBASE была удалена начиная с версии 2.1. Для импорта старых конфигураций GigaBASE используйте утилиту администрации версии 2.0.

Для загрузки архива нажмите [эту ссылку](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-admin-2.0.60.1997.zip). Распакуйте архив ZIP и запустите из распакованной директории:

```batch
admin export --source-driver=GigaBASE "--source=c:\ProgramData\Telecontrol\SCADA Server\Configuration" --target-driver=SQLite "--target=c:\ProgramData\Telecontrol\SCADA Server\Configuration"
```

Эта команда создаст файл конфигурации SQLite `configuration.sqlite3` в директории `c:\ProgramData\Telecontrol\SCADA Server\Configuration`. Все содержимое старой конфигурации будет импортировано в новую конфигурацию.

Для использования новой конфигурации нужно обновить параметры сервера. Откройте файл `server.json` находящийся в папке `c:\ProgramData\Telecontrol\SCADA Server` и измените параметр `configuration.driver` с `GigaBASE` на `SQLite`. Если такой параметр отсутствует, его нужно добавить.

`server.json`:
```
    // Конфигурационная база данных.
    "configuration": {
        // Драйвер конфигурационной базы данных: "SQLite" или "PostgreSQL".
        "driver": "SQLite",

        // Папка конфигурационной базы данных.
        // Если значение не задано или пустое, используется "${DIR_EXE}".
        "dir": "${DIR_PARAM}/Configuration"
    },
```

## [](#history)Исторические БД

Исторические БД создаются в формате [SQLite](https://www.sqlite.org/index.html).

Для хранения событий аудита и последних значений объектов используется системная историческая БД.

Для хранения событий и изменений значений параметров используются пользовательские исторические БД. Допустимо создание нескольких пользовательских исторических БД. Сервер автоматически создает и удаляет необходимые файлы на диске про создании и удалении БД.

Местоположение БД определяется системным параметром `history-path`. По умолчанию используется папка `%ProgramData%\Telecontrol\SCADA Server\History`:

```
    // Архивы.
    "history": {
        // Архивная папка, содержащая все конфигурационные базы данных.
        // Если значение не задано или пустое, используется "${DIR_EXE}/historical-db".
        "dir": "${DIR_PARAM}/History"
    },
```

Для каждой БД создается собственная подпапка с уникальным идентификатором. Исключением является фиксированное имя `System` системной БД. Каждому объекту может быть назначена одна БД. При удалении объекта, вся связанные с ним данные удаляются из БД. При переназначении БД объекту, связанные с ним данные удаляются из предыдущей БД.

Историческим БД задается глубина хранения данных. Сервер автоматически выполяет очистку БД в соответствии с ее глубиной.


### Оценка требуемого дискового пространства

Максимальный допустимый размер БД составляет 1 Тб. Допустимые ограничения смотрите в подробных [характеристиках SQLite](http://sqlite.org/limits.html). Размер страницы БД, создаваемой Сервером, составляет 1 Кб. Максимальное число страниц равно 1073741823.

Размер записи одного [Объекта](architecture#data-items) составляет менее 100 Байт.

Таким образом, ожидаемый размер БД в Мб можно вычислить как:
`size = freq * depth / 10000`, где:
- `size` - ожидаемый размер БД в Мб;
- `freq` - частота изменений в день;
- `depth` - глубина (в днях).

Либо, при известном объеме доступного дискового пространства, можно вычислить максимальную глубину в днях:
`depth = size * 10000 / freq`.

### Работа с БД SQLite

Данный пункт описывает дополнительные возможности администрирования и диагностики. Так как сервер выполняет обслуживание БД в автоматическом режиме, ознакомление с данным пунктом не требуется.

Удобный графический интерфейс предоставляет бесплатная утилита [SQLiteStudio](https://sqlitestudio.pl/).

Для прямого доступа к БД можно использовать утилиту командной строки SQLite, устанавливаемую вместе с Сервером. Для вызова командной строки SQLite перейдите в папку БД и выполните команду

```batch
"%ProgramFiles(x86)%\Telecontrol SCADA\bin\sqlite3.exe" history
```

Утилита позволяет выполнять запросы SQL и ряд специальных команд. Для информации о списке допустимых команд смотрите [документацию SQLite](https://sqlite.org/cli.html).

#### Примеры

Размер страницы БД:

```SQL
sqlite> pragma page_size;
1024
```

Перечень таблиц:

```SQL
sqlite> .tables
events      timed_data
```

Схема таблицы системных событий:

```SQL
sqlite> .schema events
CREATE TABLE events(time INTEGER, change_mask INTEGER, severity INTEGER,
item_id INTEGER, user_id INTEGER, value FLOAT, qualifier INTEGER,
message TEXT, ack_id INTEGER, ack_time INTEGER, ack_user_id INTEGER);
CREATE UNIQUE INDEX events_ack_index ON events(ack_id);
CREATE INDEX events_time_index ON events(time);
```

Количество системных событий в архиве:

```SQL
sqlite> select count(*) from events;
86
```

## [](#filesystem)Серверная файловая система

Серверная файловая система позволяет хранить файлы мнемосхем на Сервере. Таким образом, доступ к мнемосхемам будет предоставлен всем Клиентам, избавляя их он необходимости ручной синхронизации при обновлении файлов.

Серверная файловая система включается автоматически при новой установке ОИК. Для включения на существующих установках потребуется установить параметр `filesystem.enabled` в значение `true` в файле `%ProgramData%\Telecontrol\SCADA Server\server.json`:

```
   // Статические данные.
    "filesystem": {
      // Разрешить статические данные.
      "enabled": true,

      // Папка статических данных.
      "dir": "${DIR_PARAM}/FileSystem",
    },

```

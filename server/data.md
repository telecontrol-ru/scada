---
title: Базы данных и файлы
nav_order: 6
parent: Сервер
permalink: /server/data/
---

# Базы данных и файлы
{:.no_toc}

* TOC
{:toc}

## Конфигурационная БД

Для хранения конфигурации используется база данных в папке, заданной параметром `configuration.dir` файла параметров процесса. Удобно указывать `${DIR_PARAM}/Configuration` — папку рядом с файлом параметров, как в примере ниже. Если параметр не задан, БД создается в папке исполняемого файла.

### SQLite

По умолчанию используется встроенная БД [SQLite](https://www.sqlite.org/index.html), не требующая установки дополнительного ПО:

```json
"configuration": {
    "driver": "SQLite",
    "dir": "${DIR_PARAM}/Configuration"
}
```

### PostgreSQL

Для распределенных установок и повышенных требований к надежности поддерживается [PostgreSQL](https://www.postgresql.org/):

```json
"configuration": {
    "driver": "PostgreSQL",
    "connection-string": "postgresql://user:password@localhost:5432/scada"
}
```

При использовании PostgreSQL требуется предварительно установить и настроить сервер PostgreSQL.

### Миграция конфигурационной БД GigaBASE {#migration}

Поддержка GigaBASE была удалена начиная с версии 2.1, а `scada-setup migrate`
переносит только конфигурацию SQLite. Если конфигурация объекта еще хранится в
GigaBASE, сначала переведите ее в SQLite и запустите на ней Сервер версии 2.5,
и только затем выполняйте `scada-setup migrate` (смотрите
[Переход с версии 2.5]({{ '/server/upgrade/' | relative_url }}#upgrade-2-5)). Для перевода нужна утилита
администрации версии 2.0; она не публикуется на странице выпусков —
обратитесь за ней в ООО «Телеконтроль» (mail@telecontrol.ru).

## Исторические БД {#history}

Исторические БД создаются в формате [SQLite](https://www.sqlite.org/index.html).

Для хранения событий аудита и последних значений объектов используется системная историческая БД.

Для хранения событий и изменений значений параметров используются пользовательские исторические БД. Допустимо создание нескольких пользовательских исторических БД. Сервер автоматически создает и удаляет необходимые файлы на диске при создании и удалении БД.

Исторические БД ведет процесс `scada-historian`. Местоположение БД определяется параметром `history.dir` его файла параметров; `scada-setup` задает папку `%ProgramData%\Telecontrol\SCADA Server\historian\History`. (Сервер версии 2.5 хранил их в `%ProgramData%\Telecontrol\SCADA Server\History`; при [переходе с версии 2.5]({{ '/server/upgrade/' | relative_url }}#upgrade-2-5) они копируются в новую папку.)

Для каждой БД создается собственная подпапка с числовым идентификатором БД. Исключением является фиксированное имя `System` системной БД. Каждому объекту может быть назначена одна БД. При удалении объекта все связанные с ним данные удаляются из БД. При переназначении БД объекту связанные с ним данные удаляются из предыдущей БД.

Историческим БД задается глубина хранения данных. Сервер автоматически выполняет очистку БД в соответствии с ее глубиной.

### Оценка требуемого дискового пространства

Новые БД создаются со стандартным для SQLite размером страницы 4 Кб; БД, перенесенные из прежних версий, сохраняют свой. Допустимые размеры смотрите в [характеристиках SQLite](https://sqlite.org/limits.html).

Размер записи одного [Объекта]({{ '/architecture/' | relative_url }}#data-items) составляет менее 100 Байт.

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

Для прямого доступа к БД можно использовать утилиту командной строки `sqlite3`. В установку версии 2.6 она не входит (версии 2.5 и ранее ее устанавливали); загрузите ее со [страницы загрузок SQLite](https://sqlite.org/download.html). Файл БД называется `history` и лежит в папке БД. Перейдите в эту папку и выполните команду

```batch
sqlite3 history
```

Открывайте для записи только БД остановленного процесса (`scada-setup stop`).

Утилита позволяет выполнять запросы SQL и ряд специальных команд. Для информации о списке допустимых команд смотрите [документацию SQLite](https://sqlite.org/cli.html).

#### Примеры

Размер страницы БД:

```SQL
sqlite> pragma page_size;
4096
```

Перечень таблиц: значения параметров (`timed_data`), последние значения
объектов (`items_info`) и по таблице на каждый тип событий:

```SQL
sqlite> .tables
AuditActivateSessionEventType  OperatorActionAuditEventType
AuditUpdateMethodEventType     SystemEventType
DeviceWatchEventType           items_info
ItemAlarmEventType             timed_data
```

В БД, перенесенной из прежних версий, может быть также таблица
`events_v1_backup` — это исходная таблица событий старого формата, данные
которой уже перенесены в `SystemEventType`.

Схема таблицы системных событий:

```SQL
sqlite> .schema SystemEventType
CREATE TABLE SystemEventType(EventID INTEGER PRIMARY KEY NOT NULL, Time INTEGER NOT NULL, ReceiveTime INTEGER NOT NULL, ChangeMask INTEGER, Severity INTEGER, NodeNS INTEGER NOT NULL, NodeID INTEGER NOT NULL, UserID INTEGER, Value FLOAT, Qualifier INTEGER, Message TEXT, Acked BOOLEAN NOT NULL, AckTime INTEGER, AckUserID INTEGER, SourceName TEXT, MessageLocale TEXT, SourceNameLocale TEXT);
CREATE INDEX SystemEventType_TimeIndex ON SystemEventType(Time);
CREATE INDEX SystemEventType_NodeIndex ON SystemEventType(NodeNS, NodeID);
```

Количество системных событий в архиве:

```SQL
sqlite> select count(*) from SystemEventType;
86
```

## Серверная файловая система {#filesystem}

Серверная файловая система позволяет хранить файлы мнемосхем на Сервере. Таким образом, доступ к мнемосхемам будет предоставлен всем Клиентам, избавляя их от необходимости ручной синхронизации при обновлении файлов.

Серверную файловую систему ведет процесс `scada-filesystem`. В файле параметров, который создает `scada-setup`, она уже включена. При ручной настройке включите ее параметром `filesystem.enabled` в файле `server.json` процесса:

```json
"filesystem": {
    "enabled": true,
    "dir": "${DIR_PARAM}/FileSystem"
}
```

Файлы мнемосхем размещаются в папке, указанной в параметре `dir`; `scada-setup` задает папку `%ProgramData%\Telecontrol\SCADA Server\filestore\FileSystem`. (Сервер версии 2.5 хранил их в `%ProgramData%\Telecontrol\SCADA Server\FileSystem`; при [переходе с версии 2.5]({{ '/server/upgrade/' | relative_url }}#upgrade-2-5) они копируются в новую папку.) Управление файлами выполняется из [панели файлов]({{ '/client/' | relative_url }}) Клиента.

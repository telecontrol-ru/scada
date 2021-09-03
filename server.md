---
layout: default
permalink: /server
---

# Сервер
{:.no_toc}

* TOC
{:toc}


## [](#parameters) Системные параметры

Изменить системные параметры сервера можно в файле `server.json`, расположенном в папке `%ProgramData%\Telecontrol\SCADA Server`.

## [](#console) Запуск в режиме консоли

Сервер может быть запущен в консольном режиме. Для этого следует остановить службу *Telecontrol SCADA Server*, и использовать пиктограмму *Сервер (консоль)* на рабочем столе, либо из меню *Пуск - ОИК Телеконтроль*.

Внимание: при отсутствии у текущего пользователя Windows административных прав работа Сервера может быть нарушена.

## Конфигурационная БД

Для хранения конфигурации используется отдельная БД, расположенная в папке `%ProgramData%\Telecontrol\SCADA Server\Configuration`. Это расположение можно изменить через параметр `configuration/dir` в файле `server.json`.

Поддерживаются БД в формате [SQLite](https://www.sqlite.org/index.html).

### [](#migration)Миграция конфигурационной БД

Для изменения формата конфигурационной БД используйте утилиту администрирования `admin.exe`, находящуюся в папке `%ProgramFiles(x86)%\Telecontrol SCADA\bin`.

```batch
"%ProgramFiles(x86)%\Telecontrol SCADA\bin\admin.exe" export ^
  --source-driver=source-driver ^
  --source="source-configuration-dir" ^
  --source-driver=source-driver ^
  --target="target-configuration-dir"
```

Обозначения:
- `source-driver` - тип исходной базы данных;
- `source-configuration-dir` - папка исходной базы GigaBASE;
- `target-driver` - тип новой базы данных;
- `target-configuration-dir` - папка новой конфигурации SQLite.

Пример миграции БД GigaBASE в SQLite:

```batch
cd "%ProgramData%\Telecontrol\SCADA Server"
"%ProgramFiles(x86)%\Telecontrol SCADA\bin\admin.exe" export ^
  --source-driver=GigaBASE ^
  --source="configuration" ^
  --target-driver=SQLite ^
  --target="configuration-sqlite"
rename configuration configuration-gigabase
rename configuration-sqlite configuration
```

После обновления БД в файле `server.json` измените параметр `configuration/driver` на `SQLite`.

## [](#history)Исторические БД

Исторические БД создаются в формате [SQLite](https://www.sqlite.org/index.html).

Для хранения событий аудита и последних значений объектов используется системная историческая БД.

Для хранения событий и изменений значений параметров используются пользовательские исторические БД. Допустимо создание нескольких пользовательских исторических БД. Сервер автоматически создает и удаляет необходимые файлы на диске про создании и удалении БД.

Местоположение БД определяется системным параметром `history-path`. По умолчанию используется папка `%ProgramData%\Telecontrol\SCADA Server\History`. Для каждой БД создается собственная подпапка с уникальным идентификатором. Исключением является фиксированное имя `System` системной БД.

Каждому объекту может быть назначена одна БД. При удалении объекта, вся связанные с ним данные удаляются из БД. При переназначении БД объекту, связанные с ним данные удаляются из предыдущей БД.

Историческим БД задается глубина хранения данных. Сервер автоматически выполяет очистку БД в соответствии с ее глубиной.

## [](#filesystem)Серверная файловая система

Серверная файловая система позволяет хранить файлы мнемосхем на сервере. Таким образом, доступ к мнемосхемам будет предоставлен всем пользователям, избавляя их он необходимости ручной синхронизации при обновлении файлов.

Серверная файловая система включается автоматически при новой установке ОИК. Для включения на существующих установках потребуется установить параметр `filesystem.enabled` в значение `true` в файле `%ProgramData%\Telecontrol\SCADA Server\Configuration\server.json`.


### Оценка требуемого дискового пространства

Максимальный допустимый размер БД составляет 1 Тб. Для подробностей смотрите [характеристики SQLite](http://sqlite.org/limits.html). Размер страницы БД, создаваемой Сервером, составляет 1 Кб. Максимальное число страниц равно 1073741823.

Размер одной записи измерения составляет менее 100 Б.

Таким образом, ожидаемый размер БД в Мб можно вычислить как:
`size = freq * depth / 10000`, где:
- `size` - ожидаемый размер БД в Мб;
- `freq` - частота изменений в день;
- `depth` - глубина (в днях).

Либо, при известном объеме доступного дискового пространства, можно вычислить максимальную глубину в днях:
`depth = size * 10000 / freq`.

### Работа с БД SQLite

Данный пункт описывает дополнительные возможности администрирования и диагностики. Так как сервер выполняет обслуживание БД в автоматическом режиме, ознакомление с данным пунктом не требуется.

Удобный графический интерфейс предоставляет бесплатная утилита [SQLiteStudio](https://sqlitestudio.pl/index.rvt).

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

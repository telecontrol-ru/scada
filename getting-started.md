## Начало работы

ОИК не требует специальной процедуры развертывания. Для работы 
системы необходимо скопировать файл server.exe из архива 
scada.zip в отдельную папку на серверном компьютере. При первом 
запуске сервера в его папке будет создана первичная база данных. 
Если включен Брандмауэр Windows или какая либо другая программа, 
ограничивающая доступ, необходимо разрешить входящие соединения 
TCP/IP на порт 2000[Заметка в подвал:
Описание настройки брандмауэра смотрите в приложении.
].

Скопировать файл сlient.exe в отдельную папку на клиентском 
компьютере и запустить. Схемы Modus (.sde) следует поместить в 
находящуюся на том же уровне папку public.

# Лицензирование

Сервер требует аппаратный ключ HASP или GUARDANT для своей 
работы. Без ключа работа сервера останавливается через 2 часа 
после запуска.

# Настройка Брандмауэра Windows

[плавающий объект Рисунок:
<Изображение: C:/Work/scada/stable/docs/scada/firewall.eps>

[Рисунок 1.3.1:
Выключенный Брандмауэр Windows
]
]
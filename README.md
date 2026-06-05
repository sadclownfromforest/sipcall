sipcall
=====

An OTP application

Build
-----

    $ rebar3 compile

Dockerfile взят из примера.
После звонка из Twinkle c User name например 3001, uri сохранится в ets
Для обратного звонка на клиент Twinkle из командной строки возможно написать: curl http://localhost:8080/api/call/3001

Пример URI: sip:3001@127.0.0.1:5065


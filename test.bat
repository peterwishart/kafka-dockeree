@echo off
set appname=kafka_dockeree

echo *** Stop existing containers ***
for /f "tokens=1" %%i in ('docker ps --filter "name=%appname%*"') do docker stop %%i
for /f "tokens=1" %%i in ('docker ps -a --filter "name=%appname%*"') do docker rm %%i

if [%1]==[kill] goto :skiprun

echo *** Rebuild containers - first run takes a long time ***
docker build -t %appname%_server .
docker run -d -p 9000:9000 -p 9092:9092 --name %appname%_server --hostname %appname%_server %appname%_server

echo ***
echo kafka running %appname%_server:9092
echo kafka manager http interface on %appname%_server:9000
echo run [%0 kill] to shut down services
echo ***

:skiprun



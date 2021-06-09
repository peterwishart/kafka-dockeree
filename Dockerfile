arg win_tag=1809
FROM mcr.microsoft.com/windows/servercore:$win_tag

#copy set path powershell script 
COPY Set-PathVariable.ps1 / 

#get 7zip
RUN powershell (new-object System.Net.WebClient).Downloadfile('http://www.7-zip.org/a/7z1701-x64.exe', '\7z1701-x64.exe')
RUN powershell start-process -filepath \7z1701-x64.exe -passthru -wait -argumentlist "/S"
ENV 7z_HOME="c:\\program files\\7-zip"
RUN powershell -executionpolicy bypass /Set-PathVariable.ps1 -NewLocation '%7Z_HOME%'
RUN del \7z1701-x64.exe

#get jdk - had to guess the magic bundle number. download process requires cookies for higher java versions but 8.91 will do
RUN powershell (new-object System.Net.WebClient).Downloadfile('http://javadl.oracle.com/webapps/download/AutoDL?BundleId=210180', '\jdk-8u91-windows-x64.exe')
ARG java_install_dir=c:\\Java\\jdk1.8.0_91
ENV JAVA_HOME=$java_install_dir
RUN powershell -executionpolicy bypass /Set-PathVariable.ps1 -NewLocation '%JAVA_HOME%/bin'
RUN powershell start-process -filepath \jdk-8u91-windows-x64.exe -passthru -wait -argumentlist "/s,INSTALLDIR=c:\Java\jdk1.8.0_91,/L,install64.log"
RUN del \jdk-8u91-windows-x64.exe

#get kafka manager
ENV KM_VERSION=1.3.3.15
RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; (new-object System.Net.WebClient).Downloadfile('http://github.com/yahoo/kafka-manager/archive/1.3.3.15.tar.gz', '\kafka-manager-1.3.3.15.tgz');

RUN 7z.exe e kafka-manager-%KM_VERSION%.tgz
RUN 7z.exe x kafka-manager-%KM_VERSION%.tar
RUN REN "c:\CMAK-%KM_VERSION%" kafka-manager
ENV KM_HOME="c:\\kafka-manager"
RUN DEL kafka-manager-%KM_VERSION%.tgz
RUN DEL kafka-manager-%KM_VERSION%.tar
#

#get sbt
ENV SBT_HOME=c:\\sbt
RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; (new-object System.Net.WebClient).Downloadfile('http://github.com/sbt/sbt/releases/download/v1.0.4/sbt-1.0.4.tgz', '\sbt-1.0.4.tgz');
RUN 7z.exe e sbt-1.0.4.tgz
RUN 7z.exe x sbt.tar
#
RUN DEL sbt-1.0.4.tgz
RUN DEL sbt.tar
RUN powershell -executionpolicy bypass /Set-PathVariable.ps1 -NewLocation '%SBT_HOME%/bin'

#package is built to C:\kafka-manager\target\universal\kafka-manager-1.3.3.15.zip
RUN PUSHD %KM_HOME% & sbt clean dist & POPD
RUN COPY %KM_HOME%\target\universal\kafka-manager-%KM_VERSION%.zip "\kafka-manager.zip" 

## Runtime layer ##
FROM mcr.microsoft.com/windows/servercore:$win_tag

#copy set path powershell script
COPY Set-PathVariable.ps1 / 

#get 7zip
RUN powershell (new-object System.Net.WebClient).Downloadfile('http://www.7-zip.org/a/7z1701-x64.exe', '\7z1701-x64.exe')
RUN powershell start-process -filepath \7z1701-x64.exe -passthru -wait -argumentlist "/S"
ENV 7z_HOME="c:\\program files\\7-zip"
RUN powershell -executionpolicy bypass /Set-PathVariable.ps1 -NewLocation '%7Z_HOME%'
RUN del \7z1701-x64.exe

#get jre
RUN powershell (new-object System.Net.WebClient).Downloadfile('http://javadl.oracle.com/webapps/download/AutoDL?BundleId=210185', '\jre-8u91-windows-x64.exe')
ARG java_install_dir=c:\\Java\\jre1.8.0_91
ENV JAVA_HOME=$java_install_dir
RUN powershell -executionpolicy bypass /Set-PathVariable.ps1 -NewLocation '%JAVA_HOME%/bin'
RUN powershell start-process -filepath \jre-8u91-windows-x64.exe -passthru -wait -argumentlist "/s,INSTALLDIR=c:\Java\jre1.8.0_91,/L,install64.log"
RUN del \jre-8u91-windows-x64.exe

#get zookeeper and kafka

ENV ZK_VERSION=3.6.3
ENV ZOOKEEPER_HOME=c:\\zookeeper
RUN powershell (new-object System.Net.WebClient).Downloadfile('http://mirrors.ukfast.co.uk/sites/ftp.apache.org/zookeeper/stable/apache-zookeeper-%ZK_VERSION%-bin.tar.gz', '\zookeeper-%ZK_VERSION%.tar.gz')
RUN 7z.exe e zookeeper-%ZK_VERSION%.tar.gz 
RUN 7z.exe x zookeeper-%ZK_VERSION%.tar -y
RUN DEL \zookeeper-%ZK_VERSION%.tar.gz 
RUN DEL \zookeeper-%ZK_VERSION%.tar
RUN REN \apache-zookeeper-%ZK_VERSION%-bin zookeeper
RUN powershell -executionpolicy bypass /Set-PathVariable.ps1 -NewLocation '%ZOOKEEPER_HOME%/bin'

#kafka releases are stored under a folder for the SBT version
#e.g. http://mirrors.ukfast.co.uk/sites/ftp.apache.org/kafka/1.1.1/kafka_2.12-1.1.1.tgz

ENV K_SBT_VER=2.6.2
ENV K_VER=2.12
ENV K_NAME=kafka_${K_VER}-${K_SBT_VER}
ENV KAFKA_HOME=c:\\kafka

RUN powershell (new-object System.Net.WebClient).Downloadfile('http://mirrors.ukfast.co.uk/sites/ftp.apache.org/kafka/%K_SBT_VER%/%K_NAME%.tgz', '\%K_NAME%.tgz')

RUN 7z.exe e %K_NAME%.tgz
RUN 7z.exe x %K_NAME%.tar 
RUN REN %K_NAME% kafka
RUN DEL \%K_NAME%.tgz
RUN DEL \%K_NAME%.tar

#copy built kafka-manager from stage 0
ENV KM_VERSION=1.3.3.15
COPY --from=0 /kafka-manager.zip /
RUN 7z.exe x kafka-manager.zip
RUN DEL kafka-manager.zip
RUN REN c:\kafka-manager-%KM_VERSION% kafka-manager
ENV KAFKA_MANAGER_HOME=c:\\kafka-manager
RUN powershell -executionpolicy bypass /Set-PathVariable.ps1 -NewLocation '%KAFKA_MANAGER_HOME%/bin'

#todo replace kafka home dir in server.properties
#todo replace zk data folder in zoo.cfg
#configure and run services
COPY conf/zookeeper/zoo.cfg c:/zookeeper/conf/

COPY conf/kafka/server.properties ${KAFKA_HOME}/config/
RUN powershell "((Get-Content -path %KAFKA_HOME%/config/server.properties -Raw) -replace '--k_name--','%K_NAME%') | Set-Content -Path %KAFKA_HOME%/config/server.properties"

COPY conf/kafka-manager/application.conf c:/kafka-manager/conf
COPY bootstrap.ps1 /

EXPOSE 9000
EXPOSE 9092

ENTRYPOINT [ "powershell", \
"-executionpolicy" , \
"bypass", \
 "/bootstrap.ps1" ]

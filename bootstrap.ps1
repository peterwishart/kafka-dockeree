Write-Output "bootstrapping java/zookeeper/kafka"

Write-Output "starting zookeeper"
Start-Process -NoNewWindow -Filepath "$env:zookeeper_home/bin/zkserver.cmd"
Write-Output "starting kafka manager"
Start-Process -FilePath "$env:kafka_manager_home/bin/kafka-manager"
Write-Output "starting kafka"
Start-Process -Filepath "$env:kafka_home/bin/windows\kafka-server-start.bat" -ArgumentList "$env:kafka_home/config/server.properties" -NoNewWindow -Wait


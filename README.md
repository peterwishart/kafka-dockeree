# Introduction 
This is a development-only container of kafka based on instructions here: https://dzone.com/articles/running-apache-kafka-on-windows-os.

It includes zookeeper, a single kafka instance plus kafka manager web interface. All storage is ephemeral (but you could change that if needed).

Its mainly tested on Windows Docker EE but works on CE too.

# Getting Started
On Windows Server, follow standard instructions for setting up Docker EE.

E.g. instructions for setting up windows docker here: https://docs.docker.com/install/windows/docker-ee/

On Windows 10, install Docker CE.

On CE I've previously had error "The operation timed out because a response was not received from the Virtual Machine Container. (0xc0370109)" during container build - just retrying the build fixed it.

# Build and Test

Build and run the container via test.bat. It takes a *very* long time on first run, due to pulling and building scala for the kafka manager webUI.

Once running, run `docker ps`.
Note the first 3 digits of the container id and plug into these commands to test the container is working internally

<pre>
  set container_id=105
  set khome=/kafka_2.12-1.1.0/bin/windows/
  docker exec -i %container_id% %khome%kafka-topics.bat --create --zookeeper localhost:2181 --topic test --partitions 1 --replication-factor 1
  docker exec -i %container_id% %khome%kafka-console-producer.bat --broker-list kafka_dockeree_server:9092 --topic test 
  docker exec -i %container_id% %khome%kafka-console-consumer.bat --broker-list kafka_dockeree_server:9092 --topic test
</pre>

You should be then able to connect to the cluster on kafka_dockeree_server:9092 and to the web management (kafka-manager) on kafka_dockeree_server:9000.

# Contribute
If you want to, feel free!

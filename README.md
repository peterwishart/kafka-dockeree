# Introduction 
This is a development-only container of kafka based on instructions here: https://dzone.com/articles/running-apache-kafka-on-windows-os.

It includes zookeeper, a single kafka instance plus kafka manager web interface. All storage is ephemeral (but you could change that if needed).

Its mainly tested on Windows Docker EE but works on CE too.

# Getting Started
On Windows Server, follow standard instructions for setting up Docker EE.

E.g. instructions for setting up windows docker here: https://docs.docker.com/install/windows/docker-ee/

On Windows 10, install Docker CE: https://hub.docker.com/editions/community/docker-ce-desktop-windows
On Windows 10 1809 onwards you can install Docker EE as well: https://www.kauffmann.nl/2019/03/04/how-to-install-docker-on-windows-10-without-hyper-v/

On CE I've previously had error "The operation timed out because a response was not received from the Virtual Machine Container. (0xc0370109)" during container build - just retrying the build fixed it.

# Build and Test

Build and run the container via `build.ps1`. It takes a *very* long time on first run, mainly due to pulling and building scala for the kafka manager webUI.

Once running, run with `run.ps1`.
Note the first 3 digits of the container id and plug into the following powershell commands to test the container is working internally:

<pre>
  $id=700
  # this command creates a named topic with simple replication options
  docker exec -i $id /kafka/bin/windows/kafka-topics.bat --create --zookeeper localhost:2181 --topic test --partitions 1 --replication-factor 1
  # start this producer in one shell:
  docker exec -i $id /kafka/bin/windows/kafka-console-producer.bat --broker-list kafka_dockeree_server:9092 --topic test 
  # start this consumer in another:
  docker exec -i $id /kafka/bin/windows/kafka-console-consumer.bat --bootstrap-server kafka_dockeree_server:9092 --topic test
  # messages typed in the producer shell get echoed to the consumer
</pre>

You should be then able to connect to the cluster on kafka_dockeree_server:9092 and to the web management (kafka-manager) on http://kafka_dockeree_server:9000.

# Contribute
If you want to, feel free!

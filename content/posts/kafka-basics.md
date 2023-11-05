---
date : "2019-03-22T23:23:29+02:00"
draft : false
title : "Kafka 1: Basics"
topics: [Kafka]
Category: articles
weight: 3
---

***
As a consultant, it is hard to say "I don't know". With only very limited knowledge of Kafka, I started working as DevSecOps a few months ago on a large Kafka(confluent) installation for a bank.

I am writing this from my own perspective on the key takeaways after working and tuning this multi-dc setup. There will be topics that you feel important that is not covered here, please let me know so I can improve this.

***

---
# What is Kafka?
Apache Kafka is an open-source stream-processing software platform developed by LinkedIn.

* Publish and subscribe to streams of records, similar to a message queue or enterprise messaging system.
* Store streams of records in a fault-tolerant durable way.
* Process streams of records as they occur.

---
## Who is using Kafka and probably more
https://cwiki.apache.org/confluence/display/KAFKA/Powered+By

---
# Kafka components


---
## Kafka Broker
One or more of these forms a Kafka cluster, or sometimes be called Kafka server.

Also shows that Kafka is a brokered message queue system. (A non-brokered message queue system for example zeromq)

See this post here: https://stackoverflow.com/questions/39529747/advantages-disadvantages-of-brokered-vs-non-brokered-messaging-systems

---
### Kafka Topics
Topic, queue or category of messages. Topics are constructed by a number of partitions.

Each topic is controlled mainly by several attributes: Number of replicas, Number of partitions and  Retention time.

<img src="https://sookocheff.com/post/kafka/kafka-in-a-nutshell/log-anatomy.png" alt="topic anatomy"/>


Since Kafka is pub-sub, each consumer group is using their own offset, so clients can proceed with their own pace.

There are two types of retention policy:

* Delete: Discard messages that are too old, or exceeding size limitation. This is useful for normal event logs.
* Compact: Logs will be compacted to the keys or say to keep last state/message to such key. This is useful when treating topics as key-value database.

---
#### Kafka Partitions
Partition is *THE* atomic level in terms of storage, read, write and replication.

* Number of partitions is the MAX parallelism of a topic.
* Messages in a partition have strong ordering.

Messages with the same key will send to the same partition and a partition handles messages from multiple keys.

When a partition is replicated, it can be either leader, in-sync replica, follower.

A message/record can be written to the leader replica only, though messages can be read from any replica.

<img src="https://sookocheff.com/post/kafka/kafka-in-a-nutshell/producing-to-partitions.png" alt="topic anatomy"/>

Kafka partitions are assigned to brokers at:

* When a topic is created for the first time.
* When manually re-assigned.

So they are static at most of the time, even when *node failure* strikes.

---
## Zookeeper
Zookeeper is an inseparable part of the Kafka cluster although it is not being used all the time. That has been said, Zookeeper is needed when starting Kafka, failure handling but not running Kafka.

* Controller election

The controller is one of the most important broking entity in a Kafka ecosystem, and it also has the responsibility to maintain the leader-follower relationship across all the partitions. If a node by some reason is shutting down, it’s the controller’s responsibility to tell all the replicas to act as partition leaders in order to fulfill the duties of the partition leaders on the node that is about to fail. So, whenever a node shuts down, a new controller can be elected and it can also be made sure that at any given time, there is only one controller and all the follower nodes have agreed on that.

* Configuration Of Topics

The configuration regarding all the topics including the list of existing topics, the number of partitions for each topic, the location of all the replicas, list of configuration overrides for all topics and which node is the preferred leader, etc.

* Access control lists

Access control lists or ACLs for all the topics are also maintained within Zookeeper.

* Membership of the cluster

Zookeeper also maintains a list of all the brokers that are functioning at any given moment and are a part of the cluster.

---
### Kafka Producer

Any component in this landscape that sends data to Kafka is by definition a Kafka producer and uses producer API at some point.

Here, we are listing the Kafka Producer API’s main configuration settings:

* [client.id]:
It identifies the producer application.

* [producer.type]:
Either sync or async.

* [acks]:
Basically, it controls the criteria for producer requests that are considered complete.
    * -1/all: Make sure ALL replicas are written. (Slow/most reliable)
    * 0: As long as data is received by the replica leader. (Fastest/least reliable)
    * 1: Make sure when in-sync replicas are written. (Fast, also depends on min-ISR settings)

* [retries]:
“Retries” means if somehow producer request fails, then automatically retry with the specific value.

* [bootstrap.servers]:
It bootstraps list of brokers.

* [linger.ms]:
The producer will wait and batch for linger.ms before sending to the broker.
This will significantly improve throughput by micro batching but will also add latency per request as well.

* [key.serializer]:
It is a key for the serializer interface.

* [value.serializer]:
A value for the serializer interface.

* [batch.size]:
Simply, Buffer size.

* [buffer.memory]:
“buffer.memory” controls the total amount of memory available to the producer for buffering.

---
## Kafka Consumer

As Kafka producer, an application reads from Kafka uses consumer API at some point.
And here comes a bit connection to the number of partitions and a concept called consumer group.

A consumer group is a way to consume records in Kafka in parallel. Each partition is consumed by __Exactly one__ consumer in the group and the maximum consumer parallelism for a topic is the number of partitions.

<img src="https://i.stack.imgur.com/32esG.png" alt="Consumer group"/>


Here, we are listing the configuration settings for the Consumer client API −

* [bootstrap.servers]:
It bootstraps list of brokers.

* [group.id]:
To assign an individual consumer to a group.

* [enable.auto.commit]:
Basically, it enables auto-commit for offsets if the value is true, otherwise not committed.

* [auto.commit.interval.ms]:
Basically, it returns how often updated consumed offsets are written to ZooKeeper.

* [session.timeout.ms]:
It indicates how many milliseconds Kafka will wait for the ZooKeeper to respond to a request (read or write) before giving up and continuing to consume messages.

---
## Kafka Connect

Kafka connect is a common framework to transfer records in and out of Kafka cluster.

Why use Kafka connect?

* Auto-recovery After Failure

To each record, a “source” connector can attach arbitrary “source location” information which it passes to Kafka Connect. Hence, at the time of failure Kafka Connect will automatically provide this information back to the connector. In this way, it can resume where it failed. Additionally, auto recovery for “sink” connectors is even easier.

* Auto-failover

Auto-failover is possible because the Kafka Connect nodes build a Kafka cluster. That means if suppose one node fails the work that it is doing is redistributed to other nodes.

* Simple Parallelism

A connector can define data import or export tasks, especially which execute in parallel.

* Community and existing connectors
(Incomplete list of existing connectors)
    * Kafka Connect ActiveMQ Connector
    * Kafka FileStream Connectors
    * Kafka Connect HDFS
    * Kafka Connect JDBC Connector
    * Kafka Connect S3
    * Kafka Connect Elasticsearch Connector
    * Kafka Connect IBM MQ Connector
    * Kafka Connect JMS ConnectorKafka Connect Cassandra Connector
    * Kafka Connect GCS
    * Kafka Connect Microsoft SQL Server Connector
    * Kafka Connect InfluxDB Connector
    * Kafka Connect Kinesis Source Connector
    * Kafka Connect MapR DB Connector
    * Kafka Connect MQTT Connector
    * Kafka Connect RabbitMQ Source Connector
    * Kafka Connect Salesforce Connector
    * Kafka Connect Syslog Connector



<img src="https://www.confluent.io/wp-content/uploads/Picture1-1.png" alt="Why kafka" width=600px/>

In case you need to develop a new connector, Kafka connect provides:

* A common framework for Kafka connectors
It standardizes the integration of other data systems with Kafka. Also, simplifies connector development, deployment, and management.

* Distributed and standalone modes
Scale up to a large, centrally managed service supporting an entire organization or scale down to development, testing, and small production deployments.

* REST interface
By an easy to use REST API, we can submit and manage connectors to our Kafka Connect cluster.

* Automatic offset management
However, Kafka Connect can manage the offset commit process automatically even with just a little information from connectors. Hence, connector developers do not need to worry about this error-prone part of connector development.

* Distributed and scalable by default
It builds upon the existing group management protocol. And to scale up a Kafka Connect cluster we can add more workers.

* Streaming/batch integration
We can say for bridging streaming and batch data systems, Kafka Connect is an ideal solution.

---
## Schema Registry

Schema Registry stores a versioned history of all schemas and allows the evolution of schemas according to the configured compatibility settings. It also provides a plugin to clients that handle schema storage and retrieval for messages that are sent in Avro format.

Why do we need schema in the first place?

Kafka sees every record as bytes, so schema works and lives on the application level. It is very likely the producer and consumer is not the same application, not in the code base and there is a need collaboration between them.

A schema registry is here to:

* Reduce payload
Instead send data with a header, JSON structure, only actual payload needed to pass to Kafka.

* Data validation and evolvement
Invalid messages will never get to approach to Kafka. Schema can be evolved to the next version without breaking existing parts.

* Schema access
Instead of distributing class definition, object structure can be distributed via RESTful API alone with all previous versions.


<img src="https://www.confluent.io/wp-content/uploads/dwg_SchemaReg_howitworks.png" alt="Schema registry" width=600px/>

In addition to schema management, use schema alone will also reduce record size to Kafka.

If you send a message using JSON, 50% or more payload could be wasted by message structure. Using a schema registry, you only need to transfer the schema identification alone with the payload.

A workflow using a schema registry:

* The serializer places a call to the schema registry, to see if it has a format for the data the application wants to publish. If it does, schema registry passes that format to the application’s serializer, which uses it to filter out incorrectly formatted messages.

* After checking the schema is authorized, it’s automatically serialized and there’s no effort you need to put into it. The message will, as expected, be delivered to the Kafka topic.

* Your consumers will handle deserialization, making sure your data pipeline can quickly evolve and continue to have clean data. You simply need to have all applications call the schema registry when publishing.


# References

* https://data-flair.training/blogs/kafka-tutorials-home/
* https://docs.confluent.io/current/getting-started.html
* https://kafka.apache.org/documentation/
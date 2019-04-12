---
date : "2019-03-22T23:23:29+02:00"
draft : false
title : "Kafka 1: Basics"
img : "articles/apache-kafka.png"
Category: articles
---

---
## What is kafka?
Apache Kafka is an open-source stream-processing software platform developed by LinkedIn

---
### Who is using kafka and probably more
https://cwiki.apache.org/confluence/display/KAFKA/Powered+By

---
## Kafka components


---
### Kafka Broker
One or more of these forms a kafka cluster, or sometimes be called Kafka server.

Also shows that kafka is a brokered message queue system. (A non-brokered message queue system for example: zeromq)

See this post here: https://stackoverflow.com/questions/39529747/advantages-disadvantages-of-brokered-vs-non-brokered-messaging-systems

---
#### Kafka Topics
Topic, queue or category of messages. Topics are constructed by number of partitions.

Each topic is controlled mainly by several attributes: Number of replicas, Number of partitions and  Retention time.

<img src="https://sookocheff.com/post/kafka/kafka-in-a-nutshell/log-anatomy.png" alt="topic anatomy"/>


Since Kafka is pub-sub, each consumer group is using their own offset, so clients can proceed with their own pace.

There are two types of retention policy:

* Delete: Discard messages that is too old, or exceeding size limitation. This is useful for normal event logs.
* Compact: Logs will be compacted to the keys or say to keep last state/message to such key. This is useful when treating topic as key value database.

---
##### Kafka Partitions
Partition is *THE* atomic level in terms of storage, read, write and replication.

* Number of partitions is the MAX parallelism of a topic.
* Messages in a partition have strong ordering.

Messages with the same key will send to the same partition and a partition handles messages from multiple keys.

When a partition is replicated, it can be either leader, in-sync replica, follower.

A message/record can be written to the leader replica only, though messages can be read from any replica.

<img src="https://sookocheff.com/post/kafka/kafka-in-a-nutshell/producing-to-partitions.png" alt="topic anatomy"/>

Kafka partitions are assigned to brokers at:

* When topic is created at first time.
* When manually re-assigned.

So they are static at most of time, even when *node failure* strikes.

---
### Zookeeper
Zookeeper is an inseparable part of kafka cluster although it is not being used all the time. That has been said, Zookeeper is needed when starting kafka, failure handling but not running kafka.

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

Any component in this landscape that sends data to kafka is by definition a Kafka producer and uses producer API at some point.

Here, we are listing the Kafka Producer API’s main configuration settings:

* [client.id]:
It identifies producer application.

* [producer.type]:
Either sync or async.

* [acks]:
Basically, it controls the criteria for producer requests that are considered complete.
    * -1/all    : Make sure ALL replicas are written. (Slow/most reliable)
    * 0         : As long as data is received by the replica leader. (Fastest/least reliable)
    * 1         : Make sure when in-sync replicas are written. (Fast, also depends on min-ISR settings)

* [retries]:
“Retries” means if somehow producer request fails, then automatically retry with the specific value.

* [bootstrap.servers]:
It bootstraps list of brokers.

* [linger.ms]:
Producer will wait and batch for linger.ms before sending to the broker.
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
### Kafka Consumer

As Kafka producer, an application reads from kafka uses consumer API at some point.
And here comes a bit connection to the number of partitions and a concept called consumer group.

A consumer group is the way to consume records in kafka in parallel. Each partition is consumed by __Exactly one__ consumer in the group and the maximum consumer parallelism for a topic is the number of partitions.
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

* session.timeout.ms]:
It indicates how many milliseconds Kafka will wait for the ZooKeeper to respond to a request (read or write) before giving up and continuing to consume messages.

---
### Kafka Connect
---
### Schema Registry

## Characteristics

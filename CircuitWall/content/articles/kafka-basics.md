---
date : "2019-04-01T23:23:29+02:00"
draft : false
title : "Kafka 1: Basics"
img : "articles/apache-kafka.png"
weight : 1
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

So they are static at most of time, even when *node failure*         strikes.

---
### Zookeeper

---
### Kafka Producer
---
### Kafka Consumer
---
### Kafka Connect
---
### Schema Registry

## Characteristics

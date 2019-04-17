---
date : "2019-04-15T08:08:29+02:00"
draft : false
title : "Kafka 2: Multi Datacenter Setup"
img : "articles/kafka-multi-dc/kafka_diagram.png"
topics: [Kafka]
Category: articles
---

***

The multi-datacenter topic come up usually because of two reasons:

* Your business now expanded into another part of the world.
* You need reliability more than pure performance (to some degree).

I will skip the single DC setup here, as you can read upon in basically any
<a href="http://{{< relref "kafka-basics.md" >}}">kafka introduction documents</a>.

When comes to multi-datacenter setup there are, in my opinion, there are three major aspects during normal operations and when disaster strikes to consider:

* Consistency: If datacenter fails, will there be data lose when switched to the other datacenter?
* Availability: Will failure of one datacenter cause partitions offline? this may caused by
    * No in sync replica available.
    * Zookeeper cluster cannot form a quorum and can not elect new leaders.
    * Brokers not available.
* Performance: What is the latency and/or throughput characteristics?

This is given that the producer receives confirmation of message been written and this is highly related to consistency and performance.
acks=

* -1/all:   All ISR reported back and acknowledged commit, slowest but consistent.
* 0:        As long as broker receives it (not even committed), fastest but most likely to create inconsistency.
* 1:        Whenever the leader is committed. Most common case to balance between speed and data security.

Before discuss into different setups, here are some heavily used abbreviations:

```
nr-dc:      Number of data centers
nr-rep:     (default.replication.factor) Number of replicas
ISR:        In-sync replicas
min-ISR:    (min.insync.replicas) Minimum in-sync replicas
```

All the scenarios are based on producer setting acks=1 and topics created using default settings.

---
# Two data centers and 2.5 data centers

Note: 2.5 DC is basically 2DC+1 zookeeper on the third DC.

---
***To set a tone here, two data centers set up for Kafka is NOT ideal!***

----
There will be trade-offs for two dc setups. before continue you need to understand the concept of <a href="https://en.wikipedia.org/wiki/CAP_theorem">CAP theorem</a>.
According to LinkedIn engineers, Kafka is a CA system. If there is a network partition happens, you will have either split brian situation or failed cluster. It is a choice when you have to shut down part of the cluster to prevent split brain.

When comes to two dc setups, you can not even achieve CA across the cluster either. Having said that, you can still tune individual topics to have either consistency OR availability.

---
## Stretched cluster

With rack awareness, two data centers joined as one cluster. The rack awareness feature spreads replicas of the same partition across different racks/data centers. This extends the guarantees Kafka provides for broker-failure to cover rack-failure, limiting the risk of data loss should all the brokers on a rack/data center fail at once.

---
### Consistency first configuration
````min-ISR > round(nr-rep/nr-dc)````

The minimum in-sync replica is larger than replicas assigned per data center.

![Consistency first fail](/img/articles/kafka-multi-dc/Consistancy-first.png)

---
#### Consistency
With this setup, it is guaranteed to have at least *ONE* in sync replica on the other data center. When there is one data center offline, the data is already secured on the other data center.

#### Availability
One data center goes down will render partitions goes offline because it just won't have enough in-sync replicas (even at least one replica is in-sync).

The way to re-enable the cluster is to either

* Change the min-ISR setting to less than replica per data center, a manual intervention.
* Re-assign partition allocation, also a manual intervention.

In a single tenant environment, producers need to able to buffer messages locally until the cluster is back functioning.

In a multi-tenant environment, there will probably message lost.


#### Performance
Whichever partition leader you are writing to will need to replicate to the other data center. Your writing latency will be the sum of normal latency plus latency between data centers.

---
### Availability first configuration
````nr-rep – min-ISR >= nr-rep/nr-dc````

There are more nodes can be down at the same time(````nr-rep – min-ISR````) then the number of replicas per data center.

![Availability first](/img/articles/kafka-multi-dc/availability-first.png)

There are actually two cases here:

* ISRs reside in the same data center, surprise! rack awareness does not honor ISR.
* ISRs spread out to different data centers.


![Availability first fail](/img/articles/kafka-multi-dc/availability-first-fail.png)

Since there will be so many partitions in the cluster, you won't avoid the first case anyway.

Why this is important? because by default, non-ISR cannot be elected as leader replica, if there is no ISR available, the partition goes offline.

To make this work, there is another piece to this puzzle: ```unclean.leader.election.enable=true````.

Here is what happens when one data center fails.

![Availability first dc fail](/img/articles/kafka-multi-dc/availability-first-leader-election.png)


---
#### Consistency
 This setting will allow followers to become leaders and you will have data missing for records did not sync in time and there definitely will be some. When old leaders come back online, that will bring back the missing records and maybe create duplicates as well.

#### Availability
This setup allows one data center goes down entirely.

#### Performance
Less min-ISR means better performance, especially data not necessarily synced across to the other data center before responding to the producer.

---
### 2.5 data centers
As I mentioned before, to perform any failover recovery you need zookeeper quorum and we just mentioned partitions in previous setups.

In previous setups, you need to form a zookeeper cluster (odd nodes) across two data centers that means one in dc1 two in dc2 or two in dc1 and three in dc2.

If one data center with more zookeeper nodes went down it brings the zookeeper cluster with it, because zookeeper needs a majority to perform election.

With 1/3/5 zookeeper(s) resides on the third data center greatly reduced the risk on the zookeeper cluster.


---
## Replicated cluster

From producer or consumer's perspective, there are two clusters and data is synced with an almost guaranteed delay between them.

There are a set of popular tools:

* Mirror maker  - Apache
* Proprietary Replicator    - Confluent / Uber /IBM

Why? because Mirrormaker from Kafka is far from perfect.

* It replicates data but topic configuration.
* Takes a long time and sometimes give up rebalance when mirroring clusters with a lot of partitions. This effects every time you need to add a new topic as well.

Active-Active and Active-Passive are the two concepts to replicated clusters

AA: Producers and consumers may using both clusters to produce and consume data. With delays in between, the order is not guaranteed outside of the data center.

AP: The other cluster is hot standby, and switching to the other cluster needs reconfiguration on the client sides.

---
### Consistency
Well there will be data cannot be synced in time, and that creates inconsistency.

### Availability
With the active-active design, you can put both clusters into bootstrap server list in theory(and not recommended) but that will sacrifice ordering and a bit performance as well, since you may be connecting to the server that is further away geographically.

Other than the case described above, if there is a data center offline, you need to do a manual recover and switch to another cluster.

### Performance
I think this may be one of the biggest advantages. Clients can choose to talk to the cluster geographically closer.

---
# Three data centers or more

````min-ISR > round(nr-rep/nr-dc)```` same formula as consistency first setup.

A stretched three data centers cluster is, in my opinion, the best setup. Consistency and availability can be achieved with little effort.


```
nr-rep  = nr-dc * n
min-ISR = n+1
```

Where n=1/2/3... and n+1 <= number of nodes per data center.


Here is a simulation for 3 replicas and min-ISR=2 setup:

![Three dc setup](/img/articles/kafka-multi-dc/three-dc.png)

---
## Consistency
When a record is delivered, it is guaranteed there is a replica lives on another data center.

## Availability
It can suffer a total loss of ONE data center and still available to read and write.

## Performance
Same performance attribute as two data centers stretched cluster. All requests have to add latency to sync replica to another data center.


# Summary
With one data center, Kafka can achieve consistency and availability on the local level. When comes to multi-datacenter setup you can prevent incidents that happen once every few years.

Although data center failure is rare, it is important to feel safe and prepared for such situations.

Choose and implement a solution to your needs, test them before going to production and remember that, you have the chance to customize topics individually as most of the configurations are per topic. If it is possible, go for the three data center setup, it can achieve both consistency and availability on the cluster level with little overhead.

In general, I am interested in site reliability topics, let me know your thoughts!


# References

* https://docs.confluent.io/current/getting-started.html
* https://kafka.apache.org/documentation/
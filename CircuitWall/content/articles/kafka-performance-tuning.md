---
date : "2019-05-31T19:08:29+02:00"
draft : false
title : "Kafka 3: Performance tuning"
img : "articles/Production-server-configurations-01.jpg"
Category: articles
---
### This is just another approach to full CAP (Consistency, Availability, Partition tolerance).
 
Here I will try to discuss different setups of kafka clusters in multiple data centers.


### 1 DC
Small development cluster setup.

As every node resides in one data center, you have no data center fail over.
What you do have is with correct setting

### 2 DC or  2.5 DC
Enterprise setup where you have to choose between availability vs consistency.
#### CP
#### AP

### 3 DC or more
Enterprise setup with both availability and consistency?

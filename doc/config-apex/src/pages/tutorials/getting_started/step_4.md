---
title: "Config Service"
description: "Config Service"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 4
---

## {$page.title}

Config service in Config.apex works as a single entry point to access the configurations. It is backed by CacheStore to provide high performance. Below is how we create an instance of the config service.

```javascript
CacheStore store = new CacheStore('PARTITION');
Config configService = new Config(store);
```

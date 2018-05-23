---
title: "Cache Management"
description: "Cache Management"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 3
---

## {$page.title}

Once you have set up a cache partition, you can use `CacheStore` to easily access your cache.

```javascript
CacheStore store = new CacheStore('Your Partition');
store.OrgCache.put('key', 'value');
String value = (String)store.get('key');
```

Internally CacheStore will bundle single cache requests into a big cache request to improve the cache efficiency. If the cache bundle is too big for one request, CacheStore will split it into smaller bundles. Care is taken and you worry no more about the details of managing Salesforce Platform Cache.

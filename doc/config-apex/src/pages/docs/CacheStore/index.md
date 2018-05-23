---
title: "CacheStore"
description: "CacheStore"
layout: "guide"
icon: "cloud"
weight: 4
---

###### {$page.description}

<article id="1">

## CacheStore

`CacheStore` provides a ready-to-use solution for cache management.

According to Salesforce Platform Cache Best Practices, too many requests for small cached items are inefficient.
A recommended way is to bundle these items into a large item to be cached. The problem is that we have a size limit for
the single cached item. That means that we cannot put too huge an item into the cache.

CacheStore is hence created to offer an elegant way to solve this. Inside CacheStore, we manage a list of bundles, each of them
is a `Map<String, Object`. Whenever users put an item to cache, we will try to fit it into a suitable bundle, and then cache the
whole bundle. If no suitable bundle is found, a new bundle will be created and added to the list.

To check the details, please see the implementation of `CacheStore`.

Here is how we use it.

```javascript
CacheStore store = new CacheStore('Your Partition');
store.OrgCache.put('key', 'value');
String value = (String)store.get('key');
```

</article>

<article id="2">

## Constructors

| Constructor | Description |
| ----------- | ----------- |
| CacheStore(String) | Create a cache store with the partition name |

</article>

<article id="3">

## Methods

| Method | Description |
| ----------- | ----------- |
| contains(String) | Check if the item exists in OrgCache or SessionCache |
| get(String) | Get the item from OrgCache and SessionCache |

</article>

<article id="4">

## Cache Providers

After creating a CacheStore, we have two cache providers, `OrgCache` and `SessionCache`.

```javascript
CacheStore store = new CacheStore('Your Partition');
store.OrgCache.put('key', 'value');
String value = (String)store.SessionCache.get('key');
```

| Method | Description |
| ----------- | ----------- |
| contains(String) | Check if the cache provider contains the item |
| get(String) | Get the item from the cache |
| put(String, Object) | Put the item to the cache |
| reload() | Reload the cache |

</article>

---
title: "Config"
description: "Config Service"
layout: "guide"
icon: "flash"
weight: 1
---

###### {$page.description}

<article id="1">

## Background

In a large system, we may encounter configurations from different sources. For example, we can
store configurations in custom settings, or some custom SObjects. Even we can read configurations from
external web services. So configurations are grouped by where they come from, and when we want to use the configs,
we need to know their sources. However, what we ideally want is that our configurations are grouped by features and functions,
and we don't want to be disturbed by where the configs come from and how we should access the configs. Under this background,
we have the idea of building a config system, which provides a unified API that gives a consistent access to our configurations.

</article>

<article id="2">

## Config Service

With the purpose above, we built the Config Service, which behaves pretty much like the http service.

Here are the factors involved in Config Service:

- Config URL
A config service provider is bound to a specific config url. A config URL may be an exact String, or a pattern that
matches a range of Strings, with variables starting with '${' and ending with '}'.

- Config Request
A request for retrieving or updating the value of the configuration url. Like http requests, we can request a config url
like this:

```
/System/version?type=String
```

Additional parameters may be specified. Also when it comes to the requests for updating, we can send the data of `Map<String, Object>`.

Config requests are divided into two types: `read`(`get`) and `write`(`put`).

- Config Response
For `read` config request, we respond with the value of the config. For `write` config request, the response is not used.

- Config Handler
A config handler is a Func used to process the logic for config requests. Usually we need to specify a config handler for each type of the config request.

</article>

<article id="3">

## Config Service Setup

Config service uses `CacheStore` to improve performance, so we need an instance of CacheStore to build the config service.

```javascript
CacheStore store = new CacheStore('PARTITION');
Config configService = new Config(store);
```

It's recommended that for one application, we use one global config service like this:

```javascript
public class MyConfig {
    private static Config configService;

    public static Config getConfig() {
        if(configService == null) {
            CacheStore store = new CacheStore('PARTITION_NAME');
            configService = new Config(store);

            // set up the config service
        }

        return configService;
    }
}
```

During the setup, we need register config handlers.

```javascript
configService.onRead('/System/version', new SystemVersionFunc());
configService.onWrite('/System/version', new SystemVersionWriteFunc());
```

</article>

<article id="4">

## Config Handlers

A config handler is actuall a Func.

Here is how we implement a `onRead` handler.

```javascript
public class OnReadFunc extends Func {
    public override Object exec(Object arg) {
        Map<String, String> params = (Map<String, String>)arg;
        // Custom logic
        return 'config value';
    }
}
```

The `params` are collected from the config request. For example, for a config request like this,

```
Config request
/System/version/1?type=String
```

`params` will be collected as:

```
{ 'number' => '1', 'type' => 'String' }
```

Here is how we implement a `onWrite` handler.

```javascript
public class OnWriteFunc extends Func {
    public override Object exec(Object arg1, Object arg2) {
        Map<String, String> params = (Map<String, String>)arg1;
        Map<String, Object> data = (Map<String, Object>)arg2;
        // Custom logic
        return null;
    }
}
```

</article>

<article id="5">

## Read Configuration

After the config service is set up, we can use it globally to read configurations.

```javascript
String version = (String)configService.read('/System/version');
// equivalent to
String version = (String)configService.get('/System/version');
```

By default, we can even specify what kind of data type we want to get.

```javascript
String version = (String)configService.read('/System/version?type=String');
```

Config.apex will convert the result configuration value according to the type you specified.

</article>

<article id="6">

## Write Configuration

We can write configurations too, using the config service.

```javascript
configService.write('/System/version', new Map<String, Object>{
    'value': '1.0.0'
});
// equivalent to
configService.put('/System/version', new Map<String, Object>{
    'value': '1.0.0'
});
```

We can pass in both params from the request config url and the data of `Map<String, Object>`.

</article>

<article id="7">

## Constructors

| Constructor | Description |
| ----------- | ----------- |
| Config(CacheStore) | Create a config from the CacheStore |

</article>

<article id="8">

## Common Methods

| Method | Description |
| ----------- | ----------- |
| getConfigPaths() | Get all config paths |
| get(String) | Get the config |
| read(String) | Read the config |
| put(String, Map&lt;String, Object&gt;) | Write the config |
| write(String, Map&lt;String, Object&gt;) | Write the config |

</article>

<article id="9">

## Setup Methods

| Method | Description |
| ----------- | ----------- |
| onReadWrite(String, Boolean, String, Func, Func) | Register read/write handlers |
| onReadWrite(String, Boolean, Func, Func) | Register read/write handlers |
| onReadWrite(String, Func, Func) | Register read/write handlers |
| onRead(String, Boolean, String, Func) | Register read handler |
| onRead(String, Boolean, Func) | Register read handler |
| onRead(String, Func) | Register read handler |
| onWrite(String, Boolean, String, Func) | Register write handler |
| onWrite(String, Boolean, Func) | Register write handler |
| onWrite(String, Func) | Register write handler |

</article>

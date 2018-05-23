# Config.apex
Config.apex is a library to manage your configurations and cache in an elegant way.

## Why Config.apex?
We may have been deep in the trouble of managing configurations through different sources, like custom settings, some SObjects, or even from web services. Config.apex is aimed to provide a universal way to access and manage your configurations. The ultimate goal is, "One Config API, Various Config Providers". Behind Config.apex, we use a standalone CacheStore to effectively manipulate Salesforce Platform Cache.

## Dependencies
Config.apex has a dependency over [R.apex](https://github.com/Click-to-Cloud/R.apex/).

Please include it before including Config.apex.

## Preliminary Knowledge
Config.apex uses Funcs from R.apex as the callback mechanism, and it requires a fair amount of knowledge on R.apex. If you want to go deeper with Config.apex, please do check out [R.apex](https://github.com/Click-to-Cloud/R.apex/).

## Examples
### Cache Management
Once you have set up a cache partition, you can use `CacheStore` to easily access your cache.

```java
CacheStore store = new CacheStore('Your Partition');
store.OrgCache.put('key', 'value');
String value = (String)store.get('key');
```

Internally CacheStore will bundle single cache requests into a big cache request to improve the cache efficiency. If the cache bundle is too big for one request, CacheStore will split it into smaller bundles. Care is taken and you worry no more about the details of managing Salesforce Platform Cache.

### Config Service
Config service in Config.apex works as a single entry point to access the configurations. It is backed by CacheStore to provide high performance. Below is how we create an instance of the config service.

```java
CacheStore store = new CacheStore('PARTITION');
Config configService = new Config(store);
```

### Config Handlers
After creating the instance of the config service, we need to correctly set it up for use. A config service is a facade that accepts config requests on certain config urls, process the requests and send back the responses. It dispatches the config requests to config handlers to process.

```java
configService.onRead('/System/version', new SystemVersionFunc());
```

Here we registered a config handler `SystemVersionFunc` to process requests from config url `/System/version`. Also we can register config handlers to process requests to update configuration values.

```java
configService.onWrite('/System/version', new SystemVersionWriteFunc());
```

By default, config handlers work on the org cache. But we can specify them to work on the session cache too.

```java
configService.onRead('/System/version', true, Config.SCOPE_SESSION, new SystemVersionFunc());
```

Or even we can turn off the cache used by the config handlers, when sometimes we need to always get the update-to-date data.

```java
configService.onRead('/System/version', false, new SystemVersionFunc());
```

In case of complicated config requests, we also support parameterized url matching.

```java
public class CustomHandler extends Func {
    public override Object exec(Object arg) {
        Map<String, String> params = (Map<String, String>)arg;
        String version = params.get('version');
        // Custom logic
        return 'config value';
    }
    
    public override Object exec(Object arg1, Object arg2) {
        Map<String, String> params = (Map<String, String>)arg1;
        Map<String, Object> data = (Map<String, Object>)arg2;
        // Custom logic
        return null;
    }
}

Func handler = new CustomHandler();
configService.onReadWrite('/System/version/${version}', handler, handler);
```

### Read Configuration
After the config service is set up, we can use it globally to read configurations.

```java
String version = (String)configService.read('/System/version');
// equivalent to 
String version = (String)configService.get('/System/version');
```

By default, we can even specify what kind of data type we want to get.

```java
String version = (String)configService.read('/System/version?type=String');
```

Config.apex will convert the result configuration value according to the type you specified.

### Write Configuration
We can write configurations too, using the config service.

```java
configService.write('/System/version', new Map<String, Object>{
    'value': '1.0.0'
});
// equivalent to 
configService.put('/System/version', new Map<String, Object>{
    'value': '1.0.0'
});
```

We can pass in both params from the request config url and the data of `Map<String, Object>`.

### Integrations
Config.apex has a good integration with custom settings and SObjects.

```java
configService.onRead('/System/CustomButton/list', new Config.SObjectHandler('Custom_Button__c')
    .fetch('SELECT Id, Name FROM Custom_Button__c')
    .then(R.pluck.apply('Name'))
);
```

`SObjectHandler` can be used to handle SObjects as well as custom setting objects, to easily manage query, insert, update and delete operations.

---
title: "Config Handlers"
description: "Config Handlers"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 5
---

## {$page.title}

After creating the instance of the config service, we need to correctly set it up for use. A config service is a facade that accepts config requests on certain config urls, process the requests and send back the responses. It dispatches the config requests to config handlers to process.

```javascript
onfigService.onRead('/System/version', new SystemVersionFunc());
```

Here we registered a config handler `SystemVersionFunc` to process requests from config url `/System/version`. Also we can register config handlers to process requests to update configuration values.

```javascript
configService.onWrite('/System/version', new SystemVersionWriteFunc());
```

By default, config handlers work on the org cache. But we can specify them to work on the session cache too.

```javascript
configService.onRead('/System/version', true, Config.SCOPE_SESSION, new SystemVersionFunc());
```

Or even we can turn off the cache used by the config handlers, when sometimes we need to always get the update-to-date data.

```javascript
configService.onRead('/System/version', false, new SystemVersionFunc());
```

In case of complicated config requests, we also support parameterized url matching.

```javascript
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

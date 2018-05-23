---
title: "Read Configuration"
description: "Read Configuration"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 6
---

## {$page.title}

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

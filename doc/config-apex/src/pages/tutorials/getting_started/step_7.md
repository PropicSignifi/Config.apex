---
title: "Write Configuration"
description: "Write Configuration"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 7
---

## {$page.title}

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

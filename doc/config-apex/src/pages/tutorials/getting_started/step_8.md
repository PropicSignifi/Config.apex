---
title: "Integrations"
description: "Integrations"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 8
---

## {$page.title}

Config.apex has a good integration with custom settings and SObjects.

```javascript
configService.onRead('/System/CustomButton/list', new Config.SObjectHandler('Custom_Button__c')
    .fetch('SELECT Id, Name FROM Custom_Button__c')
    .then(R.pluck.apply('Name'))
);
```

`SObjectHandler` can be used to handle SObjects as well as custom setting objects, to easily manage query, insert, update and delete operations.

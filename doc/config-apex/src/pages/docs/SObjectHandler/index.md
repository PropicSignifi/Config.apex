---
title: "SObjectHandler"
description: "SObjectHandler"
layout: "guide"
icon: "code-file"
weight: 2
---

###### {$page.description}

<article id="1">

## SObjectHandler

`SObjectHandler` provides easy integrations with SObjects and CustomSettings.

To create a read handler, we can do this:

```javascript
configService.onRead('/System/CustomButton/list', new Config.SObjectHandler('Custom_Button__c')
    .fetch('SELECT Id, Name FROM Custom_Button__c')
    .then(R.pluck.apply('Name'))
);
```

To create a write handler, we can do this:

```javascript
configService.onWrite('/System/CustomButton/new', new Config.SObjectHandler('Custom_Button__c')
    .doInsert(new Map<String, Object>{ ...  });
);
```

</article>

<article id="2">

## Methods

| Method | Description |
| ------ | ----------- |
| SObjectHandler(String) | Create an instance with the object type |
| fetch(String) | Get the records from the query |
| then(Func) | Add the Func to process the data |
| doInsert(Map&lt;String, Object&gt;) | Insert the data |
| doUpdate(Map&lt;String, Object&gt;) | Update the records with the data |
| doDelete() | Delete the records |

</article>

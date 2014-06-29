angular-sticky-table-header [![Build Status](https://travis-ci.org/turn/angular-sticky-table-header.svg?branch=master)](https://travis-ci.org/turn/angular-sticky-table-header) [![Coverage Status](https://coveralls.io/repos/turn/angular-sticky-table-header/badge.png?branch=master)](https://coveralls.io/r/turn/angular-sticky-table-header?branch=master)
===========================

### dependencies

- angular 1.0.8
- jquery ^1.11
- lodash ^2.4
- watch-dom ^0.0

### usage

**html**

```html
...
<link rel="stylesheet" href="angular-sticky-table-header.css">

</head>
<body>

<div ng-controller="fooCtrl">
	<div
		sticky-table-header
		rows="rowCollection"
		disabled="expression"
	>
		<table>
			...
		</table>
	</div>
</div>
...
<script src="angular-sticky-table-header.js"></script>
```

**js**

```js
angular
.module('foo', ['turn/stickyTableHeader'])
.controller('fooCtrl', ['$scope', function ($scope) {
	
	$scope.rowCollection = [
		{ column1: 'foo', column2: 'bar', ... },
		...
	];

	$scope.expression = false;

});
```

### how it works

1. create an in-dom clone of any `<th>`s (this is to preserve spacing when the header is absolutely positioned, and to serve as source of truth when computing `<th>` widths in steps 3 and 5)
2. hide the clone
3. set each `<th>`'s width equal to the offsetWidth of each one's source `<th>`
4. when the user scrolls, show the cloned `<th>`s if the original `<th>`s are off-screen
5. when the window is resized or a data collection changes, resize the `<th>`s accordingly
6. when the original `<th>` is modified, re-clone it

### events that trigger column resizing

- initial load
- window resize
- row collection change
- original clone modification

### running the demo

```shell
sass index.scss index.css
bower install
```

then pop open index.html in a browser.

### running the tests

```
bower install
npm install
grunt
```

### todo

- more unit tests
- end to end tests
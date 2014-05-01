angular-sticky-table-header
===================

### dependencies

- angular 1.0.8
- jquery 1.x.x
- lodash 2.x.x (`_.debounce`)

### usage

**html**

```html
<div ng-controller="fooCtrl">
	<div sticky-header columns="columnCollection" rows="rowCollection">
		<table>
			...
		</table>
	</div>
</div>
```

**js**

```js
angular
.module('foo', ['angularStickyTableHeader'])
.controller('fooCtrl', ['$scope', function ($scope) {
	
	$scope.columnCollection = ['column1', 'column2', ...];
	$scope.rowCollection = [
		{ column1: 'foo', column2: 'bar', ... },
		...
	];

});
```

**css**

```css
[sticky-table-header] {
	position: relative;
}

[sticky-table-header] .sticky-clone {
	background: #fff;
	display: none;
	position: fixed;
		left: 0;
		right: 0;
		top: 0;
}

[sticky-table-header] .sticky-stuck {
	display: table;
}
```

### how it works

1. create an in-dom clone of any `<th>`s (this is to preserve spacing when the header is absolutely positioned, and to serve as source of truth when computing `<th>` widths in steps 3 and 5)
2. hide the clone
3. set each `<th>`'s width equal to the offsetWidth of each one's source `<th>`
4. when the user scrolls, show the cloned `<th>`s if the original `<th>`s are off-screen
5. when the window is resized or a data collection changes, resize the `<th>`s accordingly

### events that trigger column resizing

- initial load
- window resize
- column collection change
- row collection change

### running the demo

```shell
sass index.scss index.css
bower install
```

then pop open index.html in a browser.

### todo

- unit tests
- layout tests
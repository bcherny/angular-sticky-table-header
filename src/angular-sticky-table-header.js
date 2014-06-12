angular
.module('turn/stickyTableHeader', ['watchDom'])
.value('stickyTableHeaderOptions', {
	cloneClassName: 'sticky-clone',
	stuckClassName: 'sticky-stuck',
	interval: 10,
	observeHeaderInterval: 100
})
.service('stickyTableHeaderUtil', function() {
			
	this.guard = function (fn, condition) {
		return function(){
			return condition() ? fn.apply(this, arguments) : false;
		};
	};

})
.directive('stickyTableHeader', function ($timeout, $window, stickyTableHeaderOptions, stickyTableHeaderUtil, watchDom) {

	var options = stickyTableHeaderOptions,
		util = stickyTableHeaderUtil;

	return {
		restrict: 'A',
		scope: {
			disabled: '=',
			rows: '='
		},
		template: '<div ng-transclude></div>',
		transclude: true,
		link: function (scope, element) {

			angular.extend(scope, {

				// show the cloned <tr>?
				stuck: false,

				// MutationObserver bound to the original <tr>
				mutationObserver: null,

				// original <tr>'s left/top offsets
				offset: {},

				// original <tr>
				tr: element.find('tr')[0],

				// cloned <tr>
				clone: null,

				// store references to events bound to the
				// $window, so they can be safely removed
				windowEvents: {},

				createClone: function () {

					return angular
						.element(scope.tr)
						.clone(true, true)
						.addClass(options.cloneClassName)
						.appendTo(element.find('thead'));

				},

				resetClone: _.debounce(function () {

					scope.removeClones();
					scope.clone = scope.createClone();
					$timeout(scope.sizeClone);

				}, 200),

				removeClones: function () {

					scope.stuck = false;

					element
						.find('.' + options.cloneClassName)
						.remove();

				},

				setClonedCellWidths: ifClone(function () {

					var clones = scope.clone.find('th'),
						ths = element.find('th');

					angular.forEach(clones, function(clone, n) {
						angular
							.element(clone)
							.css('width', angular.element(ths[n]).css('width'));
					});

				}),

				setCloneGutter: ifClone(function () {

					scope.clone.css({
						left: scope.offset.left,
						width: scope.offset.width
					});

				}),

				setOffset: function () {

					scope.offset = angular.extend(
						{},

						// for the width
						scope.tr.getBoundingClientRect(),

						// for the proper top offset
						angular.element(scope.tr).offset()
					);

				},

				setStuck: function (bool) {

					scope.$apply(function(){
						scope.stuck = !!bool;
					});

				},

				toggleClone: ifClone(function (bool) {

					scope.clone[(!!bool ? 'add' : 'remove') + 'Class'](options.stuckClassName);

				}),

				sizeClone: ifClone(function () {

					scope.setOffset();
					scope.setClonedCellWidths();
					scope.setCloneGutter();

				}),

				checkScroll: ifClone(function() {

					var scrollY = $window.scrollY;

					if (!scope.stuck && scrollY >= scope.offset.top) {
						scope.setClonedCellWidths();
						scope.setStuck(true);
					} else if (scope.stuck && scrollY < scope.offset.top) {
						scope.setStuck(false);
					} else if ($window.scrollX) {

						scope.clone.css('left', scope.offset.left - $window.scrollX);

					}

				}),

				observeTr: function () {

					scope.mutationObserver = watchDom.$watch(
						scope.tr,
						_.throttle(scope.resetClone, options.observeHeaderInterval),
						{ subtree: true }
					);

				},

				rowsChanged: function () {

					$timeout(function(){
						scope.setOffset();
						scope.checkScroll();
					});

				},

				on: function () {

					scope.observeTr();
					scope.addEvents();

				},

				off: function () {

					scope.mutationObserver();
					scope.removeEvents();
					scope.removeClones();

				},

				addEvents: function () {

					scope.windowEvents = {
						scroll: scope.checkScroll,
						resize: scope.sizeClone
					};

					angular
						.element($window)
						.on(scope.windowEvents);

				},

				removeEvents: function () {

					if (!scope.windowEvents.resize || !scope.windowEvents.scroll) {
						return;
					}

					angular
						.element($window)
						.off(scope.windowEvents);

					scope.windowEvents = {};
					
				},

				changeDisabled: function (disabled, old) {

					if (disabled === old) {
						return;
					}

					if (disabled) {
						scope.off();
					} else {
						scope.on();
						scope.resetClone();
						scope.toggleClone(false);
					}

				}

			});

			// enable/disable api
			scope.$watch('disabled', scope.changeDisabled);
			
			// watch rows, and re-measure column widths when they change
			scope.$watch('rows', scope.rowsChanged);

			// fired when stuck state changes
			scope.$watch('stuck', scope.toggleClone);

			// teardown
			scope.$on('$destroy', scope.off);

			// init
			scope.on();

			// helpers
			function ifClone (fn) {
				return util.guard(fn, cloneExists);
			}

			function cloneExists () {
				return scope.clone;
			}
			

		}
	};

});
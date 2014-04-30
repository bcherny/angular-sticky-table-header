angular
.module('angularStickyTableHeader', [])
.value('options', {
	cloneClassName: 'sticky-clone',
	className: 'sticky-stuck',
	interval: 10
})
.directive('stickyTableHeader', function ($interval, $timeout, $window, options) {

	return {
		restrict: 'A',
		link: function (scope, element, attrs) {

			var clearStuckWatch, interval, topOffset;

			angular.extend(scope, {

				clone: null,
				isStuck: false,

				removeClones: function () {

					scope.isStuck = false;

					element
						.find('.' + options.cloneClassName)
						.remove();

				},

				doClone: function () {

					return $(element.find('tr')[0])
						.clone()
						.addClass(options.cloneClassName)
						.appendTo(element.find('thead'));

				},

				setClonedCellWidths: function () {

					if (!scope.clone) {
						return;
					}

					var thClones = scope.clone.find('th');

					angular.forEach(element.find('th'), function(th, n) {
						$(thClones[n]).css('width', $(th).css('width'));
					});
				},

				setTopOffset: function () {

					topOffset = element.find('tr')[1].getBoundingClientRect().top;

				},

				setStuck: function (bool) {

					scope.isStuck = !!bool;

				},

				toggleClone: function (bool) {

					if (!scope.clone) {
						return;
					}

					scope.clone[(bool ? 'add' : 'remove') + 'Class'](options.className);
				},

				sizeClone: function () {

					if (!scope.clone) {
						return;
					}

					scope.setTopOffset();
					scope.setClonedCellWidths();

				},

				checkScroll: function() {

					var scroll = $window.scrollY;

					if (!scope.isStuck && scroll >= topOffset) {
						scope.setStuck(true);
					} else if (scope.isStuck && scroll < topOffset) {
						scope.setStuck(false);
					}

				}

			});
			
			// watch columns, regenerate cloned row when they change
			scope.$watch(function(){
				return scope[attrs.columns];
			}, $timeout.bind(null, function(){

				scope.removeClones();
				scope.clone = scope.doClone();

				// poll for scroll position (avoid using listeners because they will
				// bog down the scroll event)
				if (interval) {
					$interval.clear(interval);
				}
				interval = $interval(scope.checkScroll, options.interval);

			}));
			
			// watch rows, and re-measure column widths when they change
			scope.$watch(function(){
				return scope[attrs.rows];
			}, scope.setClonedCellWidths);

			// fired when a clone is created
			scope.$watch('clone', scope.sizeClone);

			// fired when stuck state changes
			scope.$watch('isStuck', scope.toggleClone);

			// listen on window resize event
			angular.element($window).on('resize', _.debounce(scope.setClonedCellWidths.bind(scope), options.interval));

		}
	};

});
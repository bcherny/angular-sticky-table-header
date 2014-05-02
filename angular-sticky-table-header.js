angular
.module('stickyTableHeader', [])
.value('options', {
	cloneClassName: 'sticky-clone',
	stuckClassName: 'sticky-stuck',
	interval: 10
})
.service('util', function() {
			
	this.guard = function (fn, condition) {
		return function(){
			return condition() ? fn.apply(this, arguments) : false;
		};
	};

})
.directive('stickyTableHeader', function ($timeout, $window, options, util) {

	return {
		restrict: 'A',
		link: function (scope, element, attrs) {

			angular.extend(scope, {

				clone: null,
				isStuck: false,
				offset: {},

				doClone: function () {

					return $(element.find('tr')[0])
						.clone()
						.addClass(options.cloneClassName)
						.appendTo(element.find('thead'));

				},

				removeClones: function () {

					scope.isStuck = false;

					element
						.find('.' + options.cloneClassName)
						.remove();

				},

				setClonedCellWidths: ifClone(function () {

					var thClones = scope.clone.find('th');

					angular.forEach(element.find('th'), function(th, n) {
						$(thClones[n]).css('width', $(th).css('width'));
					});

				}),

				setCloneGutter: ifClone(function () {

					scope.clone.css({
						left: scope.offset.left,
						right: scope.offset.right
					});

				}),

				setOffset: function () {

					scope.offset = element
						.find('tr')[0]
						.getBoundingClientRect();

				},

				setStuck: function (bool) {

					scope.$apply(function(){
						scope.isStuck = !!bool;
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

					var scroll = $window.scrollY;

					if (!scope.isStuck && scroll >= scope.offset.top) {
						scope.setStuck(true);
					} else if (scope.isStuck && scroll < scope.offset.top) {
						scope.setStuck(false);
					}

				})

			});
			
			// watch columns, regenerate cloned row when they change
			if (attrs.columns) {
				scope.$watch(function(){
					return scope[attrs.columns];
				}, $timeout.bind(null, function(){

					scope.removeClones();
					scope.clone = scope.doClone();

				}));
			}
			
			// watch rows, and re-measure column widths when they change
			if (attrs.rows) {
				scope.$watch(function(){
					return scope[attrs.rows];
				}, scope.setClonedCellWidths);
			}

			// fired when a clone is created
			scope.$watch('clone', scope.sizeClone);

			// fired when stuck state changes
			scope.$watch('isStuck', scope.toggleClone);

			// fired when the offset is re-measured
			scope.$watch('offset.left', scope.sizeClone);

			// listen on window resize event
			angular.element($window).on({
				resize: _.debounce(scope.setClonedCellWidths.bind(scope), options.interval),
				scroll: _.debounce(scope.checkScroll.bind(scope), options.interval)
			});


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
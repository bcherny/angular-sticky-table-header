angular.module('watchDom', []).constant('watchDomOptions', {
  attributes: true,
  characterData: true,
  childList: true
}).service('watchDom', [
  '$window',
  'watchDomOptions',
  function ($window, watchDomOptions) {
    this.$watch = function (element, cb, options) {
      if (!angular.isElement(element)) {
        throw new TypeError('watchDom expects its 1st argument to be a DOMElement, but was given ', element);
      }
      if (!angular.isFunction(cb)) {
        throw new TypeError('watchDom expects its 2nd argument to be a Function, but was given ', cb);
      }
      var mutationObserver = new $window.MutationObserver(function (mutationRecord) {
          cb(mutationRecord, mutationRecord.oldValue);
        });
      mutationObserver.observe(element, angular.extend({}, watchDomOptions, options));
      return mutationObserver.disconnect;
    };
  }
]);
angular.module('turn/stickyTableHeader', ['watchDom']).value('stickyTableHeaderOptions', {
  cloneClassName: 'sticky-clone',
  stuckClassName: 'sticky-stuck',
  interval: 10,
  observeHeaderInterval: 100
}).service('stickyTableHeaderUtil', function () {
  this.guard = function (fn, condition) {
    return function () {
      return condition() ? fn.apply(this, arguments) : false;
    };
  };
}).directive('stickyTableHeader', [
  '$timeout',
  '$window',
  'stickyTableHeaderOptions',
  'stickyTableHeaderUtil',
  'watchDom',
  function ($timeout, $window, stickyTableHeaderOptions, stickyTableHeaderUtil, watchDom) {
    var options = stickyTableHeaderOptions, util = stickyTableHeaderUtil;
    return {
      restrict: 'A',
      link: function (scope, element, attrs) {
        angular.extend(scope, {
          isStuck: false,
          mutationObserver: null,
          offset: {},
          tr: element.find('tr')[0],
          clone: null,
          createClone: function () {
            return angular.element(scope.tr).clone(true, true).addClass(options.cloneClassName).appendTo(element.find('thead'));
          },
          resetClone: _.debounce(function () {
            scope.removeClones();
            scope.clone = scope.createClone();
            scope.sizeClone();
          }, 200),
          removeClones: function () {
            scope.isStuck = false;
            element.find('.' + options.cloneClassName).remove();
          },
          setClonedCellWidths: ifClone(function () {
            var thClones = scope.clone.find('th');
            angular.forEach(element.find('th'), function (th, n) {
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
            scope.offset = scope.tr.getBoundingClientRect();
          },
          setStuck: function (bool) {
            scope.$apply(function () {
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
          checkScroll: ifClone(function () {
            var scroll = $window.scrollY;
            if (!scope.isStuck && scroll >= scope.offset.top) {
              scope.setClonedCellWidths();
              scope.setStuck(true);
            } else if (scope.isStuck && scroll < scope.offset.top) {
              scope.setStuck(false);
            }
          }),
          observeTr: function () {
            scope.mutationObserver = watchDom.$watch(scope.tr, _.throttle(scope.resetClone, options.observeHeaderInterval), { subtree: true });
          }
        });
        // watch rows, and re-measure column widths when they change
        if (attrs.rows) {
          scope.$watch(function () {
            return scope[attrs.rows];
          }, $timeout.bind(null, scope.setClonedCellWidths));
        }
        // fired when stuck state changes
        scope.$watch('isStuck', scope.toggleClone);
        // start observing header for DOM changes
        scope.observeTr();
        // listen on window resize event
        angular.element($window).on({
          'resize.angularStickyTableHeader': _.debounce(scope.setClonedCellWidths.bind(scope), options.interval),
          'scroll.angularStickyTableHeader': _.debounce(scope.checkScroll.bind(scope), options.interval)
        });
        // teardown
        scope.$on('$destroy', function () {
          angular.element($window).off('.angularStickyTableHeader');
          scope.mutationObserver();
        });
        // helpers
        function ifClone(fn) {
          return util.guard(fn, cloneExists);
        }
        function cloneExists() {
          return scope.clone;
        }
      }
    };
  }
]);
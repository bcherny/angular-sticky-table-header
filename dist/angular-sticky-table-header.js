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
      return mutationObserver.disconnect.bind(mutationObserver);
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
      scope: {
        disabled: '=',
        rows: '='
      },
      template: '<div ng-transclude></div>',
      transclude: true,
      link: function (scope, element) {
        angular.extend(scope, {
          stuck: false,
          mutationObserver: null,
          offset: {},
          tr: element.find('tr')[0],
          clone: null,
          windowEvents: {},
          createClone: function () {
            return angular.element(scope.tr).clone(true, true).addClass(options.cloneClassName).appendTo(element.find('thead'));
          },
          resetClone: _.debounce(function () {
            scope.removeClones();
            scope.clone = scope.createClone();
            $timeout(scope.sizeClone);
          }, 200),
          removeClones: function () {
            scope.stuck = false;
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
              width: scope.offset.width
            });
          }),
          setOffset: function () {
            scope.offset = angular.extend({}, scope.tr.getBoundingClientRect(), angular.element(scope.tr).offset());
          },
          setStuck: function (bool) {
            scope.$apply(function () {
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
          checkScroll: ifClone(function () {
            var scroll = $window.scrollY;
            if (!scope.stuck && scroll >= scope.offset.top) {
              scope.setClonedCellWidths();
              scope.setStuck(true);
            } else if (scope.stuck && scroll < scope.offset.top) {
              scope.setStuck(false);
            }
          }),
          observeTr: function () {
            scope.mutationObserver = watchDom.$watch(scope.tr, _.throttle(scope.resetClone, options.observeHeaderInterval), { subtree: true });
          },
          rowsChanged: function () {
            $timeout(function () {
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
              scroll: _.debounce(scope.checkScroll.bind(scope), options.interval),
              resize: scope.sizeClone
            };
            angular.element($window).on(scope.windowEvents);
          },
          removeEvents: function () {
            if (!scope.windowEvents.resize || !scope.windowEvents.scroll) {
              return;
            }
            angular.element($window).off(scope.windowEvents);
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
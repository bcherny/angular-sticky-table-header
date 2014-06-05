// Generated by CoffeeScript 1.7.1
describe('angular-sticky-table-header', function() {
  var $window, options;
  options = {
    cloneClassName: 'sticky-clone',
    stuckClassName: 'sticky-stuck',
    interval: 10
  };
  window._ = {
    debounce: function(fn) {
      return fn;
    },
    throttle: function(fn) {
      return fn;
    }
  };
  $window = {
    scrollY: 0,
    on: function() {},
    off: function() {}
  };
  beforeEach(module('turn/stickyTableHeader'), function($provide) {
    $provide.value('options', options);
    $provide.value('$window', $window);
    return null;
  });
  beforeEach(function() {
    return inject((function(_this) {
      return function($compile, $rootScope) {
        _this.scope = $rootScope.$new();
        angular.extend(_this.scope, {
          columnCollection: ['foo', 'bar', 'baz'],
          rowCollection: (Array.apply(null, Array(200))).map(function() {
            return ['moo', 'woo', 'zoo'];
          })
        });
        _this.element = angular.element("<div sticky-table-header rows=\"rowCollection\">\n\n	<table class=\"table\">\n		<thead>\n			<tr>\n				<th ng-repeat=\"th in columnCollection\">{{th}}</th>\n			</tr>\n		</thead>\n		<tbody>\n			<tr ng-repeat=\"tr in rowCollection\">\n				<td ng-repeat=\"td in tr\">{{td}}</td>\n			</tr>\n		</tbody>\n	</table>\n\n</div>");
        ($compile(_this.element))(_this.scope);
        _this.scope.$digest();
        _this.scope = _this.element.scope();
        return $window = {
          scrollY: 0,
          on: function() {},
          off: function() {}
        };
      };
    })(this));
  });
  describe('#createClone', function() {
    it('should clone the first <tr> it finds and append it to the <thead>', function() {
      expect((this.element.find('thead tr')).length).toBe(1);
      this.scope.createClone();
      return expect((this.element.find('thead tr')).length).toBe(2);
    });
    it('should clone the <tr>\'s contents', function() {
      this.scope.createClone();
      return expect(($((this.element.find('thead tr'))[1]).find('th')).length).toBe(this.scope.$parent.columnCollection.length);
    });
    it('should clone the <tr>\'s events', function() {
      var clone, mock;
      mock = {
        fn: function() {}
      };
      spyOn(mock, 'fn');
      $((this.element.find('thead tr'))[0]).find('th').on('click', mock.fn);
      clone = this.scope.createClone();
      $((this.element.find('thead tr'))[1]).find('th').click();
      return expect(mock.fn).toHaveBeenCalled();
    });
    it('should mirror the original <tr>\'s className', function() {
      this.element.find('thead tr').addClass('test');
      this.scope.createClone();
      return expect($((this.element.find('thead tr'))[1]).hasClass('test')).toBe(true);
    });
    return it('should assign the clone the className defined in options.cloneClassName', function() {
      this.scope.createClone();
      return expect($((this.element.find('thead tr'))[1]).hasClass(options.cloneClassName)).toBe(true);
    });
  });
  describe('#resetClone', function() {
    it('should call #removeClones, #createClone, and #sizeClone', function() {
      spyOn(this.scope, 'removeClones');
      spyOn(this.scope, 'createClone');
      spyOn(this.scope, 'sizeClone');
      this.scope.resetClone();
      expect(this.scope.removeClones).toHaveBeenCalled();
      expect(this.scope.createClone).toHaveBeenCalled();
      return expect(this.scope.sizeClone).toHaveBeenCalled();
    });
    return it('should set scope.clone to the value returned by #createClone', function() {
      this.scope.clone = null;
      this.scope.removeClones = function() {};
      this.scope.createClone = function() {
        return 42;
      };
      this.scope.sizeClone = function() {};
      this.scope.resetClone();
      return expect(this.scope.clone).toBe(42);
    });
  });
  describe('#removeClones', function() {
    it('should set scope.stuck to false', function() {
      this.scope.createClone();
      this.scope.removeClones();
      return expect(this.scope.stuck).toBe(false);
    });
    return it('should remove all <tr> clones', function() {
      this.scope.createClone();
      this.scope.createClone();
      this.scope.createClone();
      expect((this.element.find('.' + options.cloneClassName)).length).toBe(3);
      this.scope.removeClones();
      return expect((this.element.find('.' + options.cloneClassName)).length).toBe(0);
    });
  });
  describe('#setCloneGutter', function() {
    return it('should set the <th> clone\'s left and right CSS equal to scope.offset', function() {
      this.scope.clone = {
        css: function() {}
      };
      this.scope.offset = {
        left: 1,
        right: 2
      };
      spyOn(this.scope.clone, 'css');
      this.scope.setCloneGutter();
      return expect(this.scope.clone.css).toHaveBeenCalledWith(this.scope.offset);
    });
  });
  describe('#setOffset', function() {
    it('should call getOffset on the first <tr>', function() {
      spyOn(($()).__proto__, 'offset');
      this.scope.setOffset();
      return expect(($()).__proto__.offset).toHaveBeenCalled();
    });
    return it('should set scope.offset equal to the value returned by getBoundingClientRect', function() {
      this.scope.offset = null;
      spyOn(($()).__proto__, 'offset').andReturn('foo');
      this.scope.setOffset();
      return expect(this.scope.offset).toEqual('foo');
    });
  });
  describe('#setStuck', function() {
    it('should set scope.stuck equal to the boolean passed into it', function() {
      this.scope.stuck = null;
      this.scope.setStuck(true);
      return expect(this.scope.stuck).toBe(true);
    });
    return it('should coerce non-boolean values into booleans', function() {
      this.scope.setStuck(true);
      expect(this.scope.stuck).toBe(true);
      this.scope.setStuck('foo');
      expect(this.scope.stuck).toBe(true);
      this.scope.setStuck(42);
      expect(this.scope.stuck).toBe(true);
      this.scope.setStuck(null);
      expect(this.scope.stuck).toBe(false);
      this.scope.setStuck(0);
      expect(this.scope.stuck).toBe(false);
      this.scope.setStuck(false);
      return expect(this.scope.stuck).toBe(false);
    });
  });
  describe('#toggleClone', function() {
    it('should toggle options.stuckClassName on the clone', function() {
      this.scope.clone = {
        addClass: function() {},
        removeClass: function() {}
      };
      spyOn(this.scope.clone, 'addClass');
      spyOn(this.scope.clone, 'removeClass');
      this.scope.toggleClone(true);
      expect(this.scope.clone.addClass).toHaveBeenCalledWith(options.stuckClassName);
      this.scope.toggleClone(false);
      return expect(this.scope.clone.removeClass).toHaveBeenCalledWith(options.stuckClassName);
    });
    return it('should coerce non-boolean values into booleans', function() {
      this.scope.clone = {
        addClass: function() {},
        removeClass: function() {}
      };
      spyOn(this.scope.clone, 'addClass');
      spyOn(this.scope.clone, 'removeClass');
      this.scope.toggleClone(1);
      expect(this.scope.clone.addClass).toHaveBeenCalledWith(options.stuckClassName);
      this.scope.toggleClone(0);
      return expect(this.scope.clone.removeClass).toHaveBeenCalledWith(options.stuckClassName);
    });
  });
  describe('#sizeClone', function() {
    return it('should call #setOffset, #setClonedCellWidths, and #setClonedCellWidths', function() {
      this.scope.clone = true;
      this.scope.setClonedCellWidths = function() {};
      this.scope.setCloneGutter = function() {};
      this.scope.setOffset = function() {};
      spyOn(this.scope, 'setClonedCellWidths');
      spyOn(this.scope, 'setCloneGutter');
      spyOn(this.scope, 'setOffset');
      this.scope.sizeClone();
      expect(this.scope.setOffset).toHaveBeenCalled();
      expect(this.scope.setClonedCellWidths).toHaveBeenCalled();
      return expect(this.scope.setCloneGutter).toHaveBeenCalled();
    });
  });
  describe('#checkScroll', function() {
    beforeEach(function() {
      spyOn(this.scope, 'setStuck');
      return spyOn(this.scope, 'setClonedCellWidths').andCallFake(function() {});
    });
    it('should call #setStuck with true and #setClonedCellWidths with no arguments when scope.stuck is false and scrollY is >= offset.top', function() {
      this.scope.clone = true;
      this.scope.stuck = false;
      this.scope.offset = {
        top: 0
      };
      $window.scrollY = 1;
      this.scope.checkScroll();
      expect(this.scope.setStuck).toHaveBeenCalledWith(true);
      return expect(this.scope.setClonedCellWidths).toHaveBeenCalled();
    });
    it('should call #setStuck with false when scope.stuck is true and scrollY is < offset.top', function() {
      this.scope.clone = true;
      this.scope.stuck = true;
      this.scope.offset = {
        top: 1
      };
      $window.scrollY = 0;
      this.scope.checkScroll();
      return expect(this.scope.setStuck).toHaveBeenCalledWith(false);
    });
    return it('should not call #setStuck otherwise', function() {
      this.scope.clone = true;
      this.scope.stuck = true;
      this.scope.offset = {
        top: 0
      };
      $window.scrollY = 1;
      this.scope.checkScroll();
      this.scope.stuck = false;
      this.scope.offset = {
        top: 1
      };
      $window.scrollY = 0;
      this.scope.checkScroll();
      return expect(this.scope.setStuck).not.toHaveBeenCalled();
    });
  });
  describe('#rowsChanged', function() {
    return it('should call #checkScroll and #setClonedCellWidths after a $timeout', inject(function($timeout) {
      spyOn(this.scope, 'checkScroll');
      spyOn(this.scope, 'setClonedCellWidths');
      this.scope.rowsChanged();
      $timeout.flush();
      expect(this.scope.checkScroll).toHaveBeenCalled();
      return expect(this.scope.setClonedCellWidths).toHaveBeenCalled();
    }));
  });
  describe('#on', function() {
    return it('should call #observeTr and #addEvents with no arguments', function() {
      spyOn(this.scope, 'observeTr');
      spyOn(this.scope, 'addEvents');
      this.scope.on();
      expect(this.scope.observeTr).toHaveBeenCalledWith;
      return expect(this.scope.addEvents).toHaveBeenCalledWith;
    });
  });
  describe('#off', function() {
    return it('should call #mutationObserver, #removeEvents, and #removeClones with no arguments', function() {
      this.scope.mutationObserver = function() {};
      spyOn(this.scope, 'mutationObserver');
      spyOn(this.scope, 'removeEvents');
      spyOn(this.scope, 'removeClones');
      this.scope.off();
      expect(this.scope.mutationObserver).toHaveBeenCalledWith;
      expect(this.scope.removeEvents).toHaveBeenCalledWith;
      return expect(this.scope.removeClones).toHaveBeenCalledWith;
    });
  });
  describe('#changeDisabled', function() {
    it('shouldn\'t call anything if the 1st argument is identical to the 2nd argument', function() {
      spyOn(this.scope, 'on');
      spyOn(this.scope, 'off');
      spyOn(this.scope, 'resetClone');
      this.scope.changeDisabled(true, true);
      expect(this.scope.on).not.toHaveBeenCalled();
      expect(this.scope.off).not.toHaveBeenCalled();
      return expect(this.scope.resetClone).not.toHaveBeenCalled();
    });
    it('should call #off with no arguments if the 1st argument is truthy', function() {
      spyOn(this.scope, 'off');
      this.scope.changeDisabled(true);
      return expect(this.scope.off).toHaveBeenCalledWith;
    });
    return it('should call #on and #resetClone with no arguments if the 1st argument is truthy', function() {
      spyOn(this.scope, 'on');
      spyOn(this.scope, 'resetClone');
      this.scope.changeDisabled(false);
      expect(this.scope.on).toHaveBeenCalledWith;
      return expect(this.scope.resetClone).toHaveBeenCalledWith;
    });
  });
  describe('$destroy', function() {
    return it('should call #off with no arguments', function() {
      this.scope.mutationObserver = function() {};
      spyOn(this.scope, 'off');
      this.scope.$destroy();
      return expect(this.scope.off).toHaveBeenCalledWith;
    });
  });
  return describe('$watches', function() {
    it('should call #changeDisabled when scope.disabled changes', inject(function($timeout) {
      spyOn(this.scope, 'changeDisabled');
      this.element.attr('disabled', 'foo');
      this.scope.$apply();
      return $timeout(function() {
        return expect(this.scope.changeDisabled).toHaveBeenCalled();
      });
    }));
    it('should call #rowsChanged when scope.rows changes', inject(function($timeout) {
      spyOn(this.scope, 'rowsChanged');
      this.element.attr('rows', 'foo');
      this.scope.$apply();
      return $timeout(function() {
        return expect(this.scope.rowsChanged).toHaveBeenCalled();
      });
    }));
    return it('should call #toggleClone when scope.stuck changes', inject(function($timeout) {
      spyOn(this.scope, 'toggleClone');
      this.element.attr('stuck', 'foo');
      this.scope.$apply();
      return $timeout(function() {
        return expect(this.scope.toggleClone).toHaveBeenCalled();
      });
    }));
  });
});

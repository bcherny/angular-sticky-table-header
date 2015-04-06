describe 'angular-sticky-table-header', ->

	options =
		cloneClassName: 'sticky-clone'
		stuckClassName: 'sticky-stuck'
		interval: 10

	window._ =
		debounce: (fn) -> fn
		throttle: (fn) -> fn

	$window =
		scrollX: 0
		scrollY: 0
		on: ->
		off: ->

	beforeEach (module 'turn/stickyTableHeader'), ($provide) ->
		
		$provide.value 'options', options
		$provide.value '$window', $window

		null
	
	beforeEach ->
		
		inject ($compile, $rootScope) =>

			@scope = do $rootScope.$new

			angular.extend @scope,
				columnCollection: ['foo', 'bar', 'baz']
				rowCollection: (Array.apply null, Array 200).map -> ['moo', 'woo', 'zoo']

			@element = angular.element """
				<div sticky-table-header rows="rowCollection">

					<table class="table">
						<thead>
							<tr>
								<th ng-repeat="th in columnCollection">{{th}}</th>
							</tr>
						</thead>
						<tbody>
							<tr ng-repeat="tr in rowCollection">
								<td ng-repeat="td in tr">{{td}}</td>
							</tr>
						</tbody>
					</table>

				</div>
			"""

			($compile @element) @scope
			do @scope.$digest
			@scope = do @element.scope

			$window =
				scrollY: 0
				on: ->
				off: ->


	#########################################


	describe '#createClone', ->

		it 'should clone the first <tr> it finds and append it to the <thead>', ->

			expect (@element.find 'thead tr').length
			.toBe 1

			do @scope.createClone

			expect (@element.find 'thead tr').length
			.toBe 2

		it 'should clone the <tr>\'s contents', ->

			do @scope.createClone

			expect ($((@element.find 'thead tr')[1]).find 'th').length
			.toBe @scope.$parent.columnCollection.length

		it 'should clone the <tr>\'s events', ->

			mock =
				fn: ->

			spyOn mock, 'fn'

			$ (@element.find 'thead tr')[0]
			.find 'th'
			.on 'click', mock.fn

			clone = do @scope.createClone

			$ (@element.find 'thead tr')[1]
			.find 'th'
			.click()

			expect mock.fn
			.toHaveBeenCalled()

		it 'should mirror the original <tr>\'s className', ->

			@element.find 'thead tr'
			.addClass 'test'

			do @scope.createClone

			expect $((@element.find 'thead tr')[1]).hasClass 'test'
			.toBe true

		it 'should assign the clone the className defined in options.cloneClassName', ->

			do @scope.createClone

			expect $((@element.find 'thead tr')[1]).hasClass options.cloneClassName
			.toBe true


	describe '#resetClone', ->

		it 'should call #removeClones, #createClone, and #sizeClone', inject ($timeout) ->

			spyOn @scope, 'removeClones'
			spyOn @scope, 'createClone'
			spyOn @scope, 'sizeClone'

			do @scope.resetClone

			do $timeout.flush

			expect @scope.removeClones
			.toHaveBeenCalled()

			expect @scope.createClone
			.toHaveBeenCalled()

			expect @scope.sizeClone
			.toHaveBeenCalled()

		it 'should set scope.clone to the value returned by #createClone', ->

			@scope.clone = null
			@scope.removeClones = ->
			@scope.createClone = -> 42
			@scope.sizeClone = ->

			do @scope.resetClone

			expect @scope.clone
			.toBe 42
 

	describe '#removeClones', ->

		it 'should set scope.stuck to false', ->

			do @scope.createClone
			do @scope.removeClones

			expect @scope.stuck
			.toBe false

		it 'should remove all <tr> clones', ->

			do @scope.createClone
			do @scope.createClone
			do @scope.createClone

			expect (@element.find '.' + options.cloneClassName).length
			.toBe 3

			do @scope.removeClones

			expect (@element.find '.' + options.cloneClassName).length
			.toBe 0


	# TODO: add tests for #setClonedCellWidths


	describe '#setCloneGutter', ->

		it 'should set the <th> clone\'s width CSS equal to scope.offset', ->

			@scope.clone =
				css: ->
			@scope.offset =
				width: 2

			spyOn @scope.clone, 'css'

			do @scope.setCloneGutter

			expect @scope.clone.css
			.toHaveBeenCalledWith @scope.offset


	describe '#setOffset', ->

		table = null

		beforeEach ->

			table = (@element.find 'table').get 0

			spyOn table, 'getBoundingClientRect'
			.andReturn
				width: 'bar'
				top: 'zoo'

			spyOn (do $).__proto__, 'offset'
			.andReturn
				width: 'woo'
				top: 'moo'

			@scope.offset = null

			do @scope.setOffset

		it 'should call getBoundingClientRect on the first <tr>', ->

			do expect table.getBoundingClientRect
			.toHaveBeenCalledWith

		it 'should call $.offset on the first <tr>', ->

			do expect (do $).__proto__.offset
			.toHaveBeenCalledWith

		it 'should set scope.offset equal to the width returned by getBoundingClientRect and the top returned by $.offset', ->

			expect @scope.offset
			.toEqual
				width: 'bar'
				top: 'moo'


	describe '#setStuck', ->

		it 'should set scope.stuck equal to the boolean passed into it', ->

			@scope.stuck = null
			@scope.setStuck true

			expect @scope.stuck
			.toBe true

		it 'should coerce non-boolean values into booleans', ->

			@scope.setStuck true
			expect @scope.stuck
			.toBe true

			@scope.setStuck 'foo'
			expect @scope.stuck
			.toBe true

			@scope.setStuck 42
			expect @scope.stuck
			.toBe true

			@scope.setStuck null
			expect @scope.stuck
			.toBe false

			@scope.setStuck 0
			expect @scope.stuck
			.toBe false

			@scope.setStuck false
			expect @scope.stuck
			.toBe false

		it 'should call #toggleClone', ->

			spyOn @scope, 'toggleClone'

			@scope.setStuck true

			expect @scope.toggleClone
			.toHaveBeenCalledWith true

			@scope.setStuck false

			expect @scope.toggleClone
			.toHaveBeenCalledWith false


	describe '#toggleClone', ->

		it 'should toggle options.stuckClassName on the clone', ->

			@scope.clone =
				addClass: ->
				removeClass: ->

			spyOn @scope.clone, 'addClass'
			spyOn @scope.clone, 'removeClass'

			@scope.toggleClone true
			expect @scope.clone.addClass
			.toHaveBeenCalledWith options.stuckClassName

			@scope.toggleClone false
			expect @scope.clone.removeClass
			.toHaveBeenCalledWith options.stuckClassName

		it 'should coerce non-boolean values into booleans', ->

			@scope.clone =
				addClass: ->
				removeClass: ->

			spyOn @scope.clone, 'addClass'
			spyOn @scope.clone, 'removeClass'

			@scope.toggleClone 1
			expect @scope.clone.addClass
			.toHaveBeenCalledWith options.stuckClassName

			@scope.toggleClone 0
			expect @scope.clone.removeClass
			.toHaveBeenCalledWith options.stuckClassName


	describe '#sizeClone', ->

		it 'should call #setOffset, #setClonedCellWidths, #setClonedCellWidths, and #checkScroll with no arguments', ->

			@scope.clone = true
			@scope.setClonedCellWidths = ->
			@scope.setCloneGutter = ->
			@scope.setOffset = ->
			@scope.checkScroll = ->

			spyOn @scope, 'setClonedCellWidths'
			spyOn @scope, 'setCloneGutter'
			spyOn @scope, 'setOffset'
			spyOn @scope, 'checkScroll'

			do @scope.sizeClone

			expect @scope.setOffset
			.toHaveBeenCalledWith

			expect @scope.setClonedCellWidths
			.toHaveBeenCalledWith

			expect @scope.setCloneGutter
			.toHaveBeenCalledWith

			expect @scope.checkScroll
			.toHaveBeenCalledWith


	describe '#checkScroll', ->

		beforeEach ->

			spyOn @scope, 'setStuck'
			spyOn @scope, 'setClonedCellWidths'
			.andCallFake ->

		[
			{ elementScrollY: 0, windowScrollY: 0 }
			{ elementScrollY: 0, windowScrollY: 1 }
			{ elementScrollY: 1, windowScrollY: 0 }
			{ elementScrollY: 1, windowScrollY: 1 }
			{ elementScrollY: 2, windowScrollY: -1 }
			{ elementScrollY: -1, windowScrollY: 2 }
		].forEach (data) ->

			it 'should call #setStuck with true and #setClonedCellWidths with no arguments when scope.stuck is false and scrollY is >= offset.top', ->

				spyOn @element, 'scrollTop'
				.andReturn data.elementScrollY

				@scope.clone = css: ->
				@scope.stuck = false
				@scope.offset = top: 0
				$window.scrollY = data.windowScrollY

				do @scope.checkScroll

				expect @scope.setStuck
				.toHaveBeenCalledWith true

				do expect @scope.setClonedCellWidths
				.toHaveBeenCalled

		[
			{ elementScrollY: 0, windowScrollY: 0 }
			{ elementScrollY: 0, windowScrollY: -1 }
			{ elementScrollY: -1, windowScrollY: 0 }
		].forEach (data) ->

			it 'should call #setStuck with false when scope.stuck is true and scrollY is < offset.top', ->

				spyOn @element, 'scrollTop'
				.andReturn data.elementScrollY

				@scope.clone = css: ->
				@scope.stuck = true
				@scope.offset = top: 1
				$window.scrollY = data.windowScrollY

				do @scope.checkScroll

				expect @scope.setStuck
				.toHaveBeenCalledWith false

		it 'should not call #setStuck otherwise', ->

			# stuck = true, scrollY >= offset
			@scope.clone = css: ->
			@scope.stuck = true
			@scope.offset = top: 0
			$window.scrollY = 1

			do @scope.checkScroll

			# stuck = false, scrollY < offset
			@scope.stuck = false
			@scope.offset = top: 1
			$window.scrollY = 0

			do @scope.checkScroll

			do expect @scope.setStuck
			.not.toHaveBeenCalled


		it 'should set top', ->

			@scope.clone = css: ->
			spyOn @scope.clone, 'css'

			do @scope.checkScroll

			expect @scope.clone.css
			.toHaveBeenCalledWith 'top', jasmine.any(Number)


	describe '#rowsChanged', ->

		it 'should call #sizeClone with no arguments after a $timeout', inject ($timeout) ->

			spyOn @scope, 'sizeClone'

			do @scope.rowsChanged

			do $timeout.flush

			expect @scope.sizeClone
			.toHaveBeenCalledWith


	describe '#on', ->

		it 'should call #observeTr and #addEvents with no arguments', ->

			spyOn @scope, 'observeTr'
			spyOn @scope, 'addEvents'

			do @scope.on

			expect @scope.observeTr
			.toHaveBeenCalledWith

			expect @scope.addEvents
			.toHaveBeenCalledWith


	describe '#off', ->

		it 'should call #mutationObserver, #removeEvents, and #removeClones with no arguments', ->

			@scope.mutationObserver = ->

			spyOn @scope, 'mutationObserver'
			spyOn @scope, 'removeEvents'
			spyOn @scope, 'removeClones'

			do @scope.off

			expect @scope.mutationObserver
			.toHaveBeenCalledWith

			expect @scope.removeEvents
			.toHaveBeenCalledWith

			expect @scope.removeClones
			.toHaveBeenCalledWith


	describe '#addEvents', ->

		it 'should store resize and scroll events on scope.windowEvents', ->

			@scope.windowEvents = null

			do @scope.addEvents

			expect @scope.windowEvents.resize
			.toBe @scope.sizeClone

			expect @scope.windowEvents.scroll
			.toBe @scope.checkScroll

		it 'should store the scroll event on scope.elementEvents', ->

			@scope.elementEvents = null

			do @scope.addEvents

			expect @scope.elementEvents.scroll
			.toBe @scope.checkScroll

		it 'should bind windowEvents to the $window', inject ($window) ->

			spyOn (do $).__proto__, 'on'

			do spyOn angular, 'element'
			.andCallThrough

			do @scope.addEvents

			expect angular.element
			.toHaveBeenCalledWith $window

			expect (do $).__proto__.on
			.toHaveBeenCalledWith @scope.windowEvents

		it 'should bind elementEvents to the element', ->

			spyOn (do $).__proto__, 'on'

			do @scope.addEvents

			expect (do $).__proto__.on
			.toHaveBeenCalledWith @scope.elementEvents


	describe '#removeEvents', ->

		it 'should not reset scope.windowEvents or unbind events from the $window if windowEvents.resize, windowEvents.scroll, or elementEvents.scroll are falsey', ->

			spyOn (do $).__proto__, 'on'

			[
				{
					elementEvents: scroll: null
					windowEvents: resize: null, scroll: null
				}
				{
					elementEvents: scroll: true
					windowEvents: resize: null, scroll: null
				}
				{
					elementEvents: scroll: null
					windowEvents: resize: true, scroll: null
				}
				{
					elementEvents: scroll: null
					windowEvents: resize: null, scroll: true
				}
				{
					elementEvents: scroll: true
					windowEvents: resize: true, scroll: null
				}
				{
					elementEvents: scroll: true
					windowEvents: resize: null, scroll: true
				}
				{
					elementEvents: scroll: null
					windowEvents: resize: true, scroll: true
				}
			].forEach (vars) =>

				# set mock vars
				@scope.elementEvents = vars.elementEvents
				@scope.windowEvents = vars.windowEvents

				do @scope.removeEvents

				do expect (do $).__proto__.on
				.not.toHaveBeenCalled

				expect @scope.elementEvents
				.toEqual vars.elementEvents

				expect @scope.windowEvents
				.toEqual vars.windowEvents

		it 'should unbind events from the element', ->

			events =
				scroll: true

			@scope.elementEvents = angular.copy events

			spyOn (do $).__proto__, 'off'

			do @scope.removeEvents

			expect (do $).__proto__.off
			.toHaveBeenCalledWith events

		it 'should unbind events from the $window', inject ($window) ->

			events =
				resize: true
				scroll: true

			@scope.windowEvents = angular.copy events

			spyOn (do $).__proto__, 'off'

			do spyOn angular, 'element'
			.andCallThrough

			do @scope.removeEvents

			expect angular.element
			.toHaveBeenCalledWith $window

			expect (do $).__proto__.off
			.toHaveBeenCalledWith events

		it 'should set scope.elementEvents to an empty object', ->

			@scope.elementEvents =
				scroll: true

			do @scope.removeEvents

			expect @scope.elementEvents
			.toEqual {}

		it 'should set scope.windowEvents to an empty object', ->

			@scope.windowEvents =
				resize: true
				scroll: true

			do @scope.removeEvents

			expect @scope.windowEvents
			.toEqual {}


	describe '#changeDisabled', ->

		it 'shouldn\'t call anything if the 1st argument is identical to the 2nd argument', ->

			spyOn @scope, 'on'
			spyOn @scope, 'off'
			spyOn @scope, 'resetClone'

			@scope.changeDisabled true, true

			do expect @scope.on
			.not.toHaveBeenCalled

			do expect @scope.off
			.not.toHaveBeenCalled

			do expect @scope.resetClone
			.not.toHaveBeenCalled

		it 'should call #off with no arguments if the 1st argument is truthy', ->

			spyOn @scope, 'off'

			@scope.changeDisabled true

			expect @scope.off
			.toHaveBeenCalledWith

		it 'should call #on and #resetClone with no arguments, and #toggleClone with false if the 1st argument is truthy', ->

			spyOn @scope, 'on'
			spyOn @scope, 'resetClone'
			spyOn @scope, 'toggleClone'

			@scope.changeDisabled false

			expect @scope.on
			.toHaveBeenCalledWith

			expect @scope.resetClone
			.toHaveBeenCalledWith

			expect @scope.toggleClone
			.toHaveBeenCalledWith false


	describe '$destroy', ->

		it 'should call #off with no arguments', ->

			@scope.mutationObserver = ->

			spyOn @scope, 'off'

			do @scope.$destroy

			expect @scope.off
			.toHaveBeenCalledWith


	describe '$watches', ->

		it 'should call #changeDisabled when scope.disabled changes', inject ($timeout) ->

			spyOn @scope, 'changeDisabled'

			@element.attr 'disabled', 'foo'

			do @scope.$apply

			$timeout ->
				expect @scope.changeDisabled
				.toHaveBeenCalled()

		it 'should call #rowsChanged when scope.rows changes', inject ($timeout) ->

			spyOn @scope, 'rowsChanged'

			@element.attr 'rows', 'foo'

			do @scope.$apply

			$timeout ->
				expect @scope.rowsChanged
				.toHaveBeenCalled()
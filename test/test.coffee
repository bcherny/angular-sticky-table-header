describe 'angular-sticky-table-header', ->

	options =
		cloneClassName: 'sticky-clone'
		stuckClassName: 'sticky-stuck'
		interval: 10

	window._ =
		debounce: (fn) -> fn
		throttle: (fn) -> fn

	$window =
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

		it 'should call #removeClones, #createClone, and #sizeClone', ->

			spyOn @scope, 'removeClones'
			spyOn @scope, 'createClone'
			spyOn @scope, 'sizeClone'

			do @scope.resetClone

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

		it 'should set scope.isStuck to false', ->

			do @scope.createClone
			do @scope.removeClones

			expect @scope.isStuck
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

		it 'should set the <th> clone\'s left and right CSS equal to scope.offset', ->

			@scope.clone =
				css: ->
			@scope.offset =
				left: 1
				right: 2

			spyOn @scope.clone, 'css'

			do @scope.setCloneGutter

			expect @scope.clone.css
			.toHaveBeenCalledWith @scope.offset


	describe '#setOffset', ->

		it 'should call getBoundingClientRect on the first <tr>', ->

			spyOn (@element.find 'tr')[0], 'getBoundingClientRect'

			do @scope.setOffset

			do expect (@element.find 'tr')[0].getBoundingClientRect
			.toHaveBeenCalled

		it 'should set scope.offset equal to the value returned by getBoundingClientRect', ->

			@scope.offset = null

			spyOn (@element.find 'tr')[0], 'getBoundingClientRect'
			.andReturn 'foo'

			do @scope.setOffset

			expect @scope.offset
			.toEqual 'foo'


	describe '#setStuck', ->

		it 'should set scope.isStuck equal to the boolean passed into it', ->

			@scope.isStuck = null
			@scope.setStuck true

			expect @scope.isStuck
			.toBe true

		it 'should coerce non-boolean values into booleans', ->

			@scope.setStuck true
			expect @scope.isStuck
			.toBe true

			@scope.setStuck 'foo'
			expect @scope.isStuck
			.toBe true

			@scope.setStuck 42
			expect @scope.isStuck
			.toBe true

			@scope.setStuck null
			expect @scope.isStuck
			.toBe false

			@scope.setStuck 0
			expect @scope.isStuck
			.toBe false

			@scope.setStuck false
			expect @scope.isStuck
			.toBe false


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

		it 'should call #setOffset, #setClonedCellWidths, and #setClonedCellWidths', ->

			@scope.clone = true
			@scope.setClonedCellWidths = ->
			@scope.setCloneGutter = ->
			@scope.setOffset = ->

			spyOn @scope, 'setClonedCellWidths'
			spyOn @scope, 'setCloneGutter'
			spyOn @scope, 'setOffset'

			do @scope.sizeClone

			do expect @scope.setOffset
			.toHaveBeenCalled

			do expect @scope.setClonedCellWidths
			.toHaveBeenCalled

			do expect @scope.setCloneGutter
			.toHaveBeenCalled


	describe '#checkScroll', ->

		beforeEach ->

			spyOn @scope, 'setStuck'
			spyOn @scope, 'setClonedCellWidths'
			.andCallFake ->

		it 'should call #setStuck with true and #setClonedCellWidths with no arguments when scope.isStuck is false and scrollY is >= offset.top', ->

			@scope.clone = true
			@scope.isStuck = false;
			@scope.offset =
				top: 0
			$window.scrollY = 1

			do @scope.checkScroll

			expect @scope.setStuck
			.toHaveBeenCalledWith true

			do expect @scope.setClonedCellWidths
			.toHaveBeenCalled

		it 'should call #setStuck with false when scope.isStuck is true and scrollY is < offset.top', ->

			@scope.clone = true
			@scope.isStuck = true;
			@scope.offset =
				top: 1
			$window.scrollY = 0

			do @scope.checkScroll

			expect @scope.setStuck
			.toHaveBeenCalledWith false

		it 'should not call #setStuck otherwise', ->

			# isStuck = true, scrollY >= offset
			@scope.clone = true
			@scope.isStuck = true;
			@scope.offset =
				top: 0
			$window.scrollY = 1

			do @scope.checkScroll

			# isStuck = false, scrollY < offset
			@scope.isStuck = false;
			@scope.offset =
				top: 1
			$window.scrollY = 0

			do @scope.checkScroll

			do expect @scope.setStuck
			.not.toHaveBeenCalled


	describe '#rowsChanged', ->

		it 'should call #checkScroll and #setClonedCellWidths after a $timeout', inject ($timeout) ->

			spyOn @scope, 'checkScroll'
			spyOn @scope, 'setClonedCellWidths'

			do @scope.rowsChanged

			do $timeout.flush

			do expect @scope.checkScroll
			.toHaveBeenCalled

			do expect @scope.setClonedCellWidths
			.toHaveBeenCalled


	describe '$destroy', ->

		# TODO
		# it 'should remove DOM events', ->

		it 'should remove the mutation observer', ->

			@scope.mutationObserver = ->

			spyOn @scope, 'mutationObserver'

			do @scope.$destroy

			expect @scope.mutationObserver
			.toHaveBeenCalled()
describe 'angular-sticky-table-header', ->

	options =
		cloneClassName: 'sticky-clone'
		stuckClassName: 'sticky-stuck'
		interval: 10

	$window =
		scrollY: 0

	beforeEach (angular.mock.module 'stickyTableHeader'), ($provide) ->
		
		$provide.value 'options', options
		$provide.value '$window', $window
	
	beforeEach ->
		
		inject (@$compile, $rootScope) ->

			@scope = do $rootScope.$new

			angular.extend @scope,
				columnCollection: ['foo', 'bar', 'baz']
				rowCollection: (Array.apply null, Array 200).map -> ['moo', 'woo', 'zoo']

			@element = angular.element """
				<div sticky-table-header columns="columnCollection" rows="rowCollection">

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

	beforeEach ->

		(@$compile @element) @scope
		do @scope.$digest

		$window =
			scrollY: 0


	#########################################


	describe '#doClone', ->

		it 'should clone the first <tr> it finds and append it to the <thead>', ->

			expect (@element.find 'thead tr').length
			.toBe 1

			do @scope.doClone

			expect (@element.find 'thead tr').length
			.toBe 2

		it 'should clone the <tr>\'s contents', ->

			do @scope.doClone

			expect ($((@element.find 'thead tr')[1]).find 'th').length
			.toBe @scope.columnCollection.length

		it 'should mirror the original <tr>\'s className', ->

			@element.find 'thead tr'
			.addClass 'test'

			do @scope.doClone

			expect $((@element.find 'thead tr')[1]).hasClass 'test'
			.toBe true

		it 'should assign the clone the className defined in options.cloneClassName', ->

			do @scope.doClone

			expect $((@element.find 'thead tr')[1]).hasClass options.cloneClassName
			.toBe true
 

	describe '#removeClones', ->

		it 'should set scope.isStuck to false', ->

			do @scope.doClone
			do @scope.removeClones

			expect @scope.isStuck
			.toBe false

		it 'should remove all <tr> clones', ->

			do @scope.doClone
			do @scope.doClone
			do @scope.doClone

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
			.and.returnValue 'foo'

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

		it 'should call #setStuck with true when scope.isStuck is false and scrollY is >= offset.top', ->

			spyOn @scope, 'setStuck'

			@scope.clone = true
			@scope.isStuck = false;
			@scope.offset =
				top: 0
			$window.scrollY = 1

			do @scope.checkScroll

			expect @scope.setStuck
			.toHaveBeenCalledWith true

		it 'should call #setStuck with false when scope.isStuck is true and scrollY is < offset.top', ->

			spyOn @scope, 'setStuck'

			@scope.clone = true
			@scope.isStuck = true;
			@scope.offset =
				top: 1
			$window.scrollY = 0

			do @scope.checkScroll

			expect @scope.setStuck
			.toHaveBeenCalledWith false

		it 'should not call #setStuck otherwise', ->

			spyOn @scope, 'setStuck'

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

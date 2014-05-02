describe 'angular-sticky-table-header', ->

	options =
		cloneClassName: 'sticky-clone'
		className: 'sticky-stuck'
		interval: 10

	beforeEach (angular.mock.module 'stickyTableHeader'), ($provide) ->
		
		$provide.value 'options', options
	
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
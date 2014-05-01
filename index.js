/* global angular */

angular
.module('demo', ['stickyTableHeader'])
.controller('mainCtrl', ['$scope', function ($scope) {

	$scope.columnCollection = ['column1', 'column2', 'column3', 'column4'];

	$scope.rowCollection = Array
		.apply(null, { length: 200 })
		.map(function() {

			return $scope.columnCollection.map(function () {
				return 'foo';
			});

		});
	
}]);
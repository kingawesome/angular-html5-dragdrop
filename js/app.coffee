
angular.module('app', ['ddDragDrop','hljs'])

.controller('ApplicationController', ($scope) ->
    $scope.columns = [
      {name: 'Header 1'}
      {name: 'Header 2'}
      {name: 'Header 3'}
      {name: 'Header 4'}
      {name: 'Header 5'}
    ]




    $scope.columnDragHelper = (columnText) ->
      "<div class='column-drag-helper'>#{columnText.toUpperCase()}</div>"
  )

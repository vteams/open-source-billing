# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  jQuery(".reports table.table_listing").tablesorter()
  jQuery(".reports #from_date, .reports #to_date").datepicker dateFormat: 'yy-mm-dd'
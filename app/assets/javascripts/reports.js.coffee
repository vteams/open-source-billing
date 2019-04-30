# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  if $('#from_date').length > 0 and $('#to_date').length > 0
    initDateRangePicker(DateFormats.format().toUpperCase())
  else
    initOnlyToDatePicker(DateFormats.format().toUpperCase()) if $('#to_date').length > 0

initDateRangePicker = (format) ->
  options =
    autoUpdateInput: false
    locale: format: format

  $('#date_range_picker').daterangepicker options, (start, end) ->
    $('#from_date').val start.format(format)
    $('#to_date').val end.format(format)

  $('#date_range_picker').on 'apply.daterangepicker', (ev, picker) ->
    $(this).val picker.startDate.format(format) + ' - ' + picker.endDate.format(format)

  $('#date_range_picker').on 'cancel.daterangepicker', (ev, picker) ->
    $(this).val ''
    picker.element.val ''
    $('#from_date').val ''
    $('#to_date').val ''

initOnlyToDatePicker = (format) ->
  $('#to_date').daterangepicker {
    singleDatePicker: true
    locale: format: format
  }, (start, end, label) ->
    $('#to_date').val start.format(format)
    return

# Add date picker to invoice date , invoice due date and payment date.
jQuery ->
  jQuery("#expense_expense_date").datepicker
    dateFormat: DateFormats.format()
    beforeShow: (input, inst) ->
      widget = jQuery(inst).datepicker('widget')
      widget.css('margin-left', jQuery(input).outerWidth() - widget.outerWidth())
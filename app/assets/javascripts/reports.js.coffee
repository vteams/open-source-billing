# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
#  jQuery(".report-section  #from_date, .reports #to_date").datepicker dateFormat: DateFormats.format()
#  jQuery(".reports table.table_listing:not(.aged_accounts_listing, .client_report_listing, .item_sales_listing)").tablesorter()
#  jQuery(".aged_accounts_listing, .client_report_listing, .item_sales_listing").tablesorter textExtraction: (node) ->
#    node.getAttribute('data-sort_val')
  $('.report-section  #from_date_icon').pickadate
    format: "yyyy-mm-dd"
    formatSubmit: DateFormats.format()
    onSet: (context) ->
      value = @get('value')
      $('.report-section #from_date').val value

    $('.report-section  #to_date_icon').pickadate
      format: "yyyy-mm-dd"
      formatSubmit: DateFormats.format()
      onSet: (context) ->
        value = @get('value')
        $('.report-section  #to_date').val value
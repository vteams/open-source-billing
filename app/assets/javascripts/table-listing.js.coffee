window.tableListing = ->
  # setup talbesorter parser for amount columns with currency and ',' signs
#  jQuery.tablesorter.addParser
#    id: "thousands"
#    is: (s) ->
#      sp = s.replace(/,/, ".")
#      /([£$€] ?\d+\.?\d*|\d+\.?\d* ?)/.test(sp) #check currency with symbol
#    format: (s) ->
#      jQuery.tablesorter.formatFloat s.replace(new RegExp(/[^\d\.]/g), "")
#    type: "numeric"
#
#  # Apply sorting on listing tables
#  sort_list = if jQuery("table.table_listing").hasClass('emails_listing') then [
#    [3, 1]
#  ] else [
#    [1, 1]
#  ]
#  jQuery("table.table_listing").tablesorter
#    widgets: ['staticRow']
#    sortList: sort_list

  # make 10 option selected by default in invoice per page
  #jQuery("select.per_page").val('10');

  # Check all checkboxes using from main checkbox
  jQuery('body').on "click", '#select_all', ->
    listing_table =  jQuery(this).parents('table.table_listing')
    selected = if @checked then "selected" else ""
    listing_table.find(':checkbox').prop('checked', @checked).parents('tr').removeClass('selected').addClass(selected)

  jQuery(".alert button.close").click ->
    jQuery(this).parent(".alert").hide()


  # Check/uncheck all invoice listing checkboxes using from main checkbox
  jQuery('body').on "click", '#main-invoice-checkbox', ->
    jQuery(this).parents('table.table-striped').find(':checkbox').attr('checked', this.checked)

  # Check/uncheck main checkbox if all checkboxes are checked
  jQuery('table.table_listing').on "click", 'tbody :checkbox', ->
    if jQuery(this).is(":checked")
      jQuery(this).parents('tr').addClass('selected')
    else
      jQuery(this).parents('tr').removeClass('selected')
    status = unless jQuery('table.table_listing tbody input[type=checkbox]:not(:checked)').length then true else false
    jQuery('#select_all').attr('checked', status)

  # tool tip on links not implemented yet
  jQuery(".no_links").attr("title", "This feature is not implemented yet.").qtip
    position:
      at: "bottomCenter"

  # tool tip on invoice statuses
  jQuery(".sent, .draft, .partial, .draft-partial, .paid, .disputed, .viewed, .remove_item, .sort_icon, .text-overflow-class").qtip
    position:
      at: "bottomCenter"

  # Test-overflow and ellipses and Display full content on mouse over
  jQuery(".text-overflow-class").each ->
    rows = jQuery(this).attr('data-overflow-rows') || 2
    jQuery(this).ellipsis row: rows

  # add a space if td is empty in table listing
  jQuery("table.table_listing tbody td:empty").html("&nbsp;")

  # Alert on no record selection and confirm to delete forever payment
  jQuery("body").on "click", '.top_links', ->
    title = jQuery(this).parents("ul").attr "value"
    title = title.toLowerCase()
    action = jQuery(this).val().toLowerCase()
    selected_rows =  jQuery("table.table_listing tbody").find(":checked").length
    flag = true

    if jQuery(this).hasClass('new_invoice') and selected_rows is 0
      jQuery('.alert').hide();
      jQuery(".alert.alert-error").show().find("span").html "You haven't selected any client. Please select a client and try again."
      flag = false
    else if selected_rows is 0
      jQuery('.alert').hide();
      jQuery(".alert.alert-error").show().find("span").html "You haven't selected any #{title} to #{action}. Please select one or more #{if title is 'company' then 'companie' else title}s and try again."
      flag = false
    else if jQuery(this).hasClass('new_invoice') and selected_rows > 1
      jQuery('.alert').hide();
      jQuery(".alert.alert-error").show().find("span").html "You have selected multiple clients. Please select a single client to create new invoice."
      flag = false
    else if title is "payment" and action is "delete forever"
      flag = confirm("Are you sure you want to delete these payment(s)?")
    else if title is "invoice" and action is "send"
      flag = confirm("Are you sure you want to send selected invoice(s)?")
    flag

  #Add remove sortup sortdown icons in table listing
  jQuery('.table_listing a.sortable').parent('th').click (e) ->
    header = jQuery(this)
    headers = header.parents('thead').find('th')
    direction = jQuery('#sort_direction').html()

    headers.removeClass('sortup sortdown')
    if direction == 'desc' then header.addClass('sortup') else header.addClass('sortdown')

  # handle association checkboxes and redio buttons
  jQuery('.association').click ->
    type = jQuery(this).attr('value')
    parent = jQuery(this).parents('.options_content')
    checkbox = parent.find('input[type=checkbox]')
    # uncheck all checkboxes if account is selected
    checkbox.prop('checked', false) if type is 'account'

  jQuery('#pdffile').change ->
    jQuery('#subfile').val(jQuery(this).val())

  #
  jQuery('.options_content').on "click", ':checkbox', ->
    status = jQuery('.options_content input[type=checkbox]:not(:checked)').length
    jQuery('#company_association').attr('checked', status)
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
#  sort_list = if $("table.table_listing").hasClass('emails_listing') then [
#    [3, 1]
#  ] else [
#    [1, 1]
#  ]
#  $("table.table_listing").tablesorter
#    widgets: ['staticRow']
#    sortList: sort_list

  # make 10 option selected by default in invoice per page
  #$("select.per_page").val('10');

  # Check all checkboxes using from main checkbox
  $('#select_all').on "click",null, ->
    listing_table =  $(this).parents('table.table_listing')
    selected = if @checked then "selected" else ""
    listing_table.find(':checkbox').attr('checked', @checked).parents('tr').removeClass('selected').addClass(selected)

  $(".alert button.close").click ->
    $(this).parent(".alert").hide()


  # Check/uncheck all invoice listing checkboxes using from main checkbox
  $('#main-invoice-checkbox').on "click",null, ->
    $(this).parents('table.table-striped').find(':checkbox').attr('checked', this.checked)

  # Check/uncheck main checkbox if all checkboxes are checked
  $('table.table_listing tbody :checkbox').on "click",null, ->
    if $(this).is(":checked")
      $(this).parents('tr').addClass('selected')
    else
      $(this).parents('tr').removeClass('selected')
    status = unless $('table.table_listing tbody input[type=checkbox]:not(:checked)').length then true else false
    $('#select_all').attr('checked', status)

  # tool tip on links not implemented yet
  $(".no_links").attr("title", "This feature is not implemented yet.").qtip
    position:
      at: "bottomCenter"

  # tool tip on invoice statuses
  $(".sent, .draft, .partial, .draft-partial, .paid, .disputed, .viewed, .remove_item, .sort_icon, .text-overflow-class").qtip
    position:
      at: "bottomCenter"

  # Test-overflow and ellipses and Display full content on mouse over
  $(".text-overflow-class").each ->
    rows = $(this).attr('data-overflow-rows') || 2
    $(this).ellipsis row: rows

  # add a space if td is empty in table listing
  $("table.table_listing tbody td:empty").html("&nbsp;")

  # Alert on no record selection and confirm to delete forever payment
  $(".top_links").on "click",null, ->
    title = $(this).parents("ul").attr "value"
    title = title.toLowerCase()
    action = $(this).val().toLowerCase()
    selected_rows =  $("table.table_listing tbody").find(":checked").length
    flag = true

    if $(this).hasClass('new_invoice') and selected_rows is 0
      $('.alert').hide();
      $(".alert.alert-error").show().find("span").html "You haven't selected any client. Please select a client and try again."
      flag = false
    else if selected_rows is 0
      $('.alert').hide();
      $(".alert.alert-error").show().find("span").html "You haven't selected any #{title} to #{action}. Please select one or more #{if title is 'company' then 'companie' else title}s and try again."
      flag = false
    else if $(this).hasClass('new_invoice') and selected_rows > 1
      $('.alert').hide();
      $(".alert.alert-error").show().find("span").html "You have selected multiple clients. Please select a single client to create new invoice."
      flag = false
    else if title is "payment" and action is "delete forever"
      flag = confirm("Are you sure you want to delete these payment(s)?")
    else if title is "invoice" and action is "send"
      flag = confirm("Are you sure you want to send selected invoice(s)?")
    flag

  #Add remove sortup sortdown icons in table listing
  $('.table_listing a.sortable').parent('th').click (e) ->
    header = $(this)
    headers = header.parents('thead').find('th')
    direction = $('#sort_direction').html()

    headers.removeClass('sortup sortdown')
    if direction == 'desc' then header.addClass('sortup') else header.addClass('sortdown')

  # handle association checkboxes and redio buttons
  $('.association').click ->
    type = $(this).attr('value')
    parent = $(this).parents('.options_content')
    checkbox = parent.find('input[type=checkbox]')
    # uncheck all checkboxes if account is selected
    checkbox.prop('checked', false) if type is 'account'

  $('#pdffile').change ->
    $('#subfile').val($(this).val())

  #
  $('.options_content :checkbox').on "click",null, ->
    status = $('.options_content input[type=checkbox]:not(:checked)').length
    $('#company_association').attr('checked', status)

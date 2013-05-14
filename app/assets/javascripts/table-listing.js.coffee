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
  jQuery('#select_all').live "click", ->
    listing_table =  jQuery(this).parents('table.table_listing')
    selected = if @checked then "selected" else ""
    listing_table.find(':checkbox').attr('checked', @checked).parents('tr').removeClass('selected').addClass(selected)

  jQuery(".alert button.close").click ->
    jQuery(this).parent(".alert").hide()


  # Check/uncheck all invoice listing checkboxes using from main checkbox
  jQuery('#main-invoice-checkbox').live "click", ->
    jQuery(this).parents('table.table-striped').find(':checkbox').attr('checked', this.checked)

  # Check/uncheck main checkbox if all checkboxes are checked
  jQuery('table.table_listing tbody :checkbox').live "click", ->
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
    jQuery(this).ellipsis row:rows

#  jQuery(".text-overflow-class").live "mouseenter", ->
#    field_class = "single_line"
#    left_position = jQuery(this).offset().left  + "px";
#    top_position = jQuery(this).offset().top + -1+ "px";
#    full_content = jQuery(this).attr "value"
#    contains = (jQuery(this).text().indexOf("...") > -1)
#    jQuery(this).attr('title',full_content) if contains
#    field_class = "multi_line" if jQuery(this).height() > 20
#    html_text =  "<span class='mouseover_full_content #{field_class}' style='left:#{left_position};top:#{top_position}'>#{full_content}<span>"
#    jQuery(this).append html_text
#    jQuery(".mouseover_full_content").width(jQuery(this).width());
#    jQuery(".mouseover_full_content").show() if contains
#
#  jQuery('.text-overflow-class').live "mouseleave", ->
#    jQuery('.mouseover_full_content').remove()

  # add a space if td is empty in table listing
  jQuery("table.table_listing tbody td:empty").html("&nbsp;")

  # Alert on no record selection and confirm to delete forever payment
  jQuery(".top_links").live "click", ->
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
      jQuery(".alert.alert-error").show().find("span").html "You haven't selected any #{title} to #{action}. Please select one or more #{title}s and try again."
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



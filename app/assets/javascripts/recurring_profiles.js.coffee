jQuery ->
  # Add date picker to start date
  jQuery("#recurring_profile_first_invoice_date").datepicker
    dateFormat: 'yy-mm-dd'

  # Validate recurring profile form
  jQuery("form.form-recurring-profile").submit ->
    item_rows = jQuery("table#invoice_grid_fields tr.fields:visible")
    first_invoice_date = jQuery("#recurring_profile_first_invoice_date").val()
    current_date = jQuery("#recurring_profile_current_date").val()
    flag = true
    # Check if first invoice date is selected
    if jQuery("#recurring_profile_first_invoice_date").val() is ""
      applyPopover(jQuery("#recurring_profile_first_invoice_date"),"bottomMiddle","topLeft","Select first invoice date")
      flag = false
      # Check if client is selected
    else if jQuery("#recurring_profile_client_id").val() is ""
      applyPopover(jQuery("#recurring_profile_client_id_chzn"),"bottomMiddle","topLeft","Select a client")
      flag = false
      # Check if payment term is selected
    else if jQuery("#recurring_profile_payment_terms_id").val() is ""
      applyPopover(jQuery("#recurring_profile_payment_terms_id_chzn"),"bottomMiddle","topLeft","Select a payment term")
      flag = false
      # Check if item is selected
    else if item_rows.find("select.items_list option:selected[value='']").length is item_rows.length
      first_item = jQuery("table#invoice_grid_fields tr.fields:visible:first").find("select.items_list").next()
      applyPopover(first_item,"bottomMiddle","topLeft","Select an item")
      flag = false
    else if first_invoice_date == current_date
      flag = confirm("This will send out an invoice IMMEDIATELY. Are you sure you want to send the first invoice right now?" )
    flag

  applyPopover = (elem,position,corner,message) ->
    elem.qtip
      content:
        text: message
      show:
        event: false
      hide:
        event: false
      position:
        at: position
      style:
        tip:
          corner: corner
    elem.qtip().show()
    elem.focus()

  jQuery("#recurring_profile_first_invoice_date").on "change keyup", ->
    jQuery(this).qtip("hide")

  # Only numeric values(1-9) are allowed in occurrences(how many).
  jQuery("#recurring_profile_occurrences").on "keyup keypress", ->
    @value = @value.replace(/[^0-9]/g, "")
    @value = '' if @value is "0"

  # remove 'infinite' if click on how many.
  jQuery("#recurring_profile_occurrences").on
    click: ->
      @value = '' if @value is 'infinite'
    blur: ->
      @value = 'infinite' if @value is ''

  # Don't allow paste and right click in occurrences field
  jQuery("#recurring_profile_occurrences").bind "contextmenu", (e) ->
    e.preventDefault()

  # Date formating function
  formated_date = (elem) ->
    separator = "-"
    new_date  = elem.getFullYear()
    new_date += separator + ("0" + (elem.getMonth() + 1)).slice(-2)
    new_date += separator + ("0" + elem.getDate()).slice(-2)

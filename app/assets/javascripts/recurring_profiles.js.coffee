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

  useAsTemplatePopover = (elem,id,client_name) ->
    elem.qtip
      content:
        text: "<a href='/recurring_profiles/new/#{id}'>To create new recurring profile use the last invoice send to '#{client_name}'.</a><span class='close_qtip'>x</span>"
      show:
        event: false
      hide:
        event: false
      position:
        at: "rightTop"
      style:
        classes: 'use_as_template'
        tip:
          corner: "bottomLeft"
    elem.qtip().show()
    qtip = jQuery(".qtip.use_as_template")
    qtip.css("top",qtip.offset().top - qtip.height())
    qtip.attr('data-top',qtip.offset().top - qtip.height())
    elem.focus()

  hidePopover = (elem) ->
    #elem.next(".popover").hide()
    elem.qtip("hide")

  # Hide use as template qtip
  jQuery('.use_as_template .close_qtip').live "click", ->
    hidePopover(jQuery("#recurring_profile_client_id_chzn"))

  jQuery("#recurring_profile_client_id_chzn,.chzn-container").live "click", ->
    jQuery(this).qtip("hide")

  # Don't send an ajax request if an item is deselected.
  clearLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    container.find("input.description").val('')
    container.find("input.cost").val('')
    container.find("input.qty").val('')
    container.find("select.tax1,select.tax2").val('').trigger("liszt:updated")
    updateLineTotal(elem)
    updateInvoiceTotal()

  jQuery('#active_links a').live 'click', ->
    jQuery('#active_links a').removeClass('active')
    jQuery(this).addClass('active')

  jQuery(".invoice_action_links input[type=submit]").click ->
    jQuery(this).parents("FORM:eq(0)").find("table.table_listing").find(':checkbox').attr()


  jQuery("#recurring_profile_client_id").change ->
    client_id = jQuery(this).val()
    hidePopover(jQuery("#recurring_profile_client_id_chzn")) if client_id is ""
    jQuery("#last_invoice").hide()
    if not client_id? or client_id isnt ""

      jQuery.get('/clients/'+ client_id + '/default_currency')

      jQuery.ajax '/clients/get_last_invoice',
        type: 'POST'
        data: "id=" + client_id
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          alert "Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
          data = JSON.parse(data)
          id = jQuery.trim(data[0])
          client_name = data[1]
          unless id is "no invoice"
            useAsTemplatePopover(jQuery("#recurring_profile_client_id_chzn"),id,client_name)
          else
            hidePopover(jQuery(".hint_text:eq(0)"))

  # Change currency of invoice
  jQuery("#recurring_profile_currency_id").change ->
    currency_id = jQuery(this).val()
    hidePopover(jQuery("#recurring_profile_currency_id_chzn")) if currency_id is ""
    if not currency_id? or currency_id isnt ""
      jQuery.get('/recurring_profiles/selected_currency?currency_id='+ currency_id)


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

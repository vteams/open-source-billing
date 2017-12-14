# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $("a.deleted_entry").click (e)->
    applyPopover(jQuery(this),"bottomMiddle","topLeft","Please recover to view details")
    e.preventDefault()
    return false

  window.applyChosen()

  window.tableListing()

  window.validateCreditCard()

  # Calculate the line total for invoice
  updateLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    cost = jQuery(container).find("input.cost").val()
    qty = jQuery(container).find("input.qty").val()
    cost = 0 if not cost? or cost is "" or not jQuery.isNumeric(cost)
    qty = 0 if not qty? or qty is "" or not jQuery.isNumeric(qty)
    line_total = ((parseFloat(cost) * parseFloat(qty))).toFixed(2)
    jQuery(container).find(".line_total").text(line_total)

  # Calculate grand total from line totals
  updateInvoiceTotal = ->

    total = 0
    tax_amount = 0
    discount_amount = 0
    jQuery("table.estimate_grid_fields tr:visible .line_total").each ->
      line_total = parseFloat(jQuery(this).text())
      total += line_total
      #update invoice sub total lable and hidden field
      jQuery("#estimate_sub_total, #recurring_profile_sub_total").val(total.toFixed(2))
      jQuery("#estimate_sub_total_lbl").text(total.toFixed(2))

      #update estimate total lable and hidden field
      jQuery("#estimate_estimate_total, #recurring_profile_estimate_total").val(total.toFixed(2))
      jQuery("#estimate_total_lbl").text(total.toFixed(2))

      tax_amount += applyTax(line_total,jQuery(this))

    discount_amount = applyDiscount(total)

    #update tax amount label and tax amount hidden field
    jQuery("#estimate_tax_amount_lbl").text(tax_amount.toFixed(2))
    jQuery("#estimate_tax_amount, #recurring_profile_tax_amount").val(tax_amount.toFixed(2))

    #update discount amount lable and discount hidden field
#    jQuery("#estimate_discount_amount_lbl").text(discount_amount.toFixed(2))
    jQuery("#estimate_discount_amount, #recurring_profile_discount_amount").val((discount_amount * -1).toFixed(2))

    total_balance = (parseFloat(jQuery("#estimate_total_lbl").text() - discount_amount) + tax_amount)
    jQuery("#estimate_estimate_total, #recurring_profile_estimate_total").val(total_balance.toFixed(2))
    jQuery("#estimate_total_lbl").text(total_balance.toFixed(2))
    jQuery("#estimate_total_lbl").formatCurrency({symbol: window.currency_symbol})

    window.taxByCategory()

  # Apply Tax on totals
  applyTax = (line_total,elem) ->
    tax1 = elem.parents("tr").find("select.tax1 option:selected").attr('data-tax_1')
    tax2 = elem.parents("tr").find("select.tax2 option:selected").attr('data-tax_2')
    tax1 = 0 if not tax1? or tax1 is ""
    tax2 = 0 if not tax2? or tax2 is ""
    # if line total is 0
    tax1=tax2=0 if line_total is 0
    discount_amount = applyDiscount(line_total)
    total_tax = (parseFloat(tax1) + parseFloat(tax2))
    (line_total - discount_amount) * (parseFloat(total_tax) / 100.0)

  # Apply discount percentage on subtotals
  applyDiscount = (subtotal) ->
    discount_percentage = jQuery("#estimate_discount_percentage").val() || jQuery("#recurring_profile_discount_percentage").val()
    discount_type = jQuery("select#discount_type").val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    if discount_type == "%" then (subtotal * (parseFloat(discount_percentage) / 100.0)) else discount_percentage

  # Update line and grand total if line item fields are changed
  jQuery("body").on "blur", "input.cost, input.qty", ->
    updateLineTotal(jQuery(this))
    updateInvoiceTotal()

  jQuery("body").on "keyup", "input.cost, input.qty", ->
    updateLineTotal(jQuery(this))
    updateInvoiceTotal()
  #jQuery(this).popover "hide"

  # Update line and grand total when tax is selected from dropdown
  jQuery("body").on "change", "select.tax1, select.tax2", ->
    updateInvoiceTotal()

  # Prevent form submission if enter key is press in cost,quantity or tax inputs.
  jQuery("body").on "keypress", "input.cost, input.qty", (e) ->
    if e.which is 13
      e.preventDefault()
      false

  # Load Items data when an item is selected from dropdown list
  jQuery(".estimate_grid_fields").on "change", "select.items_list", ->
    # Add an empty line item row at the end if last item is changed.
    elem = jQuery(this)
    if elem.val() is ""
      clearLineTotal(elem)
      false
    else
      jQuery.ajax '/items/load_item_data',
        type: 'POST'
        data: "id=" + jQuery(this).val()
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          alert "Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
          item = JSON.parse(data)
          container = elem.parents("tr.fields")
          # populate item's discription, cost, quantity and taxes.
          container.find("input.description").val(item[0])
          container.find("input.cost").val(item[1].toFixed(2))
          container.find("input.qty").val(item[2])
          container.find("select.tax1,select.tax2").val('').trigger("liszt:updated")
          container.find("select.tax1").val(item[3]).trigger("liszt:updated") if item[3] isnt 0
          container.find("select.tax2").val(item[4]).trigger("liszt:updated") if item[4] isnt 0
          container.find("input.item_name").val(item[5])
          container.find("select.item_id").val(item[6])
          updateLineTotal(elem)
          updateInvoiceTotal()
      addLineItemRow(elem)

  # Add empty line item row
  addLineItemRow = (elem) ->
    if elem.parents('tr.fields').next('tr.fields:visible').length is 0
      jQuery(".add_nested_fields").click()
  #applyChosen(jQuery('.estimate_grid_fields tr.fields:last .chzn-select'))

  jQuery("body").on "click", ".add_nested_fields", ->
    setTimeout "window.applyChosen(jQuery('.estimate_grid_fields tr.fields:last .chzn-select'))", 0

  # Re calculate the total estimate balance if an item is removed
  jQuery("body").on "click", ".remove_nested_fields", ->
    setTimeout (->
      updateInvoiceTotal()
    ), 100

  # Subtract discount percentage from subtotal
  jQuery("#estimate_discount_percentage, #recurring_profile_discount_percentage").on "blur keyup", ->
    updateInvoiceTotal()

  # Subtract discount percentage from subtotal
  jQuery("select#discount_type").change ->
    updateInvoiceTotal()

  # Don't allow nagetive value for discount
  jQuery("#estimate_discount_percentage, #recurring_profile_discount_percentage,.qty").keydown (e) ->
    if e.keyCode is 109 or e.keyCode is 13
      e.preventDefault()
      false

  # Don't allow paste and right click in discount field
  jQuery("#estimate_discount_percentage, #recurring_profile_discount_percentage, .qty").bind "paste contextmenu", (e) ->
    e.preventDefault()

  # Add date picker to estimate date , estimate due date and payment date.
  jQuery("#estimate_estimate_date, #estimate_due_date, .date_picker_class").datepicker
    dateFormat: DateFormats.format()
    beforeShow: (input, inst) ->
      widget = jQuery(inst).datepicker('widget')
      widget.css('margin-left', jQuery(input).outerWidth() - widget.outerWidth())

  # Makes the estimate line item list sortable
  jQuery("#estimate_grid_fields tbody").sortable
    handle: ".sort_icon"
    items: "tr.fields"
    axis: "y"

  # Calculate line total and estimate total on page load
  jQuery(".estimate_grid_fields tr:visible .line_total").each ->
    updateLineTotal(jQuery(this))
    # dont use decimal points in quantity and make cost 2 decimal points
    container = jQuery(this).parents("tr.fields")
    cost = jQuery(container).find("input.cost")
    qty = jQuery(container).find("input.qty")
    cost.val(parseFloat(cost.val()).toFixed(2)) if cost.val()
    qty.val(parseInt(qty.val())) if qty.val()
  updateInvoiceTotal()

  # dispute popup validation
  jQuery("form.dispute_form").submit ->
    flag = true
    if jQuery("#reason_for_dispute").val() is ""
      applyPopover(jQuery("#reason_for_dispute"),"bottomMiddle","topLeft","Enter reason for dispute")
      flag = false
    flag
  jQuery("body").on "keyup", "#reason_for_dispute", ->
    jQuery(this).qtip("hide")

  # Validate client, cost and quantity on estimate save
  jQuery(".estimate-form.form-horizontal").submit ->
    discount_percentage = jQuery("#estimate_discount_percentage").val()
    discount_type = jQuery("select#discount_type").val()
    sub_total = jQuery('#estimate_sub_total').val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    item_rows = jQuery("table#estimate_grid_fields tr.fields:visible")

    flag = true
    # Check if company is selected
    if jQuery("#estimate_company_id").val() is ""
      applyPopover(jQuery("#estimate_company_id_chzn"),"bottomMiddle","topLeft","Select a company")
      flag = false
      # Check if client is selected
    else if jQuery("#estimate_client_id").val() is ""
      applyPopover(jQuery("#estimate_client_id_chzn"),"bottomMiddle","topLeft","Select a client")
      flag = false
      # if currency is not selected
    else if jQuery("#estimate_currency_id").val() is "" and jQuery("#estimate_currency_id").is( ":hidden" ) == false
      applyPopover(jQuery("#estimate_currency_id_chzn"),"bottomMiddle","topLeft","Select currency")
      flag = false
      # check if estimate date is selected
    else if jQuery("#estimate_estimate_date").val() is ""
      applyPopover(jQuery("#estimate_estimate_date"),"rightTop","leftMiddle","Select estimate date")
      flag =false
    else if jQuery("#estimate_estimate_date").val() isnt "" and !DateFormats.validate_date(jQuery("#estimate_estimate_date").val())
      applyPopover(jQuery("#estimate_estimate_date"),"rightTop","leftMiddle","Make sure date format is in '#{DateFormats.format()}' format")
      flag = false
      # Check if discount percentage is an integer
    else if jQuery("input#estimate_discount_percentage").val()  isnt "" and isNaN(jQuery("input#estimate_discount_percentage").val())
      applyPopover(jQuery("#estimate_discount_percentage"),"bottomMiddle","topLeft","Enter Valid Discount")
      flag = false
      # Check if no item is selected
    else if jQuery("tr.fields:visible").length < 1
      applyPopover(jQuery("#add_line_item"),"bottomMiddle","topLeft","Add line item")
      flag = false
      # Check if item is selected
    else if item_rows.find("select.items_list option:selected[value='']").length is item_rows.length
      first_item = jQuery("table#estimate_grid_fields tr.fields:visible:first").find("select.items_list").next()
      applyPopover(first_item,"bottomMiddle","topLeft","Select an item")
      flag = false
    else if discount_type == '%' and parseFloat(discount_percentage) > 100.00
      applyPopover(jQuery("#estimate_discount_percentage"),"bottomMiddle","topLeft","Percentage must be hundred or less")
      flag = false
    else if discount_type != '%' and parseFloat(discount_percentage) > parseFloat(sub_total)
      applyPopover(jQuery("#estimate_discount_percentage"),"bottomMiddle","topLeft","Discount must be less than sub-total")
      flag = false

      # Item cost and quantity should be greater then 0

    else
      jQuery("tr.fields:visible").each ->
        row = jQuery(this)
        if row.find("select.items_list").val() isnt ""
          cost = row.find(".cost")
          qty =  row.find(".qty")
          tax1 = row.find("select.tax1")
          tax2 = row.find("select.tax2")
          tax1_value = jQuery("option:selected",tax1).val()
          tax2_value = jQuery("option:selected",tax2).val()

          if not jQuery.isNumeric(cost.val()) and cost.val() isnt ""
            applyPopover(cost,"bottomLeft","topLeft","Enter valid Item cost")
            flag = false
          else hidePopover(cost)

          if not jQuery.isNumeric(qty.val())  and qty.val() isnt ""
            applyPopover(qty,"bottomLeft","topLeft","Enter valid Item quantity")
            flag = false
          else if (tax1_value is tax2_value) and (tax1_value isnt "" and tax2_value isnt "")
            applyPopover(tax2.next(),"bottomLeft","topLeft","Tax1 and Tax2 should be different")
            flag = false
          else hidePopover(qty)
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
        text: "<a href='/estimates/#{id}/edit/'>To create new estimate use the last estimate send to '#{client_name}'.</a><span class='close_qtip'>x</span>"
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
  jQuery('.use_as_template').on "click", ".close_qtip", ->
    hidePopover(jQuery("#estimate_client_id_chzn"))

  jQuery("body").on "click", "#estimate_client_id_chzn, .chzn-container", ->
    jQuery(this).qtip("hide")

  jQuery("body").on "click", "#add_line_item",->
    jQuery(this).qtip('hide')

  jQuery("body").on "change", ".line_item_qtip",->
    jQuery(this).qtip('hide')

  # Don't send an ajax request if an item is deselected.
  clearLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    container.find("input.description").val('')
    container.find("input.cost").val('')
    container.find("input.qty").val('')
    container.find("select.tax1,select.tax2").val('').trigger("liszt:updated")
    updateLineTotal(elem)
    updateInvoiceTotal()

  jQuery('#active_links').on 'click', "a", ->
    jQuery('#active_links a').removeClass('active')
    jQuery(this).addClass('active')

  jQuery(".estimate_action_links input[type=submit]").click ->
    jQuery(this).parents("FORM:eq(0)").find("table.table_listing").find(':checkbox').attr()

  # Load last estimate for client if any
  jQuery("#estimate_client_id").unbind 'change'
  jQuery("#estimate_client_id").change ->
    client_id = jQuery(this).val()
    hidePopover(jQuery("#estimate_client_id_chzn")) if client_id is ""
    jQuery("#last_estimate").hide()
    if not client_id? or client_id isnt ""

      jQuery.get('/clients/'+ client_id + '/default_currency')

      jQuery.ajax '/clients/get_last_estimate',
        type: 'POST'
        data: "id=" + client_id
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          alert "Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
          data = JSON.parse(data)
          id = jQuery.trim(data[0])
          client_name = data[1]
          unless id is "no estimate"
            #useAsTemplatePopover(jQuery("#estimate_client_id_chzn"),id,client_name)
          else
            hidePopover(jQuery(".hint_text:eq(0)"))

  # Change currency of estimate
  jQuery("#estimate_currency_id").unbind 'change'
  jQuery("#estimate_currency_id").change ->
    currency_id = jQuery(this).val()
    hidePopover(jQuery("#estimate_currency_id_chzn")) if currency_id is ""
    if not currency_id? or currency_id isnt ""
      jQuery.get('/estimates/selected_currency?currency_id='+ currency_id)


  jQuery.datepicker.setDefaults
    dateFormat: DateFormats.format()

  # Hide placeholder text on focus
  jQuery("body").on("focus", "input[type=text],input[type=number]",".quick_create_wrapper",->
    @dataPlaceholder = @placeholder
    @removeAttribute "placeholder"
  )
  jQuery("body").on("blur", "input[type=text],input[type=number]",".quick_create_wrapper", ->
    @placeholder = @dataPlaceholder
    @removeAttribute "dataPlaceholder"
  )
  jQuery("body").on "keypress", "input[type=text],input[type=number]",".quick_create_wrapper", (e) ->
    if e.which is 13
      e.preventDefault()
      jQuery(".active-form .btn_save").trigger("click")
    hidePopover(jQuery(this))

  # Show quick create popups under create buttons
  jQuery(".quick_create").click ->
    pos = $(this).position()
    height = $(this).outerHeight()
    jQuery('.quick_create_wrapper').hide()
    jQuery("##{jQuery(this).attr('name')}").css(
      position: "absolute"
      top: (pos.top + height) + "px"
      left: pos.left + "px"
    ).show()

  jQuery("body").on "click", ".close_btn", ->
    jQuery(this).parents('.quick_create_wrapper').hide().find("input").qtip("hide")

  # Alert on dispute if estimate is paid
  jQuery('#dispute_link').click ->
    jQuery('#reason_for_dispute').val('')
    flag = true
    status = jQuery(this).attr "value"
    if status is "paid"
      alert "Paid estimate can not be disputed."
      flag = false
    flag

  jQuery("body").on "click", ".more", ->
    jQuery(".toggleable").removeClass("collapse")

  jQuery("body").on "click", "#add_line_item", ->
    options = $('.items_list:first').html()
    $('.items_list:last').html(options).find('option:selected').removeAttr('selected')
    $('.items_list:last').find('option[data-type = "deleted_item"], option[data-type = "archived_item"], option[data-type = "other_company"], option[data-type = "active_line_item"]').remove()
    tax1 = $('.tax1:first').html()
    tax2 = $('.tax2:first').html()
    $('.tax1:last').html(tax1).find('option:selected').removeAttr('selected')
    $('.tax2:last').html(tax2).find('option:selected').removeAttr('selected')
    $('.tax1:last').find('option[data-type = "deleted_tax"], option[data-type = "archived_tax"], option[data-type = "active_line_item_tax"]').remove()
    $('.tax2:last').find('option[data-type = "deleted_tax"], option[data-type = "archived_tax"], option[data-type = "active_line_item_tax"]').remove()


  jQuery("body").on "click", ".less", ->
    jQuery(".toggleable").addClass("collapse")

  #send only email to client on clicking send this note only link.
  jQuery('#send_note_only').click ->
    jQuery.ajax '/estimates/send_note_only',
      type: 'POST'
      data: "response_to_client=" + jQuery("#response_to_client").val() + "&inv_id=" + jQuery("#inv_id").val()
      dataType: 'html'
      error: (jqXHR, textStatus, errorThrown) ->
        alert "Error: #{textStatus}"
      success: () ->
        jQuery('.alert').hide();
        jQuery(".alert.alert-success").show().find("span").html "This note has been sent successfully"
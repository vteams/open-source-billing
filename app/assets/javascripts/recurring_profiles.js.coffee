jQuery ->
  # Add date picker to start date
  jQuery("#recurring_profile_first_invoice_date").datepicker
    dateFormat: DateFormats.format()

  # Validate recurring profile form
  jQuery("form.form-recurring-profile").submit ->
    discount_percentage = jQuery("#recurring_profile_discount_percentage").val()
    discount_type = jQuery("select#discount_type").val()
    sub_total = jQuery('#recurring_profile_sub_total').val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
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
    # check if currency is not selected
    else if jQuery("#recurring_profile_currency_id").val() is "" and jQuery("#recurring_profile_currency_id").is( ":hidden" ) == false
      applyPopover(jQuery("#recurring_profile_currency_id_chzn"),"bottomMiddle","topLeft","Select currency")
      flag = false
      # Check if payment term is selected
    else if jQuery("#recurring_profile_payment_terms_id").val() is ""
      applyPopover(jQuery("#recurring_profile_payment_terms_id_chzn"),"bottomMiddle","topLeft","Select a payment term")
      flag = false
      # Check if discount is valid
    else if jQuery("input#recurring_profile_discount_percentage").val()  isnt "" and isNaN(jQuery("input#recurring_profile_discount_percentage").val())
      applyPopover(jQuery("#recurring_profile_discount_percentage"),"bottomMiddle","topLeft","Enter Valid Discount")
      flag = false
    # Check if no item is added
    else if jQuery("tr.fields:visible").length < 1
      applyPopover(jQuery("#add_line_item"),"bottomMiddle","topLeft","Add line item")
      flag = false
      # Check if item is selected
    else if item_rows.find("select.items_list option:selected[value='']").length is item_rows.length
      first_item = jQuery("table#invoice_grid_fields tr.fields:visible:first").find("select.items_list").next()
      applyPopover(first_item,"bottomMiddle","topLeft","Select an item")
      flag = false
    # check if discount is greater than sub-total
    else if discount_type == '%' and parseFloat(discount_percentage) > 100.00
      applyPopover(jQuery("#recurring_profile_discount_percentage"),"bottomMiddle","topLeft","Percentage must be hundred or less")
      flag = false
    else if discount_type != '%' and parseFloat(discount_percentage) > parseFloat(sub_total)
      applyPopover(jQuery("#recurring_profile_discount_percentage"),"bottomMiddle","topLeft","Discount must be less than sub-total")
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
      if first_invoice_date == current_date and flag
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
        text: "<a href='/en/recurring_profiles/new/#{id}'>To create new recurring profile use the last invoice sent to '#{client_name}'.</a><span class='close_qtip'>x</span>"
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
  jQuery('.use_as_template .close_qtip').on "click", ->
    hidePopover(jQuery("#recurring_profile_client_id_chzn"))

  jQuery("#recurring_profile_client_id_chzn,.chzn-container").on "click", ->
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

  jQuery('#active_links a').on 'click', ->
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
      @value = '1' if @value is ''

  # Don't allow paste and right click in occurrences field
  jQuery("#recurring_profile_occurrences").bind "contextmenu", (e) ->
    e.preventDefault()

  applyTax = (line_total,elem) ->
    tax1 = elem.parents("tr").find("select.tax1 option:selected").attr('data-tax_1')
    tax2 = elem.parents("tr").find("select.tax2 option:selected").attr('data-tax_2')
    tax1 = 0 if not tax1? or tax1 is ""
    tax2 = 0 if not tax2? or tax2 is ""
    discount_amount = applyDiscount(line_total)
    total_tax = (parseFloat(tax1) + parseFloat(tax2))
    (line_total - discount_amount) * (parseFloat(total_tax) / 100.0)

  # Apply discount percentage on subtotals
  applyDiscount = (subtotal) ->
    discount_percentage = jQuery("#invoice_discount_percentage").val() || jQuery("#recurring_profile_discount_percentage").val()
    discount_type = jQuery("select#discount_type").val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    if discount_type == "%" then (subtotal * (parseFloat(discount_percentage) / 100.0)) else discount_percentage

  updateInvoiceTotal = ->

    total = 0
    tax_amount = 0
    discount_amount = 0
    jQuery("table.invoice_grid_fields tr:visible .line_total").each ->
      line_total = parseFloat(jQuery(this).text())
      total += line_total
      #update invoice sub total lable and hidden field
      jQuery("#invoice_sub_total, #recurring_profile_sub_total").val(total.toFixed(2))
      jQuery("#invoice_sub_total_lbl").text(total.toFixed(2))

      #update invoice total lable and hidden field
      jQuery("#invoice_invoice_total, #recurring_profile_invoice_total").val(total.toFixed(2))
      jQuery("#invoice_total_lbl").text(total.toFixed(2))

      tax_amount += applyTax(line_total,jQuery(this))

    discount_amount = applyDiscount(total)

    #update tax amount label and tax amount hidden field
    jQuery("#invoice_tax_amount_lbl").text(tax_amount.toFixed(2))
    jQuery("#invoice_tax_amount, #recurring_profile_tax_amount").val(tax_amount.toFixed(2))

    #update discount amount lable and discount hidden field
    #    jQuery("#invoice_discount_amount_lbl").text(discount_amount.toFixed(2))
    jQuery("#invoice_discount_amount, #recurring_profile_discount_amount").val((discount_amount * -1).toFixed(2))

    total_balance = (parseFloat(jQuery("#invoice_total_lbl").text() - discount_amount) + tax_amount)
    jQuery("#invoice_invoice_total, #recurring_profile_invoice_total").val(total_balance.toFixed(2))
    jQuery("#invoice_total_lbl").text(total_balance.toFixed(2))
    jQuery("#invoice_total_lbl").formatCurrency({symbol: window.currency_symbol})
    TaxCalculator.applyAllLineItemTaxes()
  updateInvoiceTotal()

  # Date formating function
  formated_date = (elem) ->
    separator = "-"
    new_date  = elem.getFullYear()
    new_date += separator + ("0" + (elem.getMonth() + 1)).slice(-2)
    new_date += separator + ("0" + elem.getDate()).slice(-2)

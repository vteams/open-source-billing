# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->


#  Calculate the line total for invoice
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
    jQuery("table.log_invoice_grid_fields tr:visible .line_total").each ->
      line_total = parseFloat(jQuery(this).text())
      total += line_total
      #update invoice sub total lable and hidden field
      jQuery("#log_invoice_sub_total, #recurring_profile_sub_total").val(total.toFixed(2))
      jQuery("#log_invoice_sub_total_lbl").text(total.toFixed(2))

      #update invoice total lable and hidden field
      jQuery("#log_invoice_total, #recurring_profile_invoice_total").val(total.toFixed(2))
      jQuery("#log_invoice_total_lbl").text(total.toFixed(2))

    #  tax_amount += applyTax(line_total,jQuery(this))

    discount_amount = applyDiscount(total)
    #console.log(discount_amount)
    #alert(total.toFixed(2))
    #update tax amount label and tax amount hidden field
    #jQuery("#invoice_tax_amount_lbl").text(tax_amount.toFixed(2))
    #jQuery("#invoice_tax_amount, #recurring_profile_tax_amount").val(tax_amount.toFixed(2))

    #update discount amount lable and discount hidden field
    jQuery("#invoice_discount_amount_lbl").text(discount_amount)
    jQuery("#invoice_discount_amount, #recurring_profile_discount_amount").val((discount_amount * -1).toFixed(2))
    #console.log(jQuery("#log_invoice_total_lbl").text())
    total_balance = (parseFloat(jQuery("#log_invoice_total_lbl").text() - discount_amount) + tax_amount)
    #console.log(total_balance)
    jQuery("#log_invoice_total, #recurring_profile_invoice_total").val(total_balance.toFixed(2))
    jQuery("#log_invoice_total_lbl").text(total_balance.toFixed(2))
    jQuery("#log_invoice_total_lbl").formatCurrency({symbol: window.currency_symbol})

  # Apply discount percentage on subtotals
  applyDiscount = (subtotal) ->
    discount_percentage = jQuery("#invoice_discount_percentage").val() #|| jQuery("#recurring_profile_discount_percentage").val()
    discount_type = jQuery("select#discount_type").val()
    #console.log(subtotal*(parseFloat(discount_percentage)/100.0))
    #console.log(discount_type)
    #alert(subtotal)
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
  jQuery(".log_invoice_grid_fields").on "change", "select.items_list", ->
    updateInvoiceTotal()

  # Add empty line item row
#  addLineItemRow = (elem) ->
#    if elem.parents('tr.fields').next('tr.fields:visible').length is 0
#      jQuery(".log_invoice_grid_fields .add_nested_fields").click()
#  #applyChosen(jQuery('.invoice_grid_fields tr.fields:last .chzn-select'))

  jQuery(".log_invoice_grid_fields").on "click", ".add_nested_fields", ->
    setTimeout "window.applyChosen(jQuery('.log_invoice_grid_fields tr.fields:last .chzn-select'))", 0

  # Re calculate the total invoice balance if an item is removed
  jQuery("body").on "click", ".remove_nested_fields", ->
    setTimeout (->
      updateInvoiceTotal()
    ), 100

  # Subtract discount percentage from subtotal
  jQuery("#invoice_discount_percentage, #recurring_profile_discount_percentage").on "blur keyup", ->
    updateInvoiceTotal()

  # Subtract discount percentage from subtotal
  jQuery("select#discount_type").change ->
    updateInvoiceTotal()

  # Don't allow nagetive value for discount
  jQuery("#invoice_discount_percentage, #recurring_profile_discount_percentage,.qty").keydown (e) ->
    if e.keyCode is 109 or e.keyCode is 13
      e.preventDefault()
      false

  # Don't allow paste and right click in discount field
  jQuery("#invoice_discount_percentage, #recurring_profile_discount_percentage, .qty").bind "paste contextmenu", (e) ->
    e.preventDefault()

  # Add date picker to invoice date , invoice due date and payment date.
  jQuery("#log_invoice_date, #invoice_due_date, .date_picker_class").datepicker
    dateFormat: DateFormats.format()
    beforeShow: (input, inst) ->
      widget = jQuery(inst).datepicker('widget')
      widget.css('margin-left', jQuery(input).outerWidth() - widget.outerWidth())

  # Makes the invoice line item list sortable
  jQuery("#log_invoice_grid_fields tbody").sortable
    handle: ".sort_icon"
    items: "tr.fields"
    axis: "y"

  # Calculate line total and invoice total on page load
  jQuery(".log_invoice_grid_fields tr:visible .line_total").each ->
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


  jQuery(".project-invoice.form-horizontal").submit ->

    flag = true
    if jQuery("#invoice_due_date").val() is "" or !DateFormats.validate_date(jQuery("#invoice_due_date").val())
      applyPopover(jQuery("#invoice_due_date"),"rightTop","leftMiddle","Make sure date format is in '#{DateFormats.format()}' format")
      flag = false
    else
      hidePopover(jQuery("#invoice_due_date"))
    return flag


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
        text: "<a href='/en/invoices/new/#{id}'>To create new invoice use the last invoice send to '#{client_name}'.</a><span class='close_qtip'>x</span>"
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

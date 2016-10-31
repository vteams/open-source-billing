# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->


#  Calculate the line total for invoice
  updateLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    cost = $(container).find("input.cost").val()
    qty = $(container).find("input.qty").val()
    cost = 0 if not cost? or cost is "" or not jQuery.isNumeric(cost)
    qty = 0 if not qty? or qty is "" or not jQuery.isNumeric(qty)
    line_total = ((parseFloat(cost) * parseFloat(qty))).toFixed(2)
    $(container).find(".line_total").text(line_total)

  # Calculate grand total from line totals
  updateInvoiceTotal = ->
    total = 0
    tax_amount = 0
    discount_amount = 0
    $("table.log_invoice_grid_fields tr:visible .line_total").each ->
      line_total = parseFloat($(this).text())
      total += line_total
      #update invoice sub total lable and hidden field
      $("#log_invoice_sub_total, #recurring_profile_sub_total").val(total.toFixed(2))
      $("#log_invoice_sub_total_lbl").text(total.toFixed(2))

      #update invoice total lable and hidden field
      $("#log_invoice_total, #recurring_profile_invoice_total").val(total.toFixed(2))
      $("#log_invoice_total_lbl").text(total.toFixed(2))

    #  tax_amount += applyTax(line_total,$(this))

    discount_amount = applyDiscount(total)
    #console.log(discount_amount)
    #alert(total.toFixed(2))
    #update tax amount label and tax amount hidden field
    #$("#invoice_tax_amount_lbl").text(tax_amount.toFixed(2))
    #$("#invoice_tax_amount, #recurring_profile_tax_amount").val(tax_amount.toFixed(2))

    #update discount amount lable and discount hidden field
    $("#invoice_discount_amount_lbl").text(discount_amount)
    $("#invoice_discount_amount, #recurring_profile_discount_amount").val((discount_amount * -1).toFixed(2))
    #console.log($("#log_invoice_total_lbl").text())
    total_balance = (parseFloat($("#log_invoice_total_lbl").text() - discount_amount) + tax_amount)
    #console.log(total_balance)
    $("#log_invoice_total, #recurring_profile_invoice_total").val(total_balance.toFixed(2))
    $("#log_invoice_total_lbl").text(total_balance.toFixed(2))
    $("#log_invoice_total_lbl").formatCurrency({symbol: window.currency_symbol})

  # Apply discount percentage on subtotals
  applyDiscount = (subtotal) ->
    discount_percentage = $("#invoice_discount_percentage").val() #|| $("#recurring_profile_discount_percentage").val()
    discount_type = $("select#discount_type").val()
    #console.log(subtotal*(parseFloat(discount_percentage)/100.0))
    #console.log(discount_type)
    #alert(subtotal)
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    if discount_type == "%" then (subtotal * (parseFloat(discount_percentage) / 100.0)) else discount_percentage

  # Update line and grand total if line item fields are changed
  $("input.cost, input.qty").on "blur",null, ->
    updateLineTotal($(this))
    updateInvoiceTotal()

  $("input.cost, input.qty").on "keyup",null, ->
    updateLineTotal($(this))
    updateInvoiceTotal()
  #$(this).popover "hide"

  # Update line and grand total when tax is selected from dropdown
  $("select.tax1, select.tax2").on "change",null, ->
    updateInvoiceTotal()

  # Prevent form submission if enter key is press in cost,quantity or tax inputs.
  $("input.cost, input.qty").on "keypress",null, (e) ->
    if e.which is 13
      e.preventDefault()
      false

  # Load Items data when an item is selected from dropdown list
  $(".log_invoice_grid_fields").on "change",'select.items_list', ->
    updateInvoiceTotal()

  # Add empty line item row
#  addLineItemRow = (elem) ->
#    if elem.parents('tr.fields').next('tr.fields:visible').length is 0
#      $(".log_invoice_grid_fields .add_nested_fields").click()
#  #applyChosen($('.invoice_grid_fields tr.fields:last .chzn-select'))

  $(".log_invoice_grid_fields").on "click",'.add_nested_fields', ->
    setTimeout "window.applyChosen($('.log_invoice_grid_fields tr.fields:last .chzn-select'))", 0

  # Re calculate the total invoice balance if an item is removed
  $(".remove_nested_fields").on "click",null, ->
    setTimeout (->
      updateInvoiceTotal()
    ), 100

  # Subtract discount percentage from subtotal
  $("#invoice_discount_percentage, #recurring_profile_discount_percentage").on "blur keyup", ->
    updateInvoiceTotal()

  # Subtract discount percentage from subtotal
  $("select#discount_type").change ->
    updateInvoiceTotal()

  # Don't allow nagetive value for discount
  $("#invoice_discount_percentage, #recurring_profile_discount_percentage,.qty").keydown (e) ->
    if e.keyCode is 109 or e.keyCode is 13
      e.preventDefault()
      false

  # Don't allow paste and right click in discount field
  $("#invoice_discount_percentage, #recurring_profile_discount_percentage, .qty").bind "paste contextmenu", (e) ->
    e.preventDefault()

  # Add date picker to invoice date , invoice due date and payment date.
  $("#log_invoice_date, #invoice_due_date, .date_picker_class").datepicker
    dateFormat: DateFormats.format()
    beforeShow: (input, inst) ->
      widget = $(inst).datepicker('widget')
      widget.css('margin-left', $(input).outerWidth() - widget.outerWidth())

  # Makes the invoice line item list sortable
  $("#log_invoice_grid_fields tbody").sortable
    handle: ".sort_icon"
    items: "tr.fields"
    axis: "y"

  # Calculate line total and invoice total on page load
  $(".log_invoice_grid_fields tr:visible .line_total").each ->
    updateLineTotal($(this))
    # dont use decimal points in quantity and make cost 2 decimal points
    container = $(this).parents("tr.fields")
    cost = $(container).find("input.cost")
    qty = $(container).find("input.qty")
    cost.val(parseFloat(cost.val()).toFixed(2)) if cost.val()
    qty.val(parseInt(qty.val())) if qty.val()
  updateInvoiceTotal()

  # dispute popup validation
  $("form.dispute_form").submit ->
    flag = true
    if $("#reason_for_dispute").val() is ""
      applyPopover($("#reason_for_dispute"),"bottomMiddle","topLeft","Enter reason for dispute")
      flag = false
    flag
  $("#reason_for_dispute").on "keyup",null, ->
    $(this).qtip("hide")


  $(".project-invoice.form-horizontal").submit ->

    flag = true
    if $("#invoice_due_date").val() is "" or !DateFormats.validate_date($("#invoice_due_date").val())
      applyPopover($("#invoice_due_date"),"rightTop","leftMiddle","Make sure date format is in '#{DateFormats.format()}' format")
      flag = false
    else
      hidePopover($("#invoice_due_date"))
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
    qtip = $(".qtip.use_as_template")
    qtip.css("top",qtip.offset().top - qtip.height())
    qtip.attr('data-top',qtip.offset().top - qtip.height())
    elem.focus()

  hidePopover = (elem) ->
    #elem.next(".popover").hide()
    elem.qtip("hide")

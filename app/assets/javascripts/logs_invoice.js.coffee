# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
class @LogInvoice

  applyDatePicker = ->
    $('#invoice_date').pickadate
      format: DateFormats.format()
      formatSubmit: DateFormats.format()
      onSet: (context) ->
        value = @get('value')
        $('#invoice_date').html value
        $('#invoice_invoice_date').val value

    $('#invoice_due_date_text').pickadate
      format: DateFormats.format()
      formatSubmit: DateFormats.format()
      onSet: (context) ->
        value = @get('value')
        hidePopover($('#invoice_due_date_text'))
        $('#invoice_due_date_text').html value
        $('#invoice_due_date').val value

  getInvoiceTax = (total) ->
    tax_percentage = parseFloat($("#invoice_tax_id option:selected").data('tax_percentage'))
    total * (parseFloat(tax_percentage) / 100.0)

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
    discount_percentage = $("#invoice_discount_percentage").val()
    discount_type = $("select#discount_type").val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    if discount_type == "%" then (subtotal * (parseFloat(discount_percentage) / 100.0)) else discount_percentage

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
    invoice_tax_amount = 0.0
    $('table.invoice_grid_fields tr:visible .line_total').each ->
      line_total = parseFloat($(this).text())
      total += line_total
      $('#invoice_sub_total').val total.toFixed(2)
      $('#invoice_sub_total_lbl').text total.toFixed(2)
      $('#invoice_invoice_total').val total.toFixed(2)
      $('#invoice_total_lbl').text total.toFixed(2)
      $('.invoice_total_strong').html total.toFixed(2)
      tax_amount += applyTax(line_total, $(this))
    discount_amount = applyDiscount(total)

    $('#tax_amount_lbl').text tax_amount.toFixed(2)
    $('#invoice_tax_amount').val tax_amount.toFixed(2)
    $('#invoice_discount_amount_lbl').text discount_amount.toFixed(2)
    $('#invoice_discount_amount').val (discount_amount * -1).toFixed(2)
    total_balance = parseFloat($('#invoice_total_lbl').text() - discount_amount) + tax_amount

    if $('#invoice_tax_id').val() != ""
      invoice_tax_amount = getInvoiceTax(total_balance).toFixed(2)
      $("#invoice_invoice_tax_amount").val invoice_tax_amount
    else
      $("#invoice_invoice_tax_amount").val invoice_tax_amount

    invoice_tax_amount = parseFloat(invoice_tax_amount)
    total_balance += invoice_tax_amount
    $('#invoice_invoice_total').val total_balance.toFixed(2)
    $('#invoice_total_lbl').text total_balance.toFixed(2)
    $('.invoice_total_strong').html total_balance.toFixed(2)
    $('#invoice_total_lbl').formatCurrency symbol: window.currency_symbol

  applyPopover = (elem,position,corner,message) ->
    console.log message
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

  hidePopover = (elem) ->
    #elem.next(".popover").hide()
    elem.qtip("hide")

  @load_functions = ->


    $('.modal').modal complete: ->
      $('.qtip').remove()

    applyDatePicker();
    $('select').material_select();

    $("#invoice_discount_percentage").on "blur keyup", ->
      hidePopover($('#invoice_discount_percentage'));
      updateInvoiceTotal()

    $("#invoice_tax_id").on 'change', ->
      updateInvoiceTotal()

    $("select#discount_type").change ->
      updateInvoiceTotal()

    # Don't allow paste and right click in discount field
    $("#invoice_discount_percentage, #recurring_profile_discount_percentage, .qty").bind "paste contextmenu", (e) ->
      e.preventDefault()

    # Don't allow nagetive value for discount
    $("#invoice_discount_percentage, #recurring_profile_discount_percentage,.qty").keydown (e) ->
      if e.keyCode is 109 or e.keyCode is 13
        e.preventDefault()
        false

    jQuery(".project-invoice.form-horizontal").submit ->
      flag = true
      if jQuery("#invoice_due_date").val() is "" or !DateFormats.validate_date(jQuery("#invoice_due_date").val())
        applyPopover($('#invoice_due_date_text'),"rightTop","leftMiddle","Select due date")
        flag = false
      else
        hidePopover($('#invoice_due_date_text'))
      return flag

class @Estimate

  # Calculate the line total for invoice
  updateLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    cost = $(container).find("input.cost").val()
    qty = $(container).find("input.qty").val()
    cost = 0 if not cost? or cost is "" or not $.isNumeric(cost)
    qty = 0 if not qty? or qty is "" or not $.isNumeric(qty)
    line_total = ((parseFloat(cost) * parseFloat(qty))).toFixed(2)
    $(container).find(".line_total").text(line_total)

  # Calculate grand total from line totals
  updateInvoiceTotal = ->
    total = 0
    tax_amount = 0
    discount_amount = 0
    $('table.estimate_grid_fields tr:visible .line_total').each ->
      line_total = parseFloat($(this).text())
      total += line_total
      tax_amount += applyTax(line_total, $(this))
    discount_amount = applyDiscount(total)

    $('#estimate_sub_total').val total.toFixed(2)
    $('#estimate_sub_total_lbl').text total.toFixed(2)
    $('#estimate_estimate_total').val total.toFixed(2)
    $('#estimate_total_lbl').text total.toFixed(2)
    $('.estimate_total_strong').html total.toFixed(2)
    $('#tax_amount_lbl').text tax_amount.toFixed(2)
    $('#estimate_tax_amount').val tax_amount.toFixed(2)
    $('#estimate_discount_amount_lbl').text discount_amount.toFixed(2)
    $('#estimate_discount_amount').val (discount_amount * -1).toFixed(2)
    total_balance = parseFloat($('#estimate_total_lbl').text() - discount_amount) + tax_amount
    $('#estimate_estimate_total').val total_balance.toFixed(2)
    $('#estimate_total_lbl').text total_balance.toFixed(2)
    $('.estimate_total_strong').html total_balance.toFixed(2)
    $('#estimate_total_lbl').formatCurrency symbol: window.currency_symbol

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
    discount_percentage = $("#estimate_discount_percentage").val()
    discount_type = $("select#discount_type").val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    if discount_type == "%" then (subtotal * (parseFloat(discount_percentage) / 100.0)) else parseFloat(discount_percentage)

  updateLineTotal = (elem) ->
    container = elem.parents('tr.fields')
    cost = $(container).find('input.cost').val()
    qty = $(container).find('input.qty').val()
    if cost == null or cost == '' or !$.isNumeric(cost)
      cost = 0
    if qty == null or qty == '' or !$.isNumeric(qty)
      qty = 0
    line_total = (parseFloat(cost) * parseFloat(qty))
    tax = parseFloat($(container).find("input.tax1").val())
    if tax > 0
      line_total = line_total + (line_total * parseFloat($(container).find("input.tax-amount").val()) / 100.0)
    $(container).find('.line_total').text line_total.toFixed(2)

  clearLineTotal = (elem) ->
    container = elem.parents('tr.fields')
    container.find('input.description').val ''
    container.find('input.cost').val ''
    container.find('input.qty').val ''
    container.find('select.tax1,select.tax2').val('').trigger 'liszt:updated'
    updateLineTotal elem
    updateInvoiceTotal

  addLineItemRow = (elem) ->
    if elem.parents('tr.fields').next('tr.fields:visible').length == 1
      $('.estimate_grid_fields .add_nested_fields').click()

  empty_tax_fields = (tax_container) ->
    tax_container.find('input.tax1').val ''
    tax_container.find('input.tax2').val ''
    tax_container.find('td.tax1').html ''
    tax_container.find('td.tax1').html ''
    $('.taxes_total').remove()

  @change_estimate_item  = ->
    $('.estimate_grid_fields select.items_list').on 'change', ->
      hidePopover($("table#estimate_grid_fields tr.fields:visible:first"));
      elem = $(this)
      if elem.val() == ''
        clearLineTotal elem
        false
      else
        #addLineItemRow(elem);
        $.ajax '/items/load_item_data',
          type: 'POST'
          data: 'id=' + $(this).val()
          dataType: 'html'
          error: (jqXHR, textStatus, errorThrown) ->
            alert 'Error: ' + textStatus
          success: (data, textStatus, jqXHR) ->
            item = JSON.parse(data)
            container = elem.parents('tr.fields')
            container.find('input.description').val item[0]
            container.find('td.description').html item[0]
            container.find('input.cost').val item[1].toFixed(2)
            container.find('td.cost').html item[1].toFixed(2)
            container.find('input.qty').val item[2]
            container.find('td.qty').html item[2]
            empty_tax_fields(container)
            if item[3] != 0
              container.find('input.tax1').val item[3]
              container.find('input.tax-amount').val item[8]
              container.find('td.tax1').html item[6]
            if item[4] != 0
              container.find('input.tax2').val item[4]
              container.find('input.tax-amount').val item[9]
              container.find('td.tax2').html item[7]
            container.find('input.item_name').val item[5]
            updateLineTotal elem
            updateInvoiceTotal()

  setDuedate = (estimate_date, term_days) ->
    if term_days != null and estimate_date != null
      estimate_due_date = DateFormats.add_days_in_formated_date(estimate_date, parseInt(term_days))
      $('#estimate_due_date_text').html estimate_due_date
      $('#estimate_due_date').val estimate_due_date
    else
      $('#estimate_due_date').val ''

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

  useAsTemplatePopover = (elem,id,client_name) ->
    elem.qtip
      content:
        text: "<a href='/en/estimates/new/#{id}'>" + I18n.t('views.estimates.use_last_estimate_to_create', client_name: client_name) + "</a><span class='close_qtip'>x</span>"
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

  @changeTax = ->
    $('select.tax1, select.tax2').on 'change', ->
      hidePopover($('.select-wrapper.tax2'));
      updateInvoiceTotal()

  @load_functions = ->

    $('.modal').modal complete: ->
      $('.qtip').remove()

    $('select').material_select();

    # Update line and grand total if line item fields are changed
    jQuery("input.cost, input.qty").on "blur", ->
      updateLineTotal(jQuery(this))
      updateInvoiceTotal()

    jQuery("input.cost, input.qty").on "keyup", ->
      updateLineTotal(jQuery(this))
      updateInvoiceTotal()

    # Re calculate the total estimate balance if an item is removed
    $(".remove_nested_fields").on "click", ->
      setTimeout (->
        updateInvoiceTotal()
      ), 100

    setDuedate($("#estimate_estimate_date").val(),$("#estimate_payment_terms_id option:selected").attr('number_of_days'))

    # Subtract discount percentage from subtotal
    $("#estimate_discount_percentage, #recurring_profile_discount_percentage").on "blur keyup", ->
      hidePopover($('#estimate_discount_percentage'));
      updateInvoiceTotal()

    # Subtract discount percentage from subtotal
    $("select#discount_type").change ->
      updateInvoiceTotal()

    # Don't allow paste and right click in discount field
    $("#estimate_discount_percentage, #recurring_profile_discount_percentage, .qty").bind "paste contextmenu", (e) ->
      e.preventDefault()

    # Don't allow nagetive value for discount
    $("#estimate_discount_percentage, #recurring_profile_discount_percentage,.qty").keydown (e) ->
      if e.keyCode is 109 or e.keyCode is 13
        e.preventDefault()
        false

    # re calculate estimate due date on estimate date change
    $("#estimate_estimate_date").change ->
      $(this).qtip("hide") if $(this).qtip()
      term_days = $("#estimate_payment_terms_id option:selected").attr('number_of_days')
      setDuedate($(this).val(),term_days)

    # Calculate line total and estimate total on page load
    $(".estimate_grid_fields tr:visible .line_total").each ->
      updateLineTotal($(this))
      # dont use decimal points in quantity and make cost 2 decimal points
      container = $(this).parents("tr.fields")
      cost = $(container).find("input.cost")
      qty = $(container).find("input.qty")
      cost.val(parseFloat(cost.val()).toFixed(2)) if cost.val()
      qty.val(parseInt(qty.val())) if qty.val()

    updateInvoiceTotal()
    $('.remove_nested_fields').on 'click', ->
      setTimeout (->
        updateInvoiceTotal()
      ), 100
    $('#estimate_grid_fields tbody').sortable
      handle: '.sort_icon'
      items: 'tr.fields'
      axis: 'y'
    $('#estimate_payment_terms_id').unbind 'change'
    $('#estimate_payment_terms_id').change ->
      number_of_days = undefined
      number_of_days = $('option:selected', this).attr('number_of_days')
      setDuedate $('#estimate_estimate_date').val(), number_of_days
    $('#estimate_discount_percentage, #recurring_profile_discount_percentage,.qty').keydown (e) ->
      if e.keyCode == 109 or e.keyCode == 13
        e.preventDefault()
        return false
      return
    $('#estimate_discount_percentage, #recurring_profile_discount_percentage, .qty').bind 'paste contextmenu', (e) ->
      e.preventDefault()

    $("#estimate_client_id").change ->
      hidePopover($("#estimate_client_id").parents('.select-wrapper'));
    # Change currency of estimate
    $("#estimate_currency_id").unbind 'change'
    $("#estimate_currency_id").change ->
      currency_id = $(this).val()
      hidePopover($("#estimate_currency_id_chzn")) if currency_id is ""
      if not currency_id? or currency_id isnt ""
        $.get('/estimates/selected_currency?currency_id='+ currency_id)

    # Validate client, cost and quantity on estimate save
    $(".estimate-form.form-horizontal").submit ->
      discount_percentage = $("#estimate_discount_percentage").val() || $("#recurring_profile_discount_percentage").val()
      discount_type = $("select#discount_type").val()
      sub_total = $('#estimate_sub_total').val()
      discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
      item_rows = $("table#estimate_grid_fields tr.fields:visible")
      flag = true
      # Check if company is selected
      if $("#estimate_company_id").val() is ""
        applyPopover($("#estimate_company_id_chzn"),"bottomMiddle","topLeft", I18n.t('views.invoices.select_a_company'))
        flag = false
        # Check if client is selected
      else if $("#estimate_client_id").val() is ""
        applyPopover($("#estimate_client_id").parents('.select-wrapper'),"bottomMiddle","topLeft",I18n.t('views.invoices.select_a_client'))
        flag = false
        # if currency is not selected
      else if $("#estimate_currency_id").val() is "" and $("#estimate_currency_id").is( ":hidden" ) == false
        applyPopover($("#estimate_currency_id_chzn"),"bottomMiddle","topLeft",I18n.t('views.invoices.select_currency'))
        flag = false
        # check if estimate date is selected
      else if $("#estimate_estimate_date").val() is ""
        applyPopover($("#estimate_estimate_date"),"rightTop","leftMiddle",I18n.t('views.estimates.select_estimate_date'))
        flag =false
        # Check if discount percentage is an integer
      else if $("input#estimate_discount_percentage").val()  isnt "" and ($("input#estimate_discount_percentage").val() < 0)
        applyPopover($("#estimate_discount_percentage"),"bottomMiddle","topLeft",I18n.t('views.invoices.enter_valid_discount'))
        flag = false
        # Check if no item is selected
      else if $("tr.fields:visible").length < 1
        applyPopover($("#add_line_item"),"bottomMiddle","topLeft",I18n.t('views.invoices.add_line_item'))
        flag = false
        # Check if item is selected
      else if item_rows.find("select.items_list option:selected[value='']").length is item_rows.length
        first_item = $("table#estimate_grid_fields tr.fields:visible:first td:nth-child(2)")
        applyPopover(first_item,"bottomMiddle","topLeft",I18n.t('views.invoice_line_item.select_an_item'))
        flag = false
      else if discount_type == '%' and parseFloat(discount_percentage) > 100.00
        applyPopover($("#estimate_discount_percentage"),"bottomMiddle","topLeft",I18n.t('views.invoices.percentage_must_be_hundred_or_less'))
        flag = false
      else if discount_type != '%' and parseFloat(discount_percentage) > parseFloat(sub_total)
        applyPopover($("#estimate_discount_percentage"),"bottomMiddle","topLeft",I18n.t('views.invoices.discount_must_be_less_than_sub_total'))
        flag = false

        # Item cost and quantity should be greater then 0
      else
        $("tr.fields:visible").each ->
          row = $(this)
          if row.find("select.items_list").val() isnt ""
            cost = row.find(".cost")
            qty =  row.find(".qty")
            tax1 = row.find("select.tax1")
            tax2 = row.find("select.tax2")
            tax1_value = $("option:selected",tax1).val()
            tax2_value = $("option:selected",tax2).val()

            if not $.isNumeric(cost.val()) and cost.val() isnt ""
              applyPopover(cost,"bottomLeft","topLeft",I18n.t('views.invoices.enter_valid_item_cost'))
              flag = false
            else hidePopover(cost)

            if not $.isNumeric(qty.val())  and qty.val() isnt ""
              applyPopover(qty,"bottomLeft","topLeft",I18n.t('views.invoices.enter_valid_item_quantity'))
              flag = false
            else hidePopover(qty)
      flag
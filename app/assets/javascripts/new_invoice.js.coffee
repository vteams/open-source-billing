class @Invoice

  applyDatePicker = ->
    $('#invoice_date_picker').pickadate
      format: DateFormats.format()
      formatSubmit: DateFormats.format()
      onSet: (context) ->
        value = @get('value')
        $('#invoice_date').html value
        $('#invoice_invoice_date').val value
        $('#next_invoice_date').html value
        $('#invoice_recurring_schedule_attributes_next_invoice_date').val value

    $("#next_invoice_date_picker").pickadate
      format: DateFormats.format()
      formatSubmit: DateFormats.format()
      onSet: (context) ->
        value = @get('value')
        $('#next_invoice_date').html value
        $('#invoice_recurring_schedule_attributes_next_invoice_date').val value

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
    invoice_tax_amount = 0.0
    $('table.invoice_grid_fields tr:visible .line_total').each ->
      line_total = parseFloat($(this).text())
      total += line_total
      tax_amount += applyTax(line_total, $(this))
    discount_amount = applyDiscount(total)

    $('#invoice_sub_total').val total.toFixed(2)
    $('#invoice_sub_total_lbl').text total.toFixed(2)
    $('#invoice_invoice_total').val total.toFixed(2)
    $('#invoice_total_lbl').text total.toFixed(2)
    $('.invoice_total_strong').html total.toFixed(2)
    $('#tax_amount_lbl').text tax_amount.toFixed(2)
    $('#invoice_tax_amount').val tax_amount.toFixed(2)
    $('#invoice_discount_amount').val (discount_amount * -1).toFixed(2)
    total_balance = parseFloat($('#invoice_total_lbl').text() - discount_amount)

    if $('#invoice_tax_id').val() != ""
      invoice_tax_amount = getInvoiceTax(total_balance).toFixed(2)
      $("#invoice_invoice_tax_amount").val invoice_tax_amount
    else
      $("#invoice_invoice_tax_amount").val invoice_tax_amount

    invoice_tax_amount = parseFloat(invoice_tax_amount)
    total_balance += (invoice_tax_amount + tax_amount)
    $('#invoice_invoice_total').val total_balance.toFixed(2)
    $('#invoice_total_lbl').text total_balance.toFixed(2)
    $('.invoice_total_strong').html total_balance.toFixed(2)
    $("#invoice_sub_total_lbl, #invoice_total_lbl, .tax_amount").formatCurrency({symbol: window.currency_symbol})
    window.taxByCategory()

  getInvoiceTax = (total) ->
    tax_percentage = parseFloat($("#invoice_tax_id option:selected").data('tax_percentage'))
    total * (parseFloat(tax_percentage) / 100.0)

  # Apply Tax on totals
  applyTax = (line_total,elem) ->
    tax1 = elem.parents("tr").find("input#tax_amount").val()
    tax1 = 0 if not tax1? or tax1 is ""
    # if line total is 0
    tax1=0 if line_total is 0
    total_tax = parseFloat(tax1)
    (line_total) * (parseFloat(total_tax) / 100.0)

  # Apply discount percentage on subtotals
  applyDiscount = (subtotal) ->
    discount_percentage = $("#invoice_discount_percentage").val()
    discount_type = $("select#discount_type").val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    if discount_type == "%" then (subtotal * (parseFloat(discount_percentage) / 100.0)) else discount_percentage

  updateLineTotal = (elem) ->
    container = elem.parents('tr.fields')
    cost = $(container).find('input.cost').val()
    qty = $(container).find('input.qty').val()
    if cost == null or cost == '' or !$.isNumeric(cost)
      cost = 0
    if qty == null or qty == '' or !$.isNumeric(qty)
      qty = 0
    line_total = (parseFloat(cost) * parseFloat(qty))
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
      $('.invoice_grid_fields .add_nested_fields').click()

  empty_tax_fields = (tax_container) ->
    tax_container.find('input.tax1').val ''
    tax_container.find('input.tax2').val ''
    tax_container.find('td.tax1').html ''
    tax_container.find('td.tax1').html ''

  @change_invoice_item  = ->
    $('.invoice_grid_fields select.items_list').on 'change', ->
      hidePopover($("table#invoice_grid_fields tr.fields:visible:first td:nth-child(2)"))
      elem = undefined
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

  setDuedate = (invoice_date, term_days) ->
    if term_days != null and invoice_date != null
      if term_days == '0' and $('#invoice_due_date_picker').val() != null
        invoice_due_date_custom = $('#invoice_due_date_picker').val()
        if invoice_due_date_custom isnt ""
          $('#invoice_due_date_text').html invoice_due_date_custom
          $('#invoice_due_date').val invoice_due_date_custom
      else
        invoice_due_date = DateFormats.add_days_in_formated_date(invoice_date, parseInt(term_days))
        $('#invoice_due_date_picker').html invoice_due_date
        $('#invoice_due_date_picker').val invoice_due_date
    else
      $('#invoice_due_date').val ''

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
        text: "<a href='/en/invoices/new/#{id}'> "  + I18n.t('views.invoices.to_create_use_last_sent_invoice',client_name: client_name)+ "</a><span class='close_qtip'>x</span>"
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

    if $('#recurring').is(":checked")
      $("#invoice_recurring_schedule_attributes__destroy").val false
    else
      $("#invoice_recurring_schedule_attributes__destroy").val true

    $('#recurring').on 'click', ->
      if $(this).is(":checked")
        $("#recurring_schedule_container").removeClass('hide_visibility')
        $("#invoice_recurring_schedule_attributes__destroy").val false
      else
        $("#recurring_schedule_container").addClass('hide_visibility')
        $("#invoice_recurring_schedule_attributes__destroy").val true

    # Update line and grand total if line item fields are changed
    jQuery("input.cost, input.qty").on "blur", ->
      updateLineTotal(jQuery(this))
      updateInvoiceTotal()

    jQuery("input.cost, input.qty").on "keyup", ->
      updateLineTotal(jQuery(this))
      updateInvoiceTotal()


    $('.modal').modal complete: ->
      $('.qtip').remove()

    $('select').material_select();

    # Re calculate the total invoice balance if an item is removed
    $(".remove_nested_fields").on "click", ->
      setTimeout (->
        updateInvoiceTotal()
      ), 100

    setDuedate($("#invoice_invoice_date").val(),$("#invoice_payment_terms_id option:selected").attr('number_of_days'))

    # Subtract discount percentage from subtotal
    $("#invoice_discount_percentage, #recurring_profile_discount_percentage").on "blur keyup", ->
      hidePopover($('#invoice_discount_percentage'));
      updateInvoiceTotal()

    $("#invoice_tax_id").on 'change', ->
      updateInvoiceTotal()

    # Subtract discount percentage from subtotal
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

    # re calculate invoice due date on invoice date change
    $("#invoice_invoice_date").change ->
      $(this).qtip("hide") if $(this).qtip()
      term_days = $("#invoice_payment_terms_id option:selected").attr('number_of_days')
      setDuedate($(this).val(),term_days)

    # Calculate line total and invoice total on page load
    $(".invoice_grid_fields tr:visible .line_total").each ->
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
    $('#invoice_payment_terms_id').unbind 'change'
    $('#invoice_payment_terms_id').change ->
      number_of_days = undefined
      number_of_days = $('option:selected', this).attr('number_of_days')
      setDuedate $('#invoice_invoice_date').val(), number_of_days
    $('#invoice_discount_percentage, #recurring_profile_discount_percentage,.qty').keydown (e) ->
      if e.keyCode == 109 or e.keyCode == 13
        e.preventDefault()
        return false
      return
    $('#invoice_discount_percentage, #recurring_profile_discount_percentage, .qty').bind 'paste contextmenu', (e) ->
      e.preventDefault()

    $("#invoice_client_id").change ->
      hidePopover($("#invoice_client_id").parents('.select-wrapper'));
    $("#invoice_due_date_picker").change ->
      hidePopover($("#invoice_due_date_picker"));
    # Change currency of invoice
    $("#invoice_currency_id").unbind 'change'
    $("#invoice_currency_id").change ->
      currency_id = $(this).val()
      hidePopover($("#invoice_currency_id_chzn")) if currency_id is ""
      if not currency_id? or currency_id isnt ""
        $.get('/invoices/selected_currency?currency_id='+ currency_id)
    $('#add_line_item').click ->
      hidePopover($('#add_line_item'))
    # Validate client, cost and quantity on invoice save
    $(".invoice-form.form-horizontal").submit ->
      invoice_date_value = new Date(DateFormats.get_original_date($("#invoice_invoice_date").val()))
      due_date_value = new Date(DateFormats.get_original_date($("#invoice_due_date_picker").val()))
      discount_percentage = $("#invoice_discount_percentage").val() || $("#recurring_profile_discount_percentage").val()
      discount_type = $("select#discount_type").val()
      sub_total = $('#invoice_sub_total').val()
      discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
      item_rows = $("table#invoice_grid_fields tr.fields:visible")
      flag = true
      # Check if company is selected
      if $("#invoice_company_id").val() is ""
        applyPopover($("#invoice_company_id_chzn"),"bottomMiddle","topLeft", I18n.t("views.invoices.select_a_company"))
        flag = false
        # Check if client is selected
      else if $("#invoice_client_id").val() is ""
        applyPopover($("#invoice_client_id").parents('.select-wrapper'),"bottomMiddle","topLeft",I18n.t("views.invoices.select_a_client"))
        flag = false
        # if currency is not selected
      else if $("#invoice_currency_id").val() is "" and $("#invoice_currency_id").is( ":hidden" ) == false
        applyPopover($("#invoice_currency_id_chzn"),"bottomMiddle","topLeft",I18n.t("views.invoices.select_currency"))
        flag = false
        # check if invoice date is selected
      else if $("#invoice_invoice_date").val() is ""
        applyPopover($("#invoice_invoice_date"),"rightTop","leftMiddle",I18n.t("views.invoices.select_invoice_date"))
        flag =false
      else if invoice_date_value > due_date_value
        applyPopover($("#invoice_due_date_picker"),"bottomMiddle","topLeft",I18n.t("views.invoices.due_date_should_equal_or_greater"))
        flag = false
        # Check if payment term is selected
      else if $("#invoice_payment_terms_id").val() is ""
        applyPopover($("#invoice_payment_terms_id_chzn"),"bottomMiddle","topLeft",I18n.t("views.invoices.select_a_payment_term"))
        flag = false
        # Check if discount percentage is an integer
      else if $("input#invoice_discount_percentage").val()  isnt "" and ($("input#invoice_discount_percentage").val() < 0)
        applyPopover($("#invoice_discount_percentage"),"bottomMiddle","topLeft", I18n.t("views.invoices.enter_valid_discount"))
        flag = false
        # Check if no item is selected
      else if $("tr.fields:visible").length < 1
        applyPopover($("#add_line_item"),"bottomMiddle","topLeft",I18n.t("views.invoices.add_line_item"))
        flag = false
        # Check if item is selected
      else if item_rows.find("select.items_list option:selected[value='']").length is item_rows.length
        first_item = $("table#invoice_grid_fields tr.fields:visible:first td:nth-child(2)")
        applyPopover(first_item,"bottomMiddle","topLeft",I18n.t("views.invoice_line_item.select_an_item"))
        flag = false
      else if discount_type == '%' and parseFloat(discount_percentage) > 100.00
        applyPopover($("#invoice_discount_percentage"),"bottomMiddle","topLeft",I18n.t("views.invoices.percentage_must_be_hundred_or_less"))
        flag = false
      else if discount_type != '%' and parseFloat(discount_percentage) > parseFloat(sub_total)
        applyPopover($("#invoice_discount_percentage"),"bottomMiddle","topLeft",I18n.t("views.invoices.discount_must_be_less_than_sub_total"))
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
              applyPopover(cost,"bottomLeft","topLeft",I18n.t("views.invoices.enter_valid_item_cost"))
              flag = false
            else hidePopover(cost)

            if not $.isNumeric(qty.val())  and qty.val() isnt ""
              applyPopover(qty,"bottomLeft","topLeft",I18n.t("views.invoices.enter_valid_item_quantity"))
              flag = false
            else hidePopover(qty)
      flag

jQuery ->
  # for custom payment term
  $('#invoice_due_date_picker').pickadate
    format: DateFormats.format()
    onClose: ->
      custom_option = $('.payment-term-dropdown').find('li:last')
      custom_option.trigger('click') if custom_option.text() is "Custom"

  jQuery('body').on "click", '#select_all', ->
    listing_table =  jQuery(this).parents('table.bordered')
    selected = if @checked then "selected" else ""
    window.listing_table = listing_table
    listing_table.find(':checkbox').prop('checked', @checked).parents('tr').removeClass('selected').addClass(selected)

  unit = $('#invoice_currency_id option:selected').text()

  if unit.length > 0
    $('#subtotal_currency_unit').text(unit)
    $('#discount_amount_currency_unit').text(unit)
    $('#tax_currency_unit').text(unit)
    $('#total_currency_unit').text(unit)
    $selectDropdown = $('#discount_type').empty().html(' ').prop("disabled", false)
    $selectDropdown.append($("<option></option>").attr("value", '%').text("%"))
    $selectDropdown.append($("<option></option>").attr("value", unit).text(unit))
    $selectDropdown.trigger('contentChanged')

  $('select').on 'contentChanged', ->
    $(this).material_select()

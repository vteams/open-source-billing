class @OsbPlugins

  @applyDatePicker = ->
    format = DateFormats.format().toUpperCase()
    $('.date_picker').daterangepicker {
      singleDatePicker: true
      locale: format: format
    }, (start, end, label) ->
      custom_option = $('.payment-term-dropdown').find('li:last')
      custom_option.trigger('click') if custom_option.text() is "Custom"
      return

  @applyPopover = (elem,position,corner,message) ->
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

  @hidePopover = (elem) ->
    elem.qtip("hide")

  @selectUnselectAllCheckboxes = ->
    jQuery('body').on "click", '#select_all', ->
      listing_table =  jQuery(this).parents('table.bordered')
      selected = if @checked then "selected" else ""
      window.listing_table = listing_table
      listing_table.find(':checkbox').prop('checked', @checked).parents('tr').removeClass('selected').addClass(selected)

  @updateMaterializeSelect = ->
    $('select').on 'contentChanged', ->
      $(this).material_select()

  @removeQtipOnModalClose = ->
    $('.modal').modal complete: ->
      $('.qtip').remove()

  @empty_tax_fields = (tax_container) ->
    tax_container.find('select.tax1, select.tax2').val('').select2()

  @load_functions = ->

    OsbPlugins.updateMaterializeSelect()

    if $('#recurring').is(":checked")
      $("#recurring_schedule_container").removeClass('hide_visibility')
      $("#invoice_recurring_schedule_attributes__destroy").val false
    else
      $("#recurring_schedule_container").addClass('hide_visibility')
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
      InvoiceCalculator.updateLineTotal(jQuery(this))
      InvoiceCalculator.updateInvoiceTotal()

    jQuery("input.cost, input.qty").on "keyup", ->
      InvoiceCalculator.updateLineTotal(jQuery(this))
      InvoiceCalculator.updateInvoiceTotal()

    OsbPlugins.removeQtipOnModalClose()
#    $('select').material_select();

    # Re calculate the total invoice balance if an item is removed
    $(".remove_nested_fields").on "click", ->
      setTimeout (->
        InvoiceCalculator.updateInvoiceTotal()
      ), 100
#    Invoice.setInvoiceDueDate($("#invoice_date_picker").val(),$("#invoice_payment_terms_id option:selected").attr('number_of_days'))

    # Subtract discount percentage from subtotal
    $("#invoice_discount_percentage, #recurring_profile_discount_percentage").on "blur keyup", ->
      OsbPlugins.hidePopover($('#invoice_discount_percentage'));
      InvoiceCalculator.updateInvoiceTotal()

    $("#invoice_tax_id").on 'change', ->
      InvoiceCalculator.updateInvoiceTotal()

    # Subtract discount percentage from subtotal
    $("select#discount_type").change ->
      InvoiceCalculator.updateInvoiceTotal()

    # Don't allow paste and right click in discount field
    $("#invoice_discount_percentage, #recurring_profile_discount_percentage, .qty").bind "paste contextmenu", (e) ->
      e.preventDefault()

    # Don't allow nagetive value for discount
    $("#invoice_discount_percentage, #recurring_profile_discount_percentage,.qty").keydown (e) ->
      if e.keyCode is 109 or e.keyCode is 13
        e.preventDefault()
        false

    # re calculate invoice due date on invoice date change
    $("#invoice_date_picker").change ->
      $(this).qtip("hide") if $(this).qtip()
      term_days = $("#invoice_payment_terms_id option:selected").attr('number_of_days')
      Invoice.setInvoiceDueDate($(this).val(),term_days)

    # Calculate line total and invoice total on page load
    $(".invoice_grid_fields tr:visible .line_total").each ->
      InvoiceCalculator.updateLineTotal($(this))
      # dont use decimal points in quantity and make cost 2 decimal points
      container = $(this).parents("tr.fields")
      cost = $(container).find("input.cost")
      qty = $(container).find("input.qty")
      cost.val(parseFloat(cost.val()).toFixed(2)) if cost.val()
      qty.val(qty.val()) if qty.val()

    InvoiceCalculator.updateInvoiceTotal()
    $('.remove_nested_fields').on 'click', ->
      setTimeout (->
        InvoiceCalculator.updateInvoiceTotal()
      ), 100
    $('#invoice_payment_terms_id').unbind 'change'
    $('#invoice_payment_terms_id').change ->
      number_of_days = undefined
      number_of_days = $('option:selected', this).attr('number_of_days')
      Invoice.setInvoiceDueDate $('#invoice_date_picker').val(), number_of_days

    $("#invoice_client_id").change ->
      setTimeout (->
        $(".line_total_currency").html(window.currency_symbol)
        $('.invoice_total_strong').formatCurrency({symbol: window.currency_symbol})
      ), 100
      OsbPlugins.hidePopover($("#invoice_client_id").parents('.select-wrapper'));
    $("#invoice_due_date_picker").change ->
      OsbPlugins.hidePopover($("#invoice_due_date_picker"));
    # Change currency of invoice
    $("#invoice_currency_id").unbind 'change'
    $("#invoice_currency_id").change ->
      currency_id = $(this).val()
      OsbPlugins.hidePopover($("#invoice_currency_id_chzn")) if currency_id is ""
      if not currency_id? or currency_id isnt ""
        $.get('/invoices/selected_currency?currency_id='+ currency_id)
        setTimeout ( ->
          $('.invoice_total_strong').formatCurrency({symbol: window.currency_symbol})
        ), 200
    $('#add_line_item').click ->
      OsbPlugins.hidePopover($('#add_line_item'))
    # Validate client, cost and quantity on invoice save


  @estimate_load_functions = ->

    $('.modal').modal complete: ->
      $('.qtip').remove()

#    $('select').material_select();

    # Update line and grand total if line item fields are changed
    jQuery("input.cost, input.qty").on "blur", ->
      EstimateCalculator.updateLineTotal(jQuery(this))
      EstimateCalculator.updateEstimateTotal()

    jQuery("input.cost, input.qty").on "keyup", ->
      EstimateCalculator.updateLineTotal(jQuery(this))
      EstimateCalculator.updateEstimateTotal()

    # Re calculate the total estimate balance if an item is removed
    $(".remove_nested_fields").on "click", ->
      setTimeout (->
        EstimateCalculator.updateEstimateTotal()
      ), 100

    # Subtract discount percentage from subtotal
    $("#estimate_discount_percentage, #recurring_profile_discount_percentage").on "blur keyup", ->
      OsbPlugins.hidePopover($('#estimate_discount_percentage'));
      EstimateCalculator.updateEstimateTotal()

    $("#estimate_tax_id").on 'change', ->
      EstimateCalculator.updateEstimateTotal()

    # Subtract discount percentage from subtotal
    $("select#discount_type").change ->
      EstimateCalculator.updateEstimateTotal()

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

    # Calculate line total and estimate total on page load
    $(".estimate_grid_fields tr:visible .line_total").each ->
      EstimateCalculator.updateLineTotal($(this))
      # dont use decimal points in quantity and make cost 2 decimal points
      container = $(this).parents("tr.fields")
      cost = $(container).find("input.cost")
      qty = $(container).find("input.qty")
      cost.val(parseFloat(cost.val()).toFixed(2)) if cost.val()
      qty.val(qty.val()) if qty.val()

    EstimateCalculator.updateEstimateTotal()
    $('.remove_nested_fields').on 'click', ->
      setTimeout (->
        EstimateCalculator.updateEstimateTotal()
      ), 100

    $('#estimate_discount_percentage, #recurring_profile_discount_percentage,.qty').keydown (e) ->
      if e.keyCode == 109 or e.keyCode == 13
        e.preventDefault()
        return false
      return
    $('#estimate_discount_percentage, #recurring_profile_discount_percentage, .qty').bind 'paste contextmenu', (e) ->
      e.preventDefault()

    $("#estimate_client_id").change ->
      OsbPlugins.hidePopover($("#estimate_client_id").parents('.info-left-section').find('.select2-container'));
    $("#add_line_item").click ->
      OsbPlugins.hidePopover($("#add_line_item"))
    # Change currency of estimate
    $("#estimate_currency_id").unbind 'change'
    $("#estimate_currency_id").change ->
      currency_id = $(this).val()
      OsbPlugins.hidePopover($("#estimate_currency_id_chzn")) if currency_id is ""
      if not currency_id? or currency_id isnt ""
        $.get('/estimates/selected_currency?currency_id='+ currency_id)


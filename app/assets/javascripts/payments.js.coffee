class @Payment

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
    elem.qtip("hide")

  applyDatePicker = ->
    format = DateFormats.format().toUpperCase()
    $('#payment_payment_date').daterangepicker {
      singleDatePicker: true
      locale: format: format
    }, (start, end, label) ->
      $('#payment_payment_date').val start.format(format)
      return

  @load_functions = ->
    applyDatePicker();
    $('.modal').modal complete: ->
      $('.qtip').remove()

#    $('select').material_select();

    #Autocomplete amount field on paid full checkbox
    $("#payment_paid_full").on "click", ->
      rem_value = parseFloat($('.rem_payment_amount').attr('value'))
      if $(this).is ":checked"
        $('#payment_payment_amount').val(rem_value)
        $('#payment_payment_amount').attr('readonly', 'readonly')
      else
        $('#payment_payment_amount').removeAttr('readonly')
        $('#payment_payment_amount').val('')

    $("#payment_payment_amount").on "blur keyup", ->
      hidePopover($('#payment_payment_amount'))

    jQuery('.payment_form.form-horizontal').submit ->
      pay_amount = parseFloat(jQuery("#payment_payment_amount").val())
      pay_method = jQuery("#payment_payment_method").val()
      rem_amount = parseFloat(jQuery(".rem_payment_amount").attr("value"))
      rem_credit = parseFloat(jQuery("#rem_credit").attr("value"))
      if jQuery("#payment_payment_amount").val() is ""
        applyPopover(jQuery("#payment_payment_amount"), "rightbottom", "leftMiddle", I18n.t("views.payments.value_greater_than_zero_msg"))
        flag = false
      else if pay_amount <= 0
        applyPopover(jQuery("#payments_payment_amount"), "rightbottom", "leftMiddle", I18n.t("views.payments.negative_value_not_allowed_msg"))
        flag = false
      else if pay_amount > rem_amount
        applyPopover(jQuery("#payment_payment_amount"), "rightbottom", "leftMiddle", I18n.t("views.payments.exceeded_payment_amount_msg"))
        flag = false
      else if pay_amount > rem_credit and rem_credit
        applyPopover(jQuery("#payment_payment_amount"), "rightbottom", "leftMiddle", I18n.t("views.payments.credit_exceeded_msg"))
        flag = false
      else
        flag = true
      flag



  @refund_functions = ->
    applyDatePicker();
    $('.modal').modal complete: ->
      $('.qtip').remove()

#    $('select').material_select();

    #Autocomplete amount field on paid full checkbox
    if parseFloat(jQuery(".received_payment_amount").attr("value")) == Math.abs(parseFloat(jQuery(".refunds").attr("value")))
      $('#payment_payment_amount').attr('readonly', 'readonly')
      $("#payment_paid_full").attr('disabled', true)
    $("#payment_paid_full").on "click", ->
      rem_value = parseFloat($('.due_refunds').attr('value'))
      if $(this).is ":checked"
        $('#payment_payment_amount').val('-'.concat(rem_value))
        $('#payment_payment_amount').attr('readonly', 'readonly')
      else
        $('#payment_payment_amount').removeAttr('readonly')
        $('#payment_payment_amount').val('')

    $("#payment_payment_amount").on "blur keyup", ->
      hidePopover($('#payment_payment_amount'))

    jQuery('.payment_form.form-horizontal').submit ->
      pay_amount = -Math.abs(parseFloat(jQuery("#payment_payment_amount").val()))
      $('#payment_payment_amount').val(pay_amount)
      pay_method = jQuery("#payment_payment_method").val()
      rem_amount = parseFloat(jQuery(".rem_payment_amount").attr("value"))
      received_amount = parseFloat(jQuery(".received_payment_amount").attr("value"))
      refund = Math.abs(parseFloat(jQuery(".refunds").attr("value")))
      rem_credit = parseFloat(jQuery("#rem_credit").attr("value"))
      if jQuery("#payment_payment_amount").val() is ""
        applyPopover(jQuery("#payment_payment_amount"), "rightbottom", "leftMiddle", I18n.t("views.payments.value_greater_than_zero_msg"))
        flag = false
      else if pay_amount >= 0
        applyPopover(jQuery("#payment_payment_amount"), "rightbottom", "leftMiddle", "value should be negative")
        flag = false
      else if refund - pay_amount > received_amount
        applyPopover(jQuery("#payment_payment_amount"), "rightbottom", "leftMiddle", "value exceeds received amount")
        flag = false
      else if pay_amount > rem_amount
        applyPopover(jQuery("#payment_payment_amount"), "rightbottom", "leftMiddle", I18n.t("views.payments.exceeded_payment_amount_msg"))
        flag = false
      else if pay_amount > rem_credit and rem_credit
        applyPopover(jQuery("#payment_payment_amount"), "rightbottom", "leftMiddle", I18n.t("views.payments.credit_exceeded_msg"))
        flag = false
      else
        flag = true
      flag


jQuery ->

  window.creditPayment()

  flag = true
  jQuery("#close_popup").on "click", ->
    jQuery("#invoices_container").hide()

  #Autocomplete amount field on paid full checkbox
  jQuery(".paid_full").on "click", ->
    rem_value = parseFloat(jQuery(this).next('.rem_payment_amount').attr('value'))
    rem_value_id = jQuery(this).next('.rem_payment_amount').attr('id')
    if jQuery(this).is ":checked"
      jQuery('#payments_' + rem_value_id + '_payment_amount').val(rem_value)
      jQuery('#payments_' + rem_value_id + '_payment_amount').attr('readonly', 'readonly')
    else
      jQuery('#payments_' + rem_value_id + '_payment_amount').removeAttr('readonly')
      jQuery('#payments_' + rem_value_id + '_payment_amount').val('')


  # validate payments fields on enter payment form submit


  jQuery('.submit_payment_form').on "click", ->
    validate = true
    payment_fields = jQuery('.payment_amount')

    # show a message if 0 is entered in payment amount
    payment_fields.each ->
      if parseFloat(jQuery(this).val()) is 0 or parseFloat(jQuery(this).val()) < 0
        jQuery(this).qtip({content: text: I18n.t("views.payments.negative_value_not_allowed_msg"), show: event: false, hide: event: false})
        jQuery(this).focus().qtip().show()
        validate = false
    payment_fields.each ->
      if jQuery(this).val() is ""
        jQuery(this).qtip({content: text: I18n.t("views.payments.value_greater_than_zero_msg"), show: event: false, hide: event: false})
        jQuery(this).focus().qtip().show()
        validate = false
    validate

  jQuery(".line_item_qtip").on "change",->
    jQuery(this).qtip('hide')
  # hide qtip when enter some text in payment field
  jQuery(".payment_amount").keyup ->
    jQuery(this).qtip("hide")

  # show intimation message when no invoice is selected.
  jQuery('#invoice_selection').submit ->
    invoices = jQuery("table.table_listing tbody")
    flag = if invoices.find('tr.no-invoices').length
      jQuery("#invoice_popup_error").show().find('span').html(I18n.t('views.payments.no_unpaid_invoice_msg'))
      false
    else if invoices.find(":checked").length is 0
      jQuery("#invoice_popup_error").show().find('span').html(I18n.t("views.dashboard.selected_amount_detail"))
      false
    else
      true
  # show intimation message when editing credit payment
  window.bind_edit_payment_links = () ->
    jQuery(".payment_listing .edit_action").unbind 'click'
    jQuery(".payment_listing .edit_action").click ->
      flag = true
      if jQuery(this).attr("value") == "credit"
         flag = false
         if jQuery('.alert-success').length > 0
           jQuery('.alert-success').hide()
         jQuery(".alert.alert-error").show().find('span').html(I18n.t('views.payments.cannot_edit_msg'))
      if jQuery(this).hasClass 'disabled'
        flag = false
        if jQuery('.alert-success').length > 0
          jQuery('.alert-success').hide()
        jQuery(".alert.alert-error").show().find('span').html(I18n.t('views.payments.connot_edit_paypal_msg'))
      flag
  window.bind_edit_payment_links()

  if $('[id$="_payment_date"]').length > 0
    $('[id$="_payment_date"]').daterangepicker {
      singleDatePicker: true
      locale: format: DateFormats.format().toUpperCase()
    }
#  $('.select_2').material_select('destroy');
#  $('.select_2').select2();

jQuery ->

  window.creditPayment()

  flag = true
  jQuery("body").on "click", "#close_popup", ->
    jQuery("#invoices_container").hide()

  #Autocomplete amount field on paid full checkbox
  jQuery("body").on "click", ".paid_full", ->
    rem_value = parseFloat(jQuery(this).next('.rem_payment_amount').attr('value'))
    rem_value_id = jQuery(this).next('.rem_payment_amount').attr('id')
    if jQuery(this).is ":checked"
      jQuery('#payments_' + rem_value_id + '_payment_amount').val(rem_value)
      jQuery('#payments_' + rem_value_id + '_payment_amount').attr('readonly', 'readonly')
    else
      jQuery('#payments_' + rem_value_id + '_payment_amount').removeAttr('readonly')
      jQuery('#payments_' + rem_value_id + '_payment_amount').val('')

#  jQuery('#submit_payment_form').live "click", ->
#    console.log "test"
#    flag = true
#    jQuery(".apply_credit:checked").each ->
#      pay_amount = parseFloat(jQuery("#payments_#{@id}_payment_amount").val())
#      rem_credit = parseFloat(jQuery("#rem_credit_#{@id}").attr("value"))
#      rem_value = jQuery(".rem_payment_amount##{@id}").attr("value")
#      if pay_amount > rem_value
#        alert "If applying the account credit, the payment amount cannot exceed the invoice balance."
#        flag = false
#      else if pay_amount > rem_credit
#        alert "Payment from credit cannot exceed available credit."
#        flag = false
#      else
#        flag = true
#    flag
#  #edit payment form check if credit exceed available credit
  jQuery('body').on "click", "#submit_payment_form", ->
    pay_amount = parseFloat(jQuery("#payments_0_payment_amount").val())
    pay_method = jQuery("#payments_0_payment_method").val()
    rem_amount = parseFloat(jQuery(".rem_payment_amount").attr("value"))
    rem_credit = parseFloat(jQuery("#rem_credit_0").attr("value"))
    if jQuery("#payments_0_payment_amount").val() is ""
      applyPopover(jQuery("#payments_0_payment_amount"), "rightbottom", "leftMiddle", "Enter payment value greater than 0.")
      flag = false
    else if pay_amount <= 0
      applyPopover(jQuery("#payments_0_payment_amount"), "rightbottom", "leftMiddle", "Payments with 0 or negivate amount are not allowed. Enter a value greater than 0.")
      flag = false
    else if pay_amount > rem_amount
      applyPopover(jQuery("#payments_0_payment_amount"), "rightbottom", "leftMiddle", "The payment amount cannot exceed the invoice balance.")
      flag = false
    else if pay_amount > rem_credit and rem_credit
      applyPopover(jQuery("#payments_0_payment_amount"), "rightbottom", "leftMiddle", "Payment from credit cannot exceed available credit.")
      flag = false
    else
      flag = true

    if(flag)
      jQuery("form#payments_form").get(0).submit()
    else
      return false
  # validate payments fields on enter payment form submit
#  jQuery('#submit_payment_form').live "click", ->
#    validate = true
#    payment_fields = jQuery('.payment_amount')
#
#    # show a message if 0 is entered in payment amount
#    payment_fields.each ->
#      if parseFloat(jQuery(this).val()) is 0
#        jQuery(this).qtip({content: text: "Payments with 0 amount are not allowed. Either leave it blank to skip or enter a value greater than 0.", show: event: false, hide: event: false})
#        jQuery(this).focus().qtip().show()
#        validate = false
#      else
#        jQuery('.payment_dates').each ->
#          if jQuery(this).val() isnt "" and !DateFormats.validate_date((jQuery(this).val()))
#            applyPopover(jQuery(this), "rightTop", "leftMiddle", "Make sure date format is in '#{DateFormats.format()}' format")
#            validate = false
#    validate

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

  jQuery("body").on "change", ".line_item_qtip",->
    jQuery(this).qtip('hide')
  # hide qtip when enter some text in payment field
  jQuery(".payment_amount").keyup ->
    jQuery(this).qtip("hide")

  # show intimation message when no invoice is selected.
  jQuery('#invoice_selection').submit ->
    invoices = jQuery("table.table_listing tbody")
    flag = if invoices.find('tr.no-invoices').length
      jQuery("#invoice_popup_error").show().find('span').html('There are no unpaid invoices to enter payment against.')
      false
    else if invoices.find(":checked").length is 0
      jQuery("#invoice_popup_error").show().find('span').html("You haven't selected any invoice. Please select one or more invoices and try again.")
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
         jQuery(".alert.alert-error").show().find('span').html("You cannot edit credit payment")
      if jQuery(this).hasClass 'disabled'
        flag = false
        if jQuery('.alert-success').length > 0
          jQuery('.alert-success').hide()
        jQuery(".alert.alert-error").show().find('span').html("You cannot edit payment with paypal")
      flag
  window.bind_edit_payment_links()


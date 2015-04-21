jQuery ->

  window.creditPayment()

  flag = true
  jQuery("#close_popup").live "click", ->
    jQuery("#invoices_container").hide()

  #Autocomplete amount field on paid full checkbox
  jQuery(".paid_full").live "click", ->
    rem_value = parseFloat(jQuery(this).next('.rem_payment_amount').attr('value'))
    rem_value_id = jQuery(this).next('.rem_payment_amount').attr('id')
    if jQuery(this).is ":checked"
      jQuery('#payments_' + rem_value_id + '_payment_amount').val(rem_value)
      jQuery('#payments_' + rem_value_id + '_payment_amount').attr('readonly', 'readonly')
    else
      jQuery('#payments_' + rem_value_id + '_payment_amount').removeAttr('readonly')
      jQuery('#payments_' + rem_value_id + '_payment_amount').val('')

  jQuery('#submit_payment_form').live "click", ->
    flag = true
    jQuery(".apply_credit:checked").each ->
      pay_amount = parseFloat(jQuery("#payments_#{@id}_payment_amount").val())
      rem_credit = parseFloat(jQuery("#rem_credit_#{@id}").attr("value"))
      rem_value = jQuery(".rem_payment_amount##{@id}").attr("value")
      if pay_amount > rem_value
        alert "If applying the account credit, the payment amount cannot exceed the invoice balance."
        flag = false
      else if pay_amount > rem_credit
        alert "Payment from credit cannot exceed available credit."
        flag = false
      else
        flag = true
    flag
  #edit payment form check if credit exceed available credit
  jQuery('#submit_payment_edit_form').live "click", ->
    flag = true
    pay_amount = parseFloat(jQuery("#payments_0_payment_amount").val())
    pay_method = jQuery("#payments_0_payment_method").val()
    rem_amount = parseFloat(jQuery(".rem_payment_amount").attr("value"))
    rem_credit = parseFloat(jQuery("#rem_credit_0").attr("value"))
    if pay_method == "Credit"
      if pay_amount > rem_amount
         alert "If applying the account credit, the payment amount cannot exceed the invoice balance."
         flag = false
      else if pay_amount > rem_credit
         alert "Payment from credit cannot exceed available credit."
         flag = false
    else
      flag = true
    flag

  # validate payments fields on enter payment form submit
  jQuery('#payments_form').submit ->
    validate = true
    payment_fields = jQuery('.payment_amount')

    # show a message if 0 is entered in payment amount
    payment_fields.each ->
      if parseFloat(jQuery(this).val()) is 0
        jQuery(this).qtip({content: text: "Payments with 0 amount are not allowed. Either leave it blank to skip or enter a value greater than 0.", show: event: false, hide: event: false})
        jQuery(this).focus().qtip().show()
        validate = false
    validate

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
         jQuery(".alert.alert-error").show().find('span').html("You cannot edit credit payment")
      flag
  window.bind_edit_payment_links()


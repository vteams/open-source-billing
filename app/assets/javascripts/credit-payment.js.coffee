window.creditPayment = ->
  #Select credit from method dropdown if apply from credit checkbox is checked
  jQuery("body").on "click", ".apply_credit", ->

    apply_credit_id = jQuery(this).attr("id")
    parent = jQuery(this).parents(".pay_invoice")
    payfull = jQuery(".paid_full",parent)

    # make credit option selected in drop if credit checkbox is selected
    credit_selected = if jQuery(this).is ":checked" then "Credit" else ""
    jQuery("#payments_#{apply_credit_id}_payment_method").val(credit_selected).trigger("liszt:updated")

    # if amount due is greate or equal to credit then apply all credit
    credit = jQuery(this).parents('.payment_right').find('.rem_payment_amount');
    payment_field = jQuery("input#payments_#{credit.attr('id')}_payment_amount")

    if jQuery(this).is ":checked"
      credit_amount = parseFloat(jQuery(this).parents('.field_check').find('.credit_amount').text())
      amount_due = parseFloat(credit.attr('value'))

      if amount_due >= credit_amount
        payment_field.val(credit_amount.toFixed(2))
        if payfull.is ":checked"
          payfull.removeAttr('checked')
          payment_field.removeAttr('readonly')
      else if amount_due <= credit_amount
        payment_field.val(amount_due.toFixed(2))
    else
      payment_field.val('') unless payfull.is ":checked"


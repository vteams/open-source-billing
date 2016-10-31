jQuery ->

  window.creditPayment()

  flag = true
  $("#close_popup").on "click",null, ->
    $("#invoices_container").hide()

  #Autocomplete amount field on paid full checkbox
  $(".paid_full").on "click",null, ->
    rem_value = parseFloat($(this).next('.rem_payment_amount').attr('value'))
    rem_value_id = $(this).next('.rem_payment_amount').attr('id')
    if $(this).is ":checked"
      $('#payments_' + rem_value_id + '_payment_amount').val(rem_value)
      $('#payments_' + rem_value_id + '_payment_amount').attr('readonly', 'readonly')
    else
      $('#payments_' + rem_value_id + '_payment_amount').removeAttr('readonly')
      $('#payments_' + rem_value_id + '_payment_amount').val('')

#  $('#submit_payment_form').on "click",null, ->
#    console.log "test"
#    flag = true
#    $(".apply_credit:checked").each ->
#      pay_amount = parseFloat($("#payments_#{@id}_payment_amount").val())
#      rem_credit = parseFloat($("#rem_credit_#{@id}").attr("value"))
#      rem_value = $(".rem_payment_amount##{@id}").attr("value")
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
  $('#submit_payment_form').on "click",null, ->
    pay_amount = parseFloat($("#payments_0_payment_amount").val())
    pay_method = $("#payments_0_payment_method").val()
    rem_amount = parseFloat($(".rem_payment_amount").attr("value"))
    rem_credit = parseFloat($("#rem_credit_0").attr("value"))
    if $("#payments_0_payment_amount").val() is ""
      applyPopover($("#payments_0_payment_amount"), "rightbottom", "leftMiddle", "Enter payment value greater than 0.")
      flag = false
    else if pay_amount <= 0
      applyPopover($("#payments_0_payment_amount"), "rightbottom", "leftMiddle", "Payments with 0 or negivate amount are not allowed. Enter a value greater than 0.")
      flag = false
    else if pay_amount > rem_amount
      applyPopover($("#payments_0_payment_amount"), "rightbottom", "leftMiddle", "The payment amount cannot exceed the invoice balance.")
      flag = false
    else if pay_amount > rem_credit and rem_credit
      applyPopover($("#payments_0_payment_amount"), "rightbottom", "leftMiddle", "Payment from credit cannot exceed available credit.")
      flag = false
    else
      flag = true

    if(flag)
      $("form#payments_form").get(0).submit()
    else
      return false
  # validate payments fields on enter payment form submit
#  $('#submit_payment_form').on "click",null, ->
#    validate = true
#    payment_fields = $('.payment_amount')
#
#    # show a message if 0 is entered in payment amount
#    payment_fields.each ->
#      if parseFloat($(this).val()) is 0
#        $(this).qtip({content: text: "Payments with 0 amount are not allowed. Either leave it blank to skip or enter a value greater than 0.", show: event: false, hide: event: false})
#        $(this).focus().qtip().show()
#        validate = false
#      else
#        $('.payment_dates').each ->
#          if $(this).val() isnt "" and !DateFormats.validate_date(($(this).val()))
#            applyPopover($(this), "rightTop", "leftMiddle", "Make sure date format is in '#{DateFormats.format()}' format")
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

  $(".line_item_qtip").on "change",null, ->
    $(this).qtip('hide')
  # hide qtip when enter some text in payment field
  $(".payment_amount").keyup ->
    $(this).qtip("hide")

  # show intimation message when no invoice is selected.
  $('#invoice_selection').submit ->
    invoices = $("table.table_listing tbody")
    flag = if invoices.find('tr.no-invoices').length
      $("#invoice_popup_error").show().find('span').html('There are no unpaid invoices to enter payment against.')
      false
    else if invoices.find(":checked").length is 0
      $("#invoice_popup_error").show().find('span').html("You haven't selected any invoice. Please select one or more invoices and try again.")
      false
    else
      true
  # show intimation message when editing credit payment
  window.bind_edit_payment_links = () ->
    $(".payment_listing .edit_action").unbind 'click'
    $(".payment_listing .edit_action").click ->
      flag = true
      if $(this).attr("value") == "credit"
         flag = false
         if $('.alert-success').length > 0
           $('.alert-success').hide()
         $(".alert.alert-error").show().find('span').html("You cannot edit credit payment")
      if $(this).hasClass 'disabled'
        flag = false
        if $('.alert-success').length > 0
          $('.alert-success').hide()
        $(".alert.alert-error").show().find('span').html("You cannot edit payment with paypal")
      flag
  window.bind_edit_payment_links()

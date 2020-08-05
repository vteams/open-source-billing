class @Expense

  applyDatePicker = ->
    $('#expense_date_picker').pickadate
      format: DateFormats.format()
      formatSubmit: DateFormats.format()
      onSet: (context) ->
        value = @get('value')
        $('#expense_date').html value
        $('#expense_expense_date').val value

  updateAmountField = ->
    tax1 = jQuery("select.tax1 option:selected").attr('data-tax_1')
    tax2 = jQuery("select.tax2 option:selected").attr('data-tax_1')
    tax1 = 0 if not tax1? or tax1 is ""
    tax2 = 0 if not tax2? or tax2 is ""

    amount1 = jQuery("#amount1")
    amount2 = jQuery("#amount2")
    amount1_text= jQuery('.tax1_amount')
    amount2_text= jQuery('.tax2_amount')

    amount = jQuery("#expense_amount").val() || 0
    amount1_val = (amount*tax1/100).toFixed(2)
    amount2_val = (amount*tax2/100).toFixed(2)
    amount1.val(amount1_val)
    amount2.val(amount2_val)
    amount1_text.html(amount1_val)
    amount2_text.html(amount2_val)

    console.log amount
    console.log amount1_val
    console.log amount2_val

    total = (parseFloat(amount) + parseFloat(amount1_val) + parseFloat(amount2_val)).toFixed(2)
    console.log total
    $(".expense_total_strong").html(total)


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


  hidePopover = (elem) ->
    elem.qtip("hide")

  @load_functions = ->

    $('.modal').modal complete: ->
      $('.qtip').remove()

#    $('select').material_select();

    applyDatePicker();

  # Applied taxes expense
    jQuery("select.tax1, select.tax2").on "change", ->
      updateAmountField()

    jQuery("#expense_amount").on "keyup", ->
      hidePopover(jQuery("#expense_amount"))
      hidePopover($(this))
      updateAmountField()

  # Expense form validation

    jQuery(".expense-form.form-horizontal").submit ->

      expense_category = jQuery("#expense_category_id").val()
      amount = jQuery("#expense_amount").val()
      client = jQuery("#expense_client_id").val()
      expense_date = jQuery('#expense_expense_date').val()

      if client is ""
        applyPopover(jQuery("#expense_client_id").parents('.select-wrapper'),"bottomMiddle","topLeft","Select a client")
        flag = false
      else if expense_category is "" or expense_category is null
        applyPopover(jQuery("#expense_category_id").parents('.select-wrapper'),"bottomMiddle","topLeft","Select a category")
        flag = false
      else if amount is ""
        applyPopover(jQuery("#expense_amount"),"bottomMiddle","topLeft","Insert amount")
        flag = false
      else if amount < 0
        applyPopover(jQuery("#expense_amount"),"bottomMiddle","topLeft","Insert amount greater or equal to 0.")
        flag = false
      else if client is ""
        applyPopover(jQuery("#expense_client_id").parents('.select-wrapper'),"bottomMiddle","topLeft","Select a client")
        flag = false
      else if expense_date is ""
        applyPopover(jQuery("#expense_expense_date"),"bottomMiddle","topLeft","Select expense date")
        flag = false
      else
        hidePopover(jQuery("#expense_expense_date"))
        flag = true
      flag

    $("#expense_client_id, #expense_category_id ").change ->
      hidePopover($(this).parents('.select-wrapper'));
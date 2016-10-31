# Add date picker to expense date
jQuery ->
  $("#expense_expense_date").datepicker
    dateFormat: DateFormats.format()
    beforeShow: (input, inst) ->
      widget = $(inst).datepicker('widget')
      widget.css('margin-left', $(input).outerWidth() - widget.outerWidth())

# Applied taxes expense
  $(".tax_div select.tax1, .tax_div select.tax2").on "change",null, ->
    updateAmountField()

  $("#expense_amount").on "keyup",null, ->
    hidePopover($(this))
    updateAmountField()

  updateAmountField = ->
    tax1 = $(".tax_div select.tax1 option:selected").attr('data-tax_1')
    tax2 = $(".tax_div select.tax2 option:selected").attr('data-tax_1')
    tax1 = 0 if not tax1? or tax1 is ""
    tax2 = 0 if not tax2? or tax2 is ""

    amount1 = $(".amount_div #amount1")
    amount2 = $(".amount_div #amount2")

    amount = $("#expense_amount").val() || 0
    amount1_val = (amount*tax1/100).toFixed(2)
    amount2_val = (amount*tax2/100).toFixed(2)
    amount1.val(amount1_val)
    amount2.val(amount2_val)

  # Expense form validation

  $(".expense_form").on "click",'.expense-submit-btn', ->

    expense_category = $("#expense_category_id").val()
    amount = $("#expense_amount").val()
    client = $("#expense_client_id").val()
    expense_date = $('#expense_expense_date').val()
    if expense_category is ""
      applyPopover($("#expense_category_id_chzn"),"bottomMiddle","topLeft","Select a category")
      flag = false
    else if amount is ""
      applyPopover($("#expense_amount"),"bottomMiddle","topLeft","Insert amount")
      hidePopover($("#expense_category_id_chzn"))
      flag = false
    else if amount < 0
      applyPopover($("#expense_amount"),"bottomMiddle","topLeft","Insert amount greater or equal to 0.")
      hidePopover($("#expense_category_id_chzn"))
      flag = false
    else if client is ""
      applyPopover($("#expense_client_id_chzn"),"bottomMiddle","topLeft","Select a client")
      hidePopover($("#expense_amount"))
      flag = false
    else if expense_date is ""
      applyPopover($("#expense_expense_date"),"bottomMiddle","topLeft","Select expense date")
      hidePopover($("#expense_client_id_chzn"))
      flag = false
    else
      hidePopover($("#expense_expense_date"))
      flag = true
    if(flag)
      $(".expense_form>form#newExpense").get(0).submit()



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
    #elem.next(".popover").hide()
    elem.qtip("hide")

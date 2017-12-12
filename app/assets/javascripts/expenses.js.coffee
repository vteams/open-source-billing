# Add date picker to expense date
jQuery ->
  jQuery("#expense_expense_date").datepicker
    dateFormat: DateFormats.format()
    beforeShow: (input, inst) ->
      widget = jQuery(inst).datepicker('widget')
      widget.css('margin-left', jQuery(input).outerWidth() - widget.outerWidth())

# Applied taxes expense
  jQuery("body").on "change", ".tax_div select.tax1, .tax_div select.tax2", ->
    updateAmountField()

  jQuery("body").on "keyup", "#expense_amount", ->
    hidePopover($(this))
    updateAmountField()

  updateAmountField = ->
    tax1 = jQuery(".tax_div select.tax1 option:selected").attr('data-tax_1')
    tax2 = jQuery(".tax_div select.tax2 option:selected").attr('data-tax_1')
    tax1 = 0 if not tax1? or tax1 is ""
    tax2 = 0 if not tax2? or tax2 is ""

    amount1 = jQuery(".amount_div #amount1")
    amount2 = jQuery(".amount_div #amount2")

    amount = jQuery("#expense_amount").val() || 0
    amount1_val = (amount*tax1/100).toFixed(2)
    amount2_val = (amount*tax2/100).toFixed(2)
    amount1.val(amount1_val)
    amount2.val(amount2_val)

  # Expense form validation

  jQuery(".expense_form").on "click", ".expense-submit-btn", ->

    expense_category = jQuery("#expense_category_id").val()
    amount = jQuery("#expense_amount").val()
    client = jQuery("#expense_client_id").val()
    expense_date = jQuery('#expense_expense_date').val()
    if expense_category is ""
      applyPopover(jQuery("#expense_category_id_chzn"),"bottomMiddle","topLeft","Select a category")
      flag = false
    else if amount is ""
      applyPopover(jQuery("#expense_amount"),"bottomMiddle","topLeft","Insert amount")
      hidePopover(jQuery("#expense_category_id_chzn"))
      flag = false
    else if amount < 0
      applyPopover(jQuery("#expense_amount"),"bottomMiddle","topLeft","Insert amount greater or equal to 0.")
      hidePopover(jQuery("#expense_category_id_chzn"))
      flag = false
    else if client is ""
      applyPopover(jQuery("#expense_client_id_chzn"),"bottomMiddle","topLeft","Select a client")
      hidePopover(jQuery("#expense_amount"))
      flag = false
    else if expense_date is ""
      applyPopover(jQuery("#expense_expense_date"),"bottomMiddle","topLeft","Select expense date")
      hidePopover(jQuery("#expense_client_id_chzn"))
      flag = false
    else
      hidePopover(jQuery("#expense_expense_date"))
      flag = true
    if(flag)
      jQuery(".expense_form>form#newExpense").get(0).submit()



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
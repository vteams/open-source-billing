# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $("form#new_account, form.edit_account").submit ->
    flag = true
    flag = if jQuery.trim($("#account_org_name").val()) is ""
      applyQtip($("#account_org_name"),"Enter company name")
      false
    else if jQuery.trim($("#account_admin_first_name").val()) is ""
      applyQtip($("#account_admin_first_name"),"Enter first name")
      false
    else if jQuery.trim($("#account_admin_last_name").val()) is ""
      applyQtip($("#account_admin_last_name"),"Enter last name")
      false

  $("input[type=text]",".companies_wrapper").keypress ->
    hideQtip($(this))

  applyQtip = (elem,message) ->
    elem.qtip
      content:
        text: message
      show:
        event: false
      hide:
        event: false
      position:
        at: "topRight"
      style:
        tip:
          corner: "leftMiddle"
    elem.qtip().show()
    elem.focus()

  hideQtip = (elem) =>
    elem.qtip("hide")

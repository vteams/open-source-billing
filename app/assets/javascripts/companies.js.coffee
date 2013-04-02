# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  jQuery("form#new_company, form.edit_company").submit ->
    flag = true
    flag = if jQuery.trim(jQuery("#company_org_name").val()) is ""
      applyQtip(jQuery("#company_org_name"),"Enter company name")
      false
    else if jQuery.trim(jQuery("#company_admin_first_name").val()) is ""
      applyQtip(jQuery("#company_admin_first_name"),"Enter first name")
      false
    else if jQuery.trim(jQuery("#company_admin_last_name").val()) is ""
      applyQtip(jQuery("#company_admin_last_name"),"Enter last name")
      false

  jQuery("input[type=text]",".companies_wrapper").keypress ->
    hideQtip(jQuery(this))

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

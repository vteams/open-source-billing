# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  jQuery("form#new_tax, form.edit_tax,form#create_tax").submit ->
    flag = true
    flag = if jQuery.trim(jQuery("#tax_name").val()) is ""
      applyPopover(jQuery("#tax_name"),"Enter tax name")
      false
    else if jQuery.trim(jQuery("#tax_percentage").val()) is ""
      applyPopover(jQuery("#tax_percentage"),"Enter tax percentage")
      false
    else if isNaN(jQuery("#tax_percentage").val())
      applyPopover(jQuery("#tax_percentage"),"Percentage must be numeric value")
      false
    else if parseFloat(jQuery("#tax_percentage").val()) > 100
      applyPopover(jQuery("#tax_percentage"),"Percentage must be hundred or less")
      false
    flag

  applyPopover = (elem,message) ->
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


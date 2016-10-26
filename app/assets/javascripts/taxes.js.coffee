# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $("form#new_tax, form.edit_tax,form#create_tax").submit ->
    flag = true
    flag = if jQuery.trim($("#tax_name").val()) is ""
      applyPopover($("#tax_name"),"Enter tax name")
      false
    else if jQuery.trim($("#tax_percentage").val()) is ""
      applyPopover($("#tax_percentage"),"Enter tax percentage")
      false
    else if isNaN($("#tax_percentage").val())
      applyPopover($("#tax_percentage"),"Percentage must be numeric value")
      false
    else if parseFloat($("#tax_percentage").val()) > 100
      applyPopover($("#tax_percentage"),"Percentage must be hundred or less")
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


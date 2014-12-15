# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
    # Validate client
  jQuery("form#new_item, form.edit_item,form#create_item").submit ->
    flag = true
    if jQuery.trim(jQuery("#item_item_name").val()) is ""
      applyPopover(jQuery("#item_item_name"),"Item name is required")
      flag = false
    else if jQuery('#company_association').is(':checked')
      if jQuery('.options_content input[type=checkbox]:checked').length is 0
       applyPopover(jQuery("#company_association"),"Select a company")
       flag = false
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

  hidePopover = (elem) ->
    elem.qtip("hide")

  jQuery("#item_item_name").click ->
    hidePopover(jQuery(this))
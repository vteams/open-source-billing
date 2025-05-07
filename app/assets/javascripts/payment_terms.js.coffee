# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  jQuery("form#new_term, form.edit_term,form#create_term").submit ->
    flag = true
    flag = if jQuery.trim(jQuery("#payment_term_number_of_days").val()) is ""
      applyPopover(jQuery("#payment_term_number_of_days"),"Enter number of days")
      false
    else if jQuery.trim(jQuery("#payment_term_description").val()) is ""
      applyPopover(jQuery("#payment_term_description"),"Enter description")
      false

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
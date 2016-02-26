# Staff form validation

jQuery(".staff_form .staff-submit-btn").live "click", ->
  name = jQuery("#staff_name").val()
  email = jQuery("#staff_email").val()
  if name is ""
    applyPopover(jQuery("#staff_name"),"bottomMiddle","topLeft","Enter a name for this staff")
    flag = false
  else if email is ""
    applyPopover(jQuery("#staff_email"),"bottomMiddle","topLeft","Enter an email for this staff")
    flag = false
  else
    flag = true
  if(flag)
    jQuery("form#newStaff").get(0).submit()

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
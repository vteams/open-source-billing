# Staff form validation

jQuery(".staff_form").on "click", '.staff-submit-btn', ->

  name = jQuery("#staff_name").val()
  email = jQuery("#staff_email").val()
  rate = jQuery("#staff_rate").val()
  association_name = jQuery('input[name=association]:checked').attr("id")
  no_of_selected_companies = jQuery('.company_checkbox:checked').length
  flag = true
  if name is ""
    applyPopover(jQuery("#staff_name"),"bottomMiddle","topLeft","Enter a name for the staff")
    flag = false
  else if email is ""
    hidePopover(jQuery("#staff_name"))
    applyPopover(jQuery("#staff_email"),"bottomMiddle","topLeft","Enter an email for the staff")
    flag = false
  else if !validateEmail(email)
    hidePopover(jQuery("#staff_name"))
    applyPopover(jQuery("#staff_email"),"bottomMiddle","topLeft","Enter a valid email for the staff")
    flag = false
  else if rate is ""
    hidePopover(jQuery("#staff_email"))
    applyPopover(jQuery("#staff_rate"),"bottomMiddle","topLeft","Enter rate per hour for the staff")
    flag = false
  else if rate < 0
    applyPopover(jQuery("#staff_rate"),"bottomMiddle","topLeft","Enter postive value of rate per hour for the staff")
    flag = false
  else if (association_name == "company_association" and no_of_selected_companies == 0)
    hidePopover(jQuery("#staff_rate"))
    applyPopover(jQuery("input[name=association]:checked"),"topright","leftcenter","Select aleast one company for the staff")
    flag = false
  else
    hidePopover(jQuery("input[name=association]:checked"))
    flag = true
  if(flag)
    jQuery("#staff_user_attributes_email").val(jQuery("#staff_email").val())
    jQuery("form#newStaff").get(0).submit()
  else
    return false

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

validateEmail= (email) ->
  re = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
  return re.test(email)

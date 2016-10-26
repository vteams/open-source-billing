# Staff form validation

$(".staff_form").on "click", ".staff-submit-btn", ->
  name = $("#staff_name").val()
  email = $("#staff_email").val()
  rate = $("#staff_rate").val()
  association_name = $('input[name=association]:checked').attr("id")
  no_of_selected_companies = $('.company_checkbox:checked').length
  flag = true
  if name is ""
    applyPopover($("#staff_name"),"bottomMiddle","topLeft","Enter a name for the staff")
    flag = false
  else if email is ""
    hidePopover($("#staff_name"))
    applyPopover($("#staff_email"),"bottomMiddle","topLeft","Enter an email for the staff")
    flag = false
  else if !validateEmail(email)
    hidePopover($("#staff_name"))
    applyPopover($("#staff_email"),"bottomMiddle","topLeft","Enter a valid email for the staff")
    flag = false
  else if rate is ""
    hidePopover($("#staff_email"))
    applyPopover($("#staff_rate"),"bottomMiddle","topLeft","Enter rate per hour for the staff")
    flag = false
  else if rate < 0
    applyPopover($("#staff_rate"),"bottomMiddle","topLeft","Enter postive value of rate per hour for the staff")
    flag = false
  else if (association_name == "company_association" and no_of_selected_companies == 0)
    hidePopover($("#staff_rate"))
    applyPopover($("input[name=association]:checked"),"topright","leftcenter","Select aleast one company for the staff")
    flag = false
  else
    hidePopover($("input[name=association]:checked"))
    flag = true
  if(flag)
    $("#staff_user_attributes_email").val($("#staff_email").val())
    $("form#newStaff").get(0).submit()
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

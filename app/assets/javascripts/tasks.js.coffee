# Task form validation

jQuery('.task_form').on 'click', '.task-submit-btn', ->
  name = jQuery("#task_name").val()
  rate = jQuery("#task_rate").val()
  association_name = jQuery('input[name=association]:checked').attr("id")
  no_of_selected_companies = jQuery('.company_checkbox:checked').length

  flag = false
  if name is ""
    applyPopover(jQuery("#task_name"),"bottomMiddle","topLeft","Enter a name for the task")
    flag = false
  else if rate is ""
    applyPopover(jQuery("#task_rate"),"bottomMiddle","topLeft","Enter rate per hour for the task")
    flag = false
    hidePopover(jQuery("#task_name"))
  else if rate < 0
    applyPopover(jQuery("#task_rate"),"bottomMiddle","topLeft","Enter postive value of rate per hour for the task")
    flag = false
    hidePopover(jQuery("#task_name"))
  else if (association_name == "company_association" and no_of_selected_companies == 0)
    hidePopover(jQuery("#task_rate"))
    applyPopover(jQuery("input[name=association]:checked"),"topright","leftcenter","Select aleast one company for the task")
    flag = false
  else
    flag = true
    hidePopover(jQuery("input[name=association]:checked"))
  if(flag)
    jQuery("form#newTask").get(0).submit()
  else
    return false

jQuery('body').on "change", '#task_name', ->

  return hidePopover(jQuery("#task_name"))

jQuery('body').on "change", '.company_checkbox' , ->
  return hidePopover(jQuery("#company_association"))

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
  elem.qtip("hide")

# Task form validation

jQuery(".task_form .task-submit-btn").live "click", ->
  name = jQuery("#task_name").val()
  rate = jQuery("#task_rate").val()
  flag = true
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
  else
    flag = true
    hidePopover(jQuery("#task_rate"))
  if(flag)
    jQuery("form#newTask").get(0).submit()
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

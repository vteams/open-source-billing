# Task form validation

jQuery(".task_form .task-submit-btn").live "click", ->
  name = jQuery("#task_name").val()
  description = jQuery("#task_description").val()
  rate = jQuery("#task_rate").val()
  flag = true
  if name is ""
    applyPopover(jQuery("#task_name"),"bottomMiddle","topLeft","Enter a name for this task")
    flag = false
  if description is ""
    applyPopover(jQuery("#task_description"),"bottomMiddle","topLeft","Enter description for task")
    flag = false
  if rate is ""
    applyPopover(jQuery("#task_rate"),"bottomMiddle","topLeft","Enter rate for task")
    flag = false
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

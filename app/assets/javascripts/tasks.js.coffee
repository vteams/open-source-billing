# Task form validation

jQuery(".task_form .task-submit-btn").live "click", ->
  name = jQuery("#task_name").val()
  description = jQuery("#task_description").val()
  if name is ""
    applyPopover(jQuery("#task_name"),"bottomMiddle","topLeft","Enter a name for this task")
    flag = false
  else if description is ""
    applyPopover(jQuery("#task_description"),"bottomMiddle","topLeft","Insert description for task")
    flag = false
  else
    flag = true
  if(flag)
    jQuery(".task_form>form#newTask").get(0).submit()

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
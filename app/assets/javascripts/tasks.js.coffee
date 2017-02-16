# Task form validation

$(".task_form .task-submit-btn").on "click", ->
  name = $("#task_name").val()
  rate = $("#task_rate").val()
  association_name = $('input[name=association]:checked').attr("id")
  no_of_selected_companies = $('.company_checkbox:checked').length

  flag = false
  if name is ""
    applyPopover($("#task_name"),"bottomMiddle","topLeft","Enter a name for the task")
    flag = false
  else if rate is ""
    applyPopover($("#task_rate"),"bottomMiddle","topLeft","Enter rate per hour for the task")
    flag = false
    hidePopover($("#task_name"))
  else if rate < 0
    applyPopover($("#task_rate"),"bottomMiddle","topLeft","Enter postive value of rate per hour for the task")
    flag = false
    hidePopover($("#task_name"))
  else if (association_name == "company_association" and no_of_selected_companies == 0)
    hidePopover($("#task_rate"))
    applyPopover($("input[name=association]:checked"),"topright","leftcenter","Select aleast one company for the task")
    flag = false
  else
    flag = true
    hidePopover($("input[name=association]:checked"))
  if(flag)
    $("form#newTask").get(0).submit()
  else
    return false


$('#task_name').on "change", ->
  return hidePopover($("#task_name"))

$('.company_checkbox').on "change", ->
  return hidePopover($("#company_association"))

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

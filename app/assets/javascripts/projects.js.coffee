jQuery ->

  # Load Task data when an task is selected from dropdown list
  jQuery(".project_grid_fields").on "change", "select.tasks_list", ->
    # Add an empty line item row at the end if last task is changed.
    elem = jQuery(this)
    if elem.val() is ""
      clearLineTotal(elem)
      false
    else
      jQuery.ajax '/tasks/load_task_data',
        type: 'POST'
        data: "id=" + jQuery(this).val()
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          alert "Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
          item = JSON.parse(data)
          container = elem.parents("tr.fields")
          # populate task's discription, billable and rate.
          container.find("input.task_name").val(item[2])
          container.find(".description").val(item[0])
          container.find("input.rate").val(item[1])
          container.find("select.task_id").val(item[3])
      addLineTaskRow(elem)


  clearLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    container.find("input.task_name").val('')
    container.find(".description").val('')
    container.find("input.rate").val('')


  addLineTaskRow = (elem) ->
    if elem.parents('tr.fields').next('tr.fields:visible').length is 0
      jQuery(".project_grid_fields .add_nested_fields").click()
      #jQuery("#add_task").click()

  jQuery(".project_team_member_fields").on "click", ".add_nested_fields", ->
    setTimeout "window.applyChosen(jQuery('.project_team_member_fields tr.fields:last .chzn-select'))", 0

  jQuery(".project_task_fields").on "click", ".add_nested_fields", ->
    setTimeout "window.applyChosen(jQuery('.project_task_fields tr.fields:last .chzn-select'))", 0

  jQuery("body").on "click", "#add_task", ->
    options = $('.tasks_list:first').html()
    $('.tasks_list:last').html(options).find('option:selected').removeAttr('selected')
    $('.tasks_list:last').find('option[data-type = "deleted_item"], option[data-type = "archived_item"], option[data-type = "other_company"], option[data-type = "active_line_item"]').remove()


  # Load Staff data when an staff is selected from dropdown list
  jQuery(".project_grid_fields").on "change", "select.members_list", ->
    # Add an empty line item row at the end if last task is changed.
    elem = jQuery(this)
    if elem.val() is ""
      clearLineTotal(elem)
      false
    else
      addLineTaskRow(elem)
      jQuery.ajax '/staffs/load_staff_data',
        type: 'POST'
        data: "id=" + jQuery(this).val()
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          alert "Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
          item = JSON.parse(data)
          container = elem.parents("tr.fields")
          container.find("input.task_name").val(item[2])
          container.find("input.description").val(item[0])
          container.find("input.rate").val(item[1])

  jQuery("body").on 'click', ".project-submit-btn", ->
    flag = true
    if $("#project_project_name").val() is ""
      flag = false
      applyPopover(jQuery("#project_project_name"),"bottomMiddle","topLeft","Project Name field is required")
    else if ($("#project_total_hours").val() < 0)
        hidePopover(jQuery("#project_project_name"))
        flag = false
        applyPopover(jQuery("#project_total_hours"),"bottomLeft","topLeft","Time Estimate should be greater than zero")
    else
      hidePopover(jQuery("#project_total_hours"))
      flag = true
    if(flag)
      jQuery("form.project-form").get(0).submit()
    else
      reture false

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

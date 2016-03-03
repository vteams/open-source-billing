jQuery ->
  $values = new Array();
  jQuery(".project_task_select").live 'change', ->
    selected_value = $(this).val()
    $values.push(selected_value)
    console.log($values)
    task_ids_input = "<input id='project_task_ids' multiple='multiple' name='project[task_ids][]' type='hidden' value="+selected_value+">"
    jQuery(".task_hidden_fields_block").append(task_ids_input)
    jQuery(".project_task_select option[value="+ selected_value+"]").remove()


  jQuery(".assigned-tasks-list .remove_task").live 'click', ->
      task_parent = $(this).parents('li')
      task_name= task_parent.data("task-name")
      task_id = task_parent.data("task-id")
      $('.project_task_select').append($("<option></option>").attr("value",task_id).text(task_name))
      task_parent.remove()

  # Load Task data when an task is selected from dropdown list
  jQuery(".project_grid_fields select.tasks_list").live "change", ->
    # Add an empty line item row at the end if last task is changed.
    elem = jQuery(this)
    if elem.val() is ""
      clearLineTotal(elem)
      false
    else
      addLineTaskRow(elem)
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
          container.find("input.description").val(item[0])
          container.find("input.rate").val(item[1])



  clearLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    container.find("input.task_name").val('')
    container.find("input.description").val('')
    container.find("input.billable").val('')
    container.find("input.rate").val('')


  addLineTaskRow = (elem) ->
    if elem.parents('tr.fields').next('tr.fields:visible').length is 0
      jQuery(".project_grid_fields .add_nested_fields").click()
      #jQuery("#add_task").click()

  jQuery(".project_grid_fields .add_nested_fields").live "click", ->
    setTimeout "window.applyChosen(jQuery('.invoice_grid_fields tr.fields:last .chzn-select'))", 0


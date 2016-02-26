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
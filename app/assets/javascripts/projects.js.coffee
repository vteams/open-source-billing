class @Project

  @change_project_task  = ->
    # Load Task data when an task is selected from dropdown list
    jQuery(".project_grid_fields select.tasks_list").on "change", ->
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
            container.find("input.name").val(item[2])
            container.find("td.name").text(item[2])
            container.find("input.description").val(item[0])
            container.find("td.description").text(item[0])
            container.find("input.rate").val(item[1])
            container.find("td.rate").text(item[1])

  @change_project_staff = ->
    # Load Staff data when an staff is selected from dropdown list
    jQuery(".project_grid_fields select.members_list").on "change", ->
      # Add an empty line item row at the end if last task is changed.
      elem = jQuery(this)
      if elem.val() is ""
        clearLineTotal(elem)
        false
      else
        jQuery.ajax '/staffs/load_staff_data',
          type: 'POST'
          data: "id=" + jQuery(this).val()
          dataType: 'html'
          error: (jqXHR, textStatus, errorThrown) ->
            alert "Error: #{textStatus}"
          success: (data, textStatus, jqXHR) ->
            item = JSON.parse(data)
            container = elem.parents("tr.fields, .invoice-details")
            container.find("input.name").val(item[2])
            container.find("td.name").text(item[2])
            container.find("input.email").val(item[0])
            container.find("td.email").text(item[0])
            container.find("input.rate").val(item[1])
            container.find("td.rate").text(item[1])

  addLineTaskRow = (elem) ->
    if elem.parents('tr.fields').next('tr.fields:visible').length is 0
      jQuery(".project_grid_fields .add_nested_fields").click()

  clearLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    container.find("td.name, td.description, td.email, td.rate").text('')
    container.find("input").val('')

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

  @validate_fields = ->
    flag = true
    if $("#project_project_name").val() is ""
      flag = false
      applyPopover($("strong.project_name"),"bottomMiddle","topLeft","Project Name field is required")
    else if $("#project_client_id").val() is ""
      hidePopover(jQuery("#project_project_name"))
      applyPopover($("#project_client_id").parents('.select-wrapper'),"bottomMiddle","topLeft","Select a client")
      flag = false
    else if ($("#project_total_hours").val() < 0)
      hidePopover($("#project_client_id").parents('.select-wrapper'))
      flag = false
      applyPopover(jQuery("#project_total_hours"),"bottomLeft","topLeft","Time Estimate should be greater than zero")
    else
      hidePopover(jQuery("#project_total_hours"))
      flag = true
    flag

  @enable_staff_fields = ->
    $('.content-detail, .staff-list').find("input").removeAttr('disabled');
    $('.content-detail, .staff-list').find(".initialized").removeAttr('disabled');
    $('.content-detail, .staff-list').find(".not-editable").attr('disabled', true);
    $('select').material_select();

  @load_functions = ->

    jQuery('form.project-form').submit ->
      flag = true
      if $("#project_project_name").val() is ""
        flag = false
        applyPopover(jQuery("#project_project_name"),"bottomMiddle","topLeft","Project Name field is required")
      else if $("#project_client_id").val() is ""
        hidePopover(jQuery("#project_project_name"))
        applyPopover($("#project_client_id").parents('.select-wrapper'),"bottomMiddle","topLeft","Select a client")
        flag = false
      else if ($("#project_total_hours").val() < 0)
        hidePopover($("#project_client_id").parents('.select-wrapper'))
        flag = false
        applyPopover(jQuery("#project_total_hours"),"bottomLeft","topLeft","Time Estimate should be greater than zero")
      else
        hidePopover(jQuery("#project_total_hours"))
        flag = true
      flag

    $('#project_grid_fields tbody').sortable
      handle: '.sort_icon'
      items: 'tr.fields'
      axis: 'y'

  @toggleStaffRemoveButton = ->
    $('.checkbox-item.inline_team_member > input[type="checkbox"]').on 'change', ->
      n = $( ".checkbox-item.inline_team_member > input[type='checkbox']:checked" ).length
      if n > 0
        $('.edit-detail').click();
        $("a.staff_remove_btn").removeClass('hidden');
      else
        $("a.staff_remove_btn").addClass('hidden');

  @removeStaff = ->
    $("a.staff_remove_btn").on 'click', ->
      $( ".checkbox-item.inline_team_member > input[type='checkbox']:checked" ).each ->
        $(this).parents('.fields').find('input.destroy_staff').val true
        $(this).parents('.fields').addClass('hidden')

  applyDatePicker = ->
    $("#start_date_picker").pickadate
      format: "yyyy-mm-dd"
      formatSubmit: DateFormats.format()
      onSet: (context) ->
        value = @get('value')
        $('#start_date_picker').parents('.datepicker').find('input').val value

    $("#due_date_picker").pickadate
      format: "yyyy-mm-dd"
      formatSubmit: DateFormats.format()
      onSet: (context) ->
        value = @get('value')
        $('#due_date_picker').parents('.datepicker').find('input').val value


  @projectTaskForm = ->
    applyDatePicker()
    $('.rkmd-slider').rkmd_rangeSlider()
    $(".project_task_form").submit ->
      $("#project_task_name").val($(this).find('.task_name').text())
      $("#project_task_description").val($(this).find('.task_description').text())

$(document).ready ->
  Project.change_project_staff()
  Project.toggleStaffRemoveButton()
  Project.removeStaff()
  jQuery('form.project-form-inline').submit ->
    $("#project_project_name").val($("strong.project_name").text())
    $("#project_description").val($("span.project_description").text())
    Project.validate_fields()

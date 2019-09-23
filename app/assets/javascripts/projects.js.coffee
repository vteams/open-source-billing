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
            container.find("span.email").html(item[0])
            container.find("td.email").text(item[0])
            container.find("input.rate").val(item[1])
            container.find("span.rate").html(item[1])
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
      applyPopover($("strong.project_name"),"bottomMiddle","topLeft", I18n.t('views.projects.name_required'))
    else if $("#project_client_id").val() is ""
      hidePopover(jQuery("#project_project_name"))
      applyPopover($("#project_client_id").parents('.select-wrapper'),"bottomMiddle","topLeft", I18n.t('views.invoices.select_a_client'))
      flag = false
    else if ($("#project_total_hours").val() < 0)
      hidePopover($("#project_client_id").parents('.select-wrapper'))
      flag = false
      applyPopover(jQuery("#project_total_hours"),"bottomLeft","topLeft", I18n.t('views.projects.estimate_should_be_greater_than_zero'))
    else
      hidePopover(jQuery("#project_total_hours"))
      flag = true
    flag

  @enable_staff_fields = ->
    $('.content-detail, .staff-list').find("input").removeAttr('disabled');
    $('.content-detail, .staff-list').find(".initialized").removeAttr('disabled');
    $('.content-detail, .staff-list').find(".not-editable").attr('disabled', true);
#    $('select').material_select();

  @load_functions = ->
    $('#project_project_name,#project_total_hours').keypress ->
      hidePopover($(this))
    $('#project_client_id,#project_manager_id').change ->
      hidePopover($(this).parents('.select-wrapper'))

    jQuery('form#horizontal-project-form').submit ->
      flag = true
      if $('#project_project_name').val() is ""
        applyPopover(jQuery("#project_project_name"),"bottomMiddle","topLeft", I18n.t('views.projects.name_required'))
        flag = false
      else if $("#project_client_id").val() is "" or $("#project_client_id").val() == undefined
        applyPopover($("#project_client_id").parents('.select-wrapper'),"bottomMiddle","topLeft", I18n.t('views.projects.select_a_client'))
        flag = false
      else if $("#project_manager_id").val() is "" or $("#project_manager_id").val() == undefined
        applyPopover($("#project_manager_id").parents('.select-wrapper'),"bottomMiddle","topLeft", I18n.t('views.projects.select_a_manager'))
        flag = false
      else if $("#project_total_hours").val() is ""
        applyPopover(jQuery("#project_total_hours"),"bottomLeft","topLeft", I18n.t('views.projects.estimate_should_be_greater_than_zero'))
        flag = false
      else if (parseFloat($("#project_total_hours").val()) < 0)
        jQuery("#project_total_hours")
        applyPopover(jQuery("#project_total_hours"),"bottomLeft","topLeft", I18n.t('views.projects.estimate_should_be_greater_than_zero'))
        flag = false
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
        $(this).parents('.nested-fields').find('input.destroy_staff').val true
        $(this).parents('.nested-fields').addClass('hidden')

  applyDatePicker = ->
    format = DateFormats.format().toUpperCase()
    $("#project_task_start_date").daterangepicker {
      singleDatePicker: true
      locale: format: format
    }, (start, end, label) ->
      $("#project_start_date").val start.format(format)
      return

    $("#project_task_due_date").daterangepicker {
      singleDatePicker: true
      locale: format: format
    }, (start, end, label) ->
      $("#project_due_date").val start.format(format)
      return

  @projectTaskForm = ->
    applyDatePicker()
#    $('.rkmd-slider').rkmd_rangeSlider()

    $(".project_task_form").submit ->
      hidePopover($("#project_task_name,#project_task_start_date,#project_task_due_date,#project_task_hours,#project_task_spent_time,#project_task_rate"))
      flag = true
      if $("#project_task_name").val() is ""
        applyPopover($("#project_task_name"),"bottomMiddle","topLeft", I18n.t("views.tasks.enter_name"))
        flag = false
      else if $('#project_task_start_date').val() is ""
        applyPopover($('#project_task_start_date'),"bottomMiddle","topLeft", I18n.t("views.tasks.select_start_date"))
        flag = false
      else if $("#project_task_due_date").val() is ""
        applyPopover($("#project_task_due_date"),"bottomMiddle","topLeft", I18n.t("views.tasks.select_due_date"))
        flag = false
      else if $("#project_task_start_date").val() > $("#project_task_due_date").val()
        applyPopover($("#project_task_due_date"),"bottomMiddle","topLeft", I18n.t("views.tasks.due_date_should_equal_or_greater"))
        flag = false
      else if $("#project_task_hours").val() is ""
        applyPopover($("#project_task_hours"),"bottomMiddle","topLeft", I18n.t("views.tasks.enter_hours"))
        flag = false
      else if $("#project_task_hours").val() < 0
        applyPopover($("#project_task_hours"),"bottomMiddle","topLeft", I18n.t("views.tasks.enter_positive_hour"))
        flag = false
      else if $("#project_task_hours").val() < 0
        applyPopover($("#project_task_hours"),"bottomMiddle","topLeft", I18n.t("views.tasks.enter_positive_hour"))
        flag = false
      else if $("#project_task_spent_time").val() < 0
        applyPopover($("#project_task_spent_time"),"bottomMiddle","topLeft", I18n.t("views.tasks.enter_positive_spent_time"))
        flag = false
      else if $("#project_task_rate").val() is ""
        applyPopover($("#project_task_rate"),"bottomMiddle","topLeft", I18n.t("views.tasks.enter_rate"))
        flag = false
      else if $("#project_task_rate").val() < 0
        applyPopover($("#project_task_rate"),"bottomMiddle","topLeft", I18n.t("views.tasks.enter_positive_rate"))
        flag = false
      flag

$(document).ready ->
  Project.change_project_staff()
  Project.toggleStaffRemoveButton()
  Project.removeStaff()

  # show add/remove staff member button when edit project icon is clicked
  $('.edit-detail').click ->
    $('#add_member').removeClass 'hidden'

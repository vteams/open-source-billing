class @Task

  @initFilterEvents = ->
    $(document).ready (event) ->
      $('#toggle_filters').on 'click', (event) ->
        $('#filters').toggle('slow')
        toggleFilterText()
      $('#filter_reset_btn').on 'click', (event) ->
        $('#create_at_start_date,#create_at_end_date,#rate_min,#rate_max').val('')
        resetRangeSelectors()

  @load_functions = ->

    $('.modal').modal complete: ->
      $('.qtip').remove()

    # Task form validation
    $(".task_form").submit ->
      name = $("#task_name").val()
      rate = $("#task_rate").val()
      association_name = $('input[name=association]:checked').attr("id")
      no_of_selected_companies = $('.company_checkbox:checked').length

      flag = false
      if name is ""
        applyPopover($("#task_name"),"bottomMiddle","topLeft", I18n.t('views.tasks.enter_name'))
        flag = false
      else if rate is ""
        applyPopover($("#task_rate"),"bottomMiddle","topLeft", I18n.t('views.tasks.enter_rate'))
        flag = false
        hidePopover($("#task_name"))
      else if rate < 0
        applyPopover($("#task_rate"),"bottomMiddle","topLeft", I18n.t('views.tasks.enter_positive_rate'))
        flag = false
        hidePopover($("#task_name"))
      else if association_name == undefined
        hidePopover($("#task_rate"))
        applyPopover($("input[name=association]"),"topright","leftcenter", I18n.t('views.tasks.atleast_one_company_selected'))
      else if (association_name == "company_association" and no_of_selected_companies == 0)
        hidePopover($("#task_rate"))
        applyPopover($("input[name=association]"),"topright","leftcenter", I18n.t('views.tasks.atleast_one_company_selected'))
        flag = false
      else
        flag = true
        hidePopover($("input[name=association]"))
      flag

    jQuery('#account_association').change ->
      if jQuery(this).is ':checked'
        $('.company_checkbox').prop('checked',true)

    $('#task_name, #task_rate').on "keypress", ->
      return hidePopover($(this))

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

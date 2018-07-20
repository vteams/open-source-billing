class @Staff

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

    # Staff form validation

    jQuery(".staff_form").submit  ->
      name = jQuery("#staff_name").val()
      email = jQuery("#staff_email").val()
      rate = jQuery("#staff_rate").val()
      association_name = jQuery('input[name=association]:checked').attr("id")
      no_of_selected_companies = jQuery('.company_checkbox:checked').length
      flag = true
      if name is ""
        applyPopover(jQuery("#staff_name"),"bottomMiddle","topLeft", I18n.t("views.staffs.enter_name"))
        flag = false
      else if email is ""
        hidePopover(jQuery("#staff_name"))
        applyPopover(jQuery("#staff_email"),"bottomMiddle","topLeft",I18n.t("views.staffs.enter_email"))
        flag = false
      else if !validateEmail(email)
        hidePopover(jQuery("#staff_name"))
        applyPopover(jQuery("#staff_email"),"bottomMiddle","topLeft",I18n.t("views.staffs.enter_valid_email"))
        flag = false
      else if rate is ""
        hidePopover(jQuery("#staff_email"))
        applyPopover(jQuery("#staff_rate"),"bottomMiddle","topLeft",I18n.t("views.staffs.enter_rate"))
        flag = false
      else if rate < 0
        applyPopover(jQuery("#staff_rate"),"bottomMiddle","topLeft",I18n.t("views.staffs.rate_must_be_positive"))
        flag = false
      else if association_name == undefined
        hidePopover($("#staff_rate"))
        applyPopover($("input[name=association]"),"topright","leftcenter",I18n.t("views.staffs.select_company"))
      else if (association_name == "company_association" and no_of_selected_companies == 0)
        hidePopover(jQuery("#staff_rate"))
        applyPopover(jQuery("input[name=association]:checked"),"topright","leftcenter",I18n.t("views.staffs.select_company"))
        flag = false
      else
        hidePopover(jQuery("input[name=association]:checked"))
        flag = true
      flag

    jQuery('#account_association').change ->
      if jQuery(this).is ':checked'
        $('.company_checkbox').prop('checked',true)

    $('.company_checkbox').on "change", ->
      return hidePopover($("#company_association"))

    $('#staff_name, #staff_rate, #staff_email').on "keypress", ->
      return hidePopover($(this))

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

  validateEmail= (email) ->
    re = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
    return re.test(email)

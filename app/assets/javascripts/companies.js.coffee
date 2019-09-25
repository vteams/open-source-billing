class @Company

  @init_settings_form = ->
    $("#company_name,#contact_name,#companies_email").keypress ->
      hideQtip(jQuery(this))
    $('#company_side_form').submit ->
      flag = true
      pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
      if $('#company_name').val() == ''
        applyQtip($("#company_name"), I18n.t("views.companies.field_requied"), "bottomMiddle", "topLeft")
        flag = false
      else if $('#contact_name').val() == ''
        applyQtip($("#contact_name"), I18n.t("views.companies.field_requied"), "bottomMiddle", "topLeft")
        flag = false
      else if $('#companies_email').val() == ''
        applyQtip($("#companies_email"), I18n.t("views.companies.field_requied"), "bottomMiddle", "topLeft")
        flag = false
      else unless pattern.test($("#companies_email").val())
        applyQtip($("#companies_email"), I18n.t('views.companies.email_invalid'), "bottomMiddle", "topLeft")
        flag = false
      flag

  @load_functions = ->

    $('.modal').modal complete: ->
      $('.qtip').remove()

#    $('select').material_select();

    jQuery("#company_contact_name,#company_email,#company_company_name").keypress ->
      hideQtip(jQuery(this))

    $("#companyForm").submit ->
      flag = true
      pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
      if jQuery("#company_company_name").val() is ""
        applyQtip(jQuery("#company_company_name"), I18n.t("views.companies.field_requied"))
        flag = false
      else if jQuery("#company_contact_name").val() is ""
        applyQtip(jQuery("#company_contact_name"), I18n.t("views.companies.field_requied"))
        flag = false
      else if jQuery("#company_email").val() is ""
        applyQtip(jQuery("#company_email"), I18n.t("views.companies.field_requied"))
        flag = false
      else unless pattern.test(jQuery("#company_email").val())
        applyQtip(jQuery("#company_email"), I18n.t('views.companies.email_invalid'))
        flag = false
      flag

  applyQtip = (elem, message, position = "topRight", corner = "leftMiddle") ->

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

  hideQtip = (elem) ->
    elem.qtip("hide")

jQuery ->
  #/ Change selected company in companies list in header
  $('.company_select').material_select();
  $(".company_select").on "change", ->
    if parseInt($(this).find(':selected').val()) == -1
      $(this).val('')
      $('#new_company_remote_link').click()
      return

    company_id = $(this).find(':selected').data('company-id')
    controller = $(this).find(':selected').data('controller')
    action = $(this).find(':selected').data('action')
    if action is 'new' or action is 'edit'
      unless confirm(I18n.t('views.companies.changes_discarded_msg'))
        return true

    if parseInt($(this).find(':selected').val()) && parseInt($(this).find(':selected').val()) != -1
      jQuery.get "/companies/#{company_id}/select", (response) ->
        jQuery("#current_selected_company").text(response)
        jQuery('.company_read_only').val(response) if jQuery('.company_read_only').length > 0
        window.location.reload()
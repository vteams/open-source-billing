jQuery ->
  #/ Change selected company in companies list in header
  $(".company_select").on "change", ->
    company_id = $(this).find(':selected').data('company-id')
    controller = $(this).find(':selected').data('controller')
    action = $(this).find(':selected').data('action')

    if action is 'new' or action is 'edit'
      unless confirm("Your changes will be discarded by switching company. Are you sure you want to switch company?")
        return true

    jQuery.get "/companies/#{company_id}/select", (response) ->
      jQuery("#current_selected_company").text(response)
      jQuery('.company_read_only').val(response) if jQuery('.company_read_only').length > 0
      window.location.reload()

  # validate company on save and update
  jQuery("form#new_company,form.edit_company").submit ->
    flag = true
    pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
    if jQuery("#company_company_name").val() is ""
      applyQtip(jQuery("#company_company_name"), "This field is required")
      flag = false
    else if jQuery("#company_contact_name").val() is ""
      applyQtip(jQuery("#company_contact_name"), "This field is required")
      flag = false
    else if jQuery("#company_email").val() is ""
      applyQtip(jQuery("#company_email"), "This field is required")
      flag = false
    else unless pattern.test(jQuery("#company_email").val())
      applyQtip(jQuery("#company_email"), "Invalid email")
      flag = false
    flag

  applyQtip = (elem, message, direction) ->
    elem.qtip
      content:
        text: message
      show:
        event: false
      hide:
        event: false
      position:
        at: "topRight"
      style:
        tip:
          corner: "leftMiddle"
    elem.qtip().show()
    elem.focus()

  hideQtip = (elem) ->
    elem.qtip("hide")

  jQuery("#company_contact_name,#company_email,#company_company_name").keypress ->
    hideQtip(jQuery(this))

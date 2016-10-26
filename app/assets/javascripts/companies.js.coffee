jQuery ->
  #/ Change selected company in companies list in header
  $("a.header_company_link").on "click",null, ->
     link = $(this)
     company_id = link.attr('company_id')
     controller = link.attr('controller')
     action = link.attr('action')

     if action is 'new' or action is 'edit'
       unless confirm("Your changes will be discarded by switching company. Are you sure you want to switch company?")
         return true

     jQuery.get "/companies/#{company_id}/select", (response) ->
       $("#current_selected_company").text(response)
       $('.company_read_only').val(response) if $('.company_read_only').length > 0
       window.location.reload()

  # validate company on save and update
  $("form#new_company,form.edit_company").submit ->
    flag = true
    pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
    if $("#company_company_name").val() is ""
      applyQtip($("#company_company_name"), "This field is required")
      flag = false
    else if $("#company_contact_name").val() is ""
      applyQtip($("#company_contact_name"), "This field is required")
      flag = false
    else if $("#company_email").val() is ""
      applyQtip($("#company_email"), "This field is required")
      flag = false
    else unless pattern.test($("#company_email").val())
      applyQtip($("#company_email"), "Invalid email")
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

  $("#company_contact_name,#company_email,#company_company_name").keypress ->
    hideQtip($(this))

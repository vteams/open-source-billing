# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
#  $(".chzn-select").chosen({allow_single_deselect: true})
  # Show/hide additional client contact section
  $("#contact").click ->
    $("#adCntcts").toggle 500, ->
      action = $(this).find("#action")
      action_text = $(action).html()
      action_text = (if action_text == "expand" then "collaps" else "expand")
      $(this).find("#id").html action_text

  $("#detail").click ->
    $("#add_Detail").toggle 500, ->
      action = $(this).find("#action")
      action_text = if $(action).html() == "expand" then "collaps" else "expand"
      $(this).find("#id").html action_text

  $("#submit_form").click ->
    $("#newClient").submit()

  # Validate client
  $("form#newClient,form#create_client,form#edit_client").submit ->
    flag = true
    pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
    client_email = $("#client_email").val()
    client_fname = $("#client_first_name").val()
    client_lname = $("#client_last_name").val()
    client_phone = $("#client_business_phone").val()
    client_mobile = $("#client_mobile_number").val()
    pattern_phone = /^\d+$/
    if client_email is ""
      applyQtip($("#client_email"), "Email is required", 'topRight')
      flag = false
    else unless pattern.test(client_email)
      applyQtip($("#client_email"), "Invalid email", 'topRight')
      flag = false
    else if client_fname is "" and client_lname is ""
      applyQtip($("#client_first_name"), "First or Last Name is required", 'topRight')
      flag = false
    else if client_phone isnt "" and !pattern_phone.test(client_phone)
      applyQtip($("#client_business_phone"), "Invalid business phone number", 'topRight')
      flag = false
    else  if client_mobile isnt "" and !pattern_phone.test(client_mobile)
      applyQtip($("#client_mobile_number"), "Invalid mobile number", 'topRight')
      flag = false
#    else if $("#client_organization_name").val() is ""
      #$("#client_organization_name").val(client_email)
    else if $('#company_association').is(':checked')
      if $('.options_content input[type=checkbox]:checked').length is 0
        applyQtip($("#company_association").next(),"Select a company", 'topRight')
        flag = false
    else if (($('#company_association').is(':checked') is  false) and ($('#account_association').is(':checked') is  false))
      $("#company_association").prop('checked', true);
      flag = false
    else
      hideQtip($("#client_email"))
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
        at: direction
      style:
        tip:
          corner: "leftMiddle"
    elem.qtip().show()
    elem.focus()

  hideQtip = (elem) ->
    elem.qtip("hide")

  $("#client_email, #client_first_name, #client_last_name").click ->
    hideQtip($(this))

  $('.edit_client .field_row .medium_field #calculated_credit').change ->
    client_credit = $(this)
    field = "<input id='available_credit' name='available_credit' type='hidden' value='#{client_credit.val()}'>"
    $('.edit_client .field_row .medium_field #client_credit').html(field)



  # show details when client name is clicked.
  $('table.client_listing').on 'click','.client_name', ->
    row = $(this).parents('tr')
    detail_row = row.next('tr.client_detail_row')

    # check if detail is already opened
    if detail_row.length
      detail_row.remove()
      row.removeAttr('style').find('td').removeAttr('style')
    else
      jQuery.ajax '/clients/client_detail',
                  type: 'POST'
                  data: "id=" + $(this).attr 'value'
                  dataType: 'html'
                  error: (jqXHR, textStatus, errorThrown) ->
                    alert "Error: #{textStatus}"
                  success: (data) ->
                    row.css("background-color", "#f3f3f3").find('td').css("border-bottom", "none")
                    $(data).insertAfter(row)
                    row.next().find(".scrollContainer").mCustomScrollbar scrollInertia: 150

  # remove client detail row by clicking cross
  $('.client_container_top').on 'click','.cross_btn', ->
    $(this).parents('tr').prev('tr').find('.client_name').click()

  $('#account_association').change ->
    if $(this).is ':checked'
      $('.company_checkbox').prop('checked',true)

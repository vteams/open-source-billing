# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
#  jQuery(".chzn-select").chosen({allow_single_deselect: true})
  # Show/hide additional client contact section
  jQuery("#contact").click ->
    jQuery("#adCntcts").toggle 500, ->
      action = $(this).find("#action")
      action_text = jQuery(action).html()
      action_text = (if action_text == "expand" then "collaps" else "expand")
      $(this).find("#id").html action_text

  jQuery("#detail").click ->
    jQuery("#add_Detail").toggle 500, ->
      action = $(this).find("#action")
      action_text = if jQuery(action).html() == "expand" then "collaps" else "expand"
      $(this).find("#id").html action_text

  jQuery("#submit_form").click ->
    jQuery("#newClient").submit()

  # Validate client
  jQuery("form#newClient,form#create_client").submit ->
    flag = true
    pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
    client_email = jQuery("#client_email").val()
    client_fname = jQuery("#client_first_name").val()
    client_lname = jQuery("#client_last_name").val()
    if client_email is ""
      applyQtip(jQuery("#client_email"), "Email is required", 'topRight')
      flag = false
    else unless pattern.test(client_email)
      applyQtip(jQuery("#client_email"), "Invalid email", 'topRight')
      flag = false
    else if client_fname is "" and client_lname is ""
      applyQtip(jQuery("#client_first_name"), "First or Last Name is required", 'topRight')
      flag = false
#    else if jQuery("#client_organization_name").val() is ""
      #jQuery("#client_organization_name").val(client_email)
    else if jQuery('#company_association').is(':checked')
      if jQuery('.options_content input[type=checkbox]:checked').length is 0
        applyQtip(jQuery("#company_association").next(),"Select a company", 'topRight')
        flag = false
    else
      hideQtip(jQuery("#client_email"))
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

  jQuery("#client_email, #client_first_name, #client_last_name").click ->
    hideQtip(jQuery(this))

  # show details when client name is clicked.
  jQuery('table.client_listing .client_name').live 'click', ->
    row = jQuery(this).parents('tr')
    detail_row = row.next('tr.client_detail_row')

    # check if detail is already opened
    if detail_row.length
      detail_row.remove()
      row.removeAttr('style').find('td').removeAttr('style')
    else
      jQuery.ajax '/clients/client_detail',
                  type: 'POST'
                  data: "id=" + jQuery(this).attr 'value'
                  dataType: 'html'
                  error: (jqXHR, textStatus, errorThrown) ->
                    alert "Error: #{textStatus}"
                  success: (data) ->
                    row.css("background-color", "#f3f3f3").find('td').css("border-bottom", "none")
                    jQuery(data).insertAfter(row)
                    row.next().find(".scrollContainer").mCustomScrollbar scrollInertia: 150

  # remove client detail row by clicking cross
  jQuery('.client_container_top .cross_btn').live 'click', ->
    jQuery(this).parents('tr').prev('tr').find('.client_name').click()




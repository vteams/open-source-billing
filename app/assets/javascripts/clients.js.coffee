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
    if client_email is ""
      applyQtip(jQuery("#client_email"),"Email is required")
      flag = false
    else unless pattern.test(client_email)
      applyQtip(jQuery("#client_email"),"Invalid email")
      flag = false
    else if jQuery("#client_organization_name").val() is ""
      jQuery("#client_organization_name").val(client_email)
    else
      hideQtip(jQuery("#client_email"))
    flag

  applyQtip = (elem,message) ->
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

  jQuery("#client_email").click ->
    hideQtip(jQuery(this))
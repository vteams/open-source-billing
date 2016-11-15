## validate company on save and update
#class @Subscription
#
#  @validateSubsciption: ->
#    jQuery("#new_subscription input").change ->
#      flag = true
#      pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
#      if jQuery("#login_company").val() is ""
#        Subscription.applyQtip(jQuery("#login_company"), "This field is required")
#        flag = false
##      else if jQuery("#company_contact_name").val() is ""
##        applyQtip(jQuery("#company_contact_name"), "This field is required")
##        flag = false
##      else if jQuery("#company_email").val() is ""
##        applyQtip(jQuery("#company_email"), "This field is required")
##        flag = false
##      else unless pattern.test(jQuery("#company_email").val())
##        applyQtip(jQuery("#company_email"), "Invalid email")
##        flag = false
#      alert flag
#      flag
#
#  @applyQtip: (elem, message, direction) ->
#    elem.qtip
#      content:
#        text: message
#      show:
#        event: false
#      hide:
#        event: false
#      position:
#        at: "topRight"
#      style:
#        tip:
#          corner: "leftMiddle"
#    elem.qtip().show()
#    elem.focus()
#
#    hideQtip = (elem) ->
#      elem.qtip("hide")
#
#    jQuery("#company_contact_name,#company_email,#company_company_name").keypress ->
#      hideQtip(jQuery(this))
#(global ? window).validateForms = validateForms

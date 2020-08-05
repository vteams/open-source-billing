
window.validateCreditCard = ->

  # all fields on credit card form are required
  jQuery("form#cc_form").submit ->
    jQuery(this).find("input[type=submit]").attr("disabled","disabled") if validateForm(jQuery(this))
    validateForm(jQuery(this))

  validateForm = (elem) ->
    valid_form = true

    # fetch all required inputs with empty value
    elem.find("input[required]").each (e,field) =>
      unless jQuery(field).val()
        jQuery(field).qtip({content:
          text: "This field is required",
          show:
            event: false, hide:
              event: false})
        jQuery(field).qtip().show()
        jQuery(field).focus()
        valid_form = false
    valid_form

  # hide qtip on keyup
  jQuery("form#cc_form input[required]").keyup ->
    jQuery(this).qtip("destroy") if jQuery(this).qtip()



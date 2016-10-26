
window.validateCreditCard = ->

  # all fields on credit card form are required
  $("form#cc_form").submit ->
    $(this).find("input[type=submit]").attr("disabled","disabled") if validateForm($(this))
    validateForm($(this))

  validateForm = (elem) ->
    valid_form = true

    # fetch all required inputs with empty value
    elem.find("input[required]").each (e,field) =>
      unless $(field).val()
        $(field).qtip({content:
          text: "This field is required",
          show:
            event: false, hide:
              event: false})
        $(field).qtip().show()
        $(field).focus()
        valid_form = false
    valid_form

  # hide qtip on keyup
  $("form#cc_form input[required]").keyup ->
    $(this).qtip("destroy") if $(this).qtip()



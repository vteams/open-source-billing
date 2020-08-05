jQuery ->

  jQuery('#sub_user_form').submit ->
    new validateForms(jQuery(this).attr('id')).validateRequired()

  jQuery('#change_password_form').submit ->
    new validateForms(jQuery(this).attr('id')).validateCurrentPassword()

  jQuery('#update_sub_user_form').submit ->
    new validateForms(jQuery(this).attr('id')).validateUpdatePassword()

  jQuery('#send_password').submit ->
    new validateForms(jQuery(this).attr('id')).validateEmail()

  jQuery('#new_user').submit ->
    new validateForms(jQuery(this).attr('id')).validateRequired()

  jQuery('#forgot_password').submit ->
    new validateForms(jQuery(this).attr('id')).validatePassword()

  stripe_button = (document.getElementsByClassName('stripe-button-el')[0])
  setTimeout (->
    stripe_button?.disabled = true
  ), 500

  validate_form= ($this) ->
    form = new validateForms(jQuery($this).parents('form:first').attr('id'))
    if form.validateCompany() and form.validateUsername() and form.validatePasswordMatch()
      stripe_button?.disabled = false
    else
      stripe_button?.disabled = true
#  jQuery('#new_subscription').find("#login_confrm_pswd").on 'keypress', ->
#    validate_form(this)
  jQuery('#new_subscription input').on 'change', ->
    validate_form(this)

  $('#side_form_role_ids').material_select('destroy');
  $('#side_form_role_ids').select2()

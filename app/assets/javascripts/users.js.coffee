jQuery ->

  jQuery('#sub_user_form').submit ->
    new validateForms(jQuery(this).attr('id')).validateRequired()

  jQuery('#change_password_form').submit ->
    new validateForms(jQuery(this).attr('id')).validateCurrentPassword()

  jQuery('#update_sub_user_form').submit ->
    new validateForms(jQuery(this).attr('id')).validateUpdatePassword()

  jQuery('#send_password,#user_login').submit ->
    new validateForms(jQuery(this).attr('id')).validateEmail()

  jQuery('#new_user').submit ->
    new validateForms(jQuery(this).attr('id')).validateRequired()

  jQuery('#forgot_password').submit ->
    new validateForms(jQuery(this).attr('id')).validatePassword()

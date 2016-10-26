jQuery ->

  $('#sub_user_form').submit ->
    new validateForms($(this).attr('id')).validateRequired()

  $('#change_password_form').submit ->
    new validateForms($(this).attr('id')).validateCurrentPassword()

  $('#update_sub_user_form').submit ->
    new validateForms($(this).attr('id')).validateUpdatePassword()

  $('#send_password,#user_login').submit ->
    new validateForms($(this).attr('id')).validateEmail()

  $('#new_user').submit ->
    new validateForms($(this).attr('id')).validateRequired()

  $('#forgot_password').submit ->
    new validateForms($(this).attr('id')).validatePassword()

# validate forms
class window.validateForms

  constructor: (@formId) ->
    @form = jQuery("##{@formId}")
    @requiredFields = @form.find("input[required]")
    @password = @form.find("input[name=password][required]")
    @current_password = @form.find("#user_current_password")
    @confirm_password = @form.find("input[name=password_confirmation][required]")
    @user_name = @form.find('#user_name')
    @org = @form.find('#login_company')
    @email = @form.find('#email')
    @password_update = @form.find("input[name=password]")
    @confirm_update = @form.find("input[name=password_confirmation]")
    @send_password_to = @form.find('.user_email')
    @inputs = @form.find('input')

    @hideQtip()

  # validate all required fields
  validateRequired: ->
#    @password = @form.find("#login_pswd") if @password?
    if @password?
       @password = if @form.find("#login_pswd").length == 0
                     @password
                   else
                     @form.find("#login_pswd")
#    @confirm_password = @form.find("#login_confrm_pswd") if @confirm_password?

    if @confirm_password?
       @confirm_password = if @form.find("#login_confrm_pswd").length == 0
                              @confirm_password
                           else
                              @form.find("#login_confrm_pswd")
    emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/

    if jQuery.trim(@user_name.val()) is ''
      @showQtip(@user_name, @getMessage('required'))
      false
    else if @org.val() is ''
      @showQtip(@org, @getMessage('required'))
      false
    else if @email.val() is ''
      @showQtip(@email, @getMessage('required'))
      false
    else if !emailReg.test(@email.val())
      @showQtip(@email, @getMessage("invalid_email"))
      false
    else if  @password.val() is ''
      @showQtip(@password, @getMessage("required"))
      false
    else if @password.val().length < 8
      @showQtip(@password, @getMessage('password_length'))
      false
    else if @password.val() != @confirm_password.val()
      @showQtip(@confirm_password, @getMessage("confirm"))
      false
    else
      true

  validateCurrentPassword: ->
    if @current_password.val() is ''
      @showQtip(@current_password, @getMessage("required"))
      false
    else
      true

  # validate update password
  validateUpdatePassword: ->
    if jQuery.trim(@user_name.val()) is ''
      @showQtip(@user_name, @getMessage('required'))
      false
    else if @email.val() is ''
      @showQtip(@email, @getMessage('required'))
      false
    else if @password_update.val()
        if @password_update.val().length < 8
          @showQtip(@password_update, @getMessage("password_length"))
          false
        else if @password_update.val() != @confirm_update.val()
          @showQtip(@confirm_update, @getMessage("confirm"))
          false
    else if @confirm_update.val() and  @password_update.val() is ''
          @showQtip(@password_update, @getMessage("required"))
          false
    else true

  validateEmail: ->
    emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/
    if @send_password_to.val() is ''
      @showQtip(@send_password_to, @getMessage("required_email"))
      false
    else if !emailReg.test(@send_password_to.val())
      @showQtip(@send_password_to, @getMessage("invalid_email"))
      false
    else
      true

  validatePassword: ->
    @password = @form.find("#login_pswd") if @password?
    @confirm_password = @form.find("#login_confrm_pswd") if @confirm_password?
    if @password.val().length < 8
      @showQtip(@password, @getMessage('password_length'))
      false
    else if @password.val() != @confirm_password.val()
      @showQtip(@confirm_password, @getMessage("confirm"))
      false
    else
      true

  showQtip: (field, message) ->
    field.qtip({content:
      text: message, show:
        event: false, hide:
          event: false})
    field.qtip().show()
    field.focus()

  hideQtip: ->
    @inputs.keyup ->
      jQuery(this).qtip("destroy") if jQuery(this).qtip()

  getMessage: (type) ->
    switch type
      when "required" then "This field is required"
      when "confirm" then "Password and confirm password do not match"
      when "password_length" then "Password should be 8 characters long"
      when "required_email" then "Email is required"
      when "invalid_email" then "Email you have entered is invalid"
      else
        "This field is required"
class @SubUser

  applyPopover = (elem,position,corner,message) ->
    elem.qtip
      content:
        text: message
      show:
        event: false
      hide:
        event: false
      position:
        at: position
      style:
        tip:
          corner: corner
    elem.qtip().show()
    elem.focus()

  hidePopover = (elem) ->
    elem.qtip("hide")

  @load_functions = ->

    $('.modal').modal complete: ->
      $('.qtip').remove()

#    $('select').material_select();
#    $('.select2').material_select('destroy');


    $("input").on 'keypress', ->
      hidePopover($(this))

    $("#password").on 'keypress', ->
      $(this).parent().removeClass('editMode');

    jQuery("#user_name,#email,#password,#password_confirmation").keypress ->
      hidePopover(jQuery(this))

    $("form#sub_user_form").submit ->
      flag = true
      email =  $("#email").val()
      pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
      editMode = $("#password").parent().hasClass('editMode')
      console.log editMode
      if $("#user_name").val() is ""
        applyPopover($("#user_name"),"bottomMiddle","topLeft", I18n.t("views.users.full_name_required"))
        flag = false
      else if email is ""
        applyPopover($("#email"),"bottomMiddle","topLeft", I18n.t("views.users.email_required"))
        flag = false
      else unless pattern.test(email)
        applyPopover($("#email"),"bottomMiddle","topLeft", I18n.t("views.users.email_invalid"))
        flag = false
      else if !editMode and $("#password").val is ""
        applyPopover($("#password"), 'bottomMiddle', "topLeft", I18n.t("views.users.password_required"))
        flag = false
      else if !editMode and $("#password").val().length < 8
        applyPopover($("#password"), 'bottomMiddle', "topLeft", I18n.t("views.users.pass_must_have_8_char"))
        flag = false
      else if !editMode and $("#password_confirmation").val is ""
        applyPopover($("#password_confirmation"), 'bottomMiddle', "topLeft", I18n.t("views.users.pass_confirmation_required"))
        flag = false
      else if !editMode and $("#password").val() != $("#password_confirmation").val()
        applyPopover($("#password_confirmation"), 'bottomMiddle', "topLeft", I18n.t("views.users.pass_and_confirm_pass_should_same"))
        flag = false
      else
        flag = true
      flag

  @init_settings_form = ->
    $("#side_form_user_name,#side_form_user_email,#side_form_password,#side_form_password_confirmation").keypress ->
      hidePopover(jQuery(this))
    $('#user_side_form').submit ->
      flag = true
      pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
      if $('#side_form_user_name').val() == ''
        applyPopover($("#side_form_user_name"), "bottomMiddle", "topLeft", I18n.t("views.users.full_name_required"))
        flag = false
      else if $('#side_form_user_email').val() == ''
        applyPopover($("#side_form_user_email"), "bottomMiddle", "topLeft", I18n.t("views.users.email_required"))
        flag = false
      else if !pattern.test($("#side_form_user_email").val())
        applyPopover($("#side_form_user_email"), "bottomMiddle", "topLeft", I18n.t('views.users.email_invalid'))
        flag = false
      else if $('#side_form_password').val() == ''
        applyPopover($("#side_form_password"), "bottomMiddle", "topLeft", I18n.t("views.users.password_required"))
        flag = false
      else if $('#side_form_password').val().length < 8
        applyPopover($("#side_form_password"), "bottomMiddle", "topLeft", I18n.t("views.users.pass_must_have_8_char"))
        flag = false
      else if $('#side_form_password_confirmation').val() == ''
        applyPopover($("#side_form_password_confirmation"), "bottomMiddle", "topLeft", I18n.t("views.users.pass_confirmation_required"))
        flag = false
      else if $('#side_form_password_confirmation').val() != $('#side_form_password').val()
        applyPopover($("#side_form_password_confirmation"), "bottomMiddle", "topLeft", I18n.t("views.users.pass_and_confirm_pass_should_same"))
        flag = false
      flag
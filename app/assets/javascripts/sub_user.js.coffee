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

    $('select').material_select();

    $("input").on 'keypress', ->
      hidePopover($(this))

    $("#password").on 'keypress', ->
      $(this).parent().removeClass('editMode');

    $("form#sub_user_form").submit ->
      flag = true
      email =  $("#email").val()
      pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
      editMode = $("#password").parent().hasClass('editMode')
      console.log editMode
      if $("#user_name").val() is ""
        applyPopover($("#user_name"),"bottomMiddle","topLeft","Full Name required")
        flag = false
      else if email is ""
        hidePopover($("#user_name"))
        applyPopover($("#email"),"bottomMiddle","topLeft","Email required")
        flag = false
      else unless pattern.test(email)
        applyPopover($("#email"),"bottomMiddle","topLeft","Invalid email")
        flag = false
      else if !editMode and $("#password").val is ""
        hidePopover($("#email"))
        applyPopover($("#password"), 'bottomMiddle', "topLeft", "Password required")
        flag = false
      else if !editMode and $("#password").val().length < 8
        applyPopover($("#password"), 'bottomMiddle', "topLeft", "Password length must be greator than or equal to 8")
        flag = false
      else if !editMode and $("#password_confirmation").val is ""
        hidePopover($("#password"))
        applyPopover($("#password_confirmation"), 'bottomMiddle', "topLeft", "Password confirmation required")
        flag = false
      else if !editMode and $("#password").val() != $("#password_confirmation").val()
        hidePopover($("#password"))
        applyPopover($("#password_confirmation"), 'bottomMiddle', "topLeft", "Password and confirmation should be matched")
        flag = false
      else
        hidePopover($("#password_confirmation"))
        flag = true
      flag
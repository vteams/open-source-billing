jQuery ->
  # Validate users
  jQuery("form#sub_user_form").submit ->
    flag = true
    password = $('.field_row .large_field #password')
    password_confirmation = $('.field_row .large_field #password_confirmation')
    if password.val() is ""
        applyPopover(jQuery(password),"bottomMiddle","topLeft","Please enter password")
        flag = false
    else if  password_confirmation.val() is ""
        applyPopover(jQuery(password_confirmation),"bottomMiddle","topLeft","Please enter password confirmation")
        flag = false
    else if password.val() isnt "" or password_confirmation.val() isnt ""
        if password.val() != password_confirmation.val()
          applyPopover(jQuery(password),"bottomMiddle","topLeft","Passwords doesn't matched")
          flag = false
        else
          flag = true
    else
      flag = true
    flag

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
class window.Import

  applyPopover = (elem,position,corner,message) ->
    console.log message
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

    $(".import_freshbook_form").submit ->
      account_url = $('#freshbooks_account_url').val()
      api_token = $('#freshbooks_api_token').val()
      flag = true

      if account_url is ""
        applyPopover($('#freshbooks_account_url'), "bottomMiddle","topLeft","Provide account url")
        flag = false
      else if api_token is ""
        hidePopover($('#freshbooks_account_url'))
        applyPopover($('#freshbooks_api_token'), "bottomMiddle","topLeft","Provide api token")
        flag = false
      else if $(".data-import-module input[type=checkbox]:checked").length < 1
        hidePopover($('#freshbooks_api_token'))
        applyPopover($('.data-import-module'), "bottomMiddle","topLeft","Atleast select one module to import")
        flag = false
      else
        hidePopover($('.data-import-module'))
        flag = true
      flag

    $("#freshbooks_account_url, #freshbooks_api_token").on 'keypress', ->
        hidePopover($(this))
exports.import = @Import
class @Popup

  @initialize = (elem) ->
    $(elem).modal complete: ->
      $('.qtip').remove()
      $(elem).remove()

    $('.modal-close').on 'click', ->
      $(this).parents('.modal').modal 'close'
#      $('select').material_select('destroy')

  @open = (elem) ->
    $(elem).modal('open')
    $(elem).css('z-index', '1004 !important')
    $('.modal-overlay').css('z-index', '1005 !important')
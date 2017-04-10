class @Search

  @LoadListingFunctions = ->

    $('.invoice-card').on 'click', (e) ->
      if e.target == e.currentTarget
        $(this).parent().find('a.invoice_show_link').click()

    $('.checkbox-item > input[type="checkbox"]').on 'change', ->
      n = $('input[type=\'checkbox\']:checked').length
      if $(this).is(':checked')
        $('#header').addClass 'chkbox-content'
        $('.header-right').addClass 'chekbox-show'
        $('.checkbox-item').find('.invoice-name').css 'opacity', '0'
        $('.checkbox-item').find('label').css 'opacity', '1'
        $('.search-holder form').hide()
        $('.card-white-panel .action-btn-group').hide()
        $('.checkboxinfo').show()
        $('.checkboxinfo .action-btn-group .send').show()
      else
        $('#header').addClass 'chkbox-content'
        $('.action-btn-group').hide()
        $('.checkboxinfo .action-btn-group').show()
        if n == 0
          $('.card-white-panel .action-btn-group').show()
          $('.checkbox-item').find('.invoice-name').css 'opacity', '1'
          $('.checkbox-item').find('label').css 'opacity', '0'
          $('.header-right').removeClass 'chekbox-show'
          $('#header').removeClass 'chkbox-content'
          $('.checkboxinfo .action-btn-group .edit').show()
          $('.checkboxinfo .action-btn-group .send').show()
        if n == 1
          $('.checkboxinfo .action-btn-group .edit').show()
          $('.checkboxinfo .action-btn-group .send').show()
      $('.chk-text').text n + ' Selected'
      return
    $('.checkbox-item').on 'click', (e) ->
      e.stopImmediatePropagation()
      return
class window.Search

  @LoadListingFunctions = ->

    $('.invoice-card').on 'click', (e) ->
      target = $(e.target)
      if (!target.is( "a" ) and !target.is("i"))
        $(this).parent().find('a.invoice_show_link')[0].click()

    initBulkActionCheckboxes();
    $('.checkbox-item').on 'click', (e) ->
      e.stopImmediatePropagation()
      return
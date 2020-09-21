class @InvoiceCard
  @show_popup_function = ->
    $('.invoice-card').on 'click', (e) ->
      url = $(this).data('invoice-url')
      $.ajax url,
        type: 'get',
        dataType: 'script'
#    target = $(e.target)
#    if (!target.is( "a" ) and !target.is("i"))
#      $(this).find('a.invoice_show_link').click()

#  $('#in-num').mouse_enter ->
#    $('#select_all_items').css('display', 'block')
#    $('#invoice-num').hide()
#  $('#in-num').mouse_leave ->
#    $('#select_all_items').hide()
#    $('#invoice-num').show()

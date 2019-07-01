$(document).ready ->
  $('.invoice-card').on 'click', (e) ->
    target = $(e.target)
    if (!target.is( "a" ) and !target.is("i"))
      $(this).find('a.invoice_show_link').click()

#  $('#in-num').mouse_enter ->
#    $('#select_all_items').css('display', 'block')
#    $('#invoice-num').hide()
#  $('#in-num').mouse_leave ->
#    $('#select_all_items').hide()
#    $('#invoice-num').show()

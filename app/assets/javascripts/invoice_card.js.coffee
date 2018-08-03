$(document).ready ->
  $('.invoice-card').on 'click', (e) ->
    target = $(e.target)
    if (!target.is( "a" ) and !target.is("i"))
      $(this).parent().find('a.invoice_show_link').click()

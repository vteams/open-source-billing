$(document).ready ->
  $('.invoice-card').on 'click', (e) ->
    if e.target == e.currentTarget
      $(this).parent().find('a.invoice_show_link').click()

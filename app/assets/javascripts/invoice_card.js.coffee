$(document).ready ->
  $('.invoice-card').on 'click', ->
    $(this).parent().find("a.invoice_show_link").click();

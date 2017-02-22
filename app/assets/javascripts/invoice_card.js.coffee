$(document).ready ->
  $('.invoice-card').on 'click', ->
    invoice_id = $(this).data('invoice_id')
    $.ajax 'invoices/'+invoice_id+'.js'
    return
  return
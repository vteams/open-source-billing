class @Invoice

  jQuery ->
    $('.line_total').before('<span class="line_total_currency"></span>')
    $('.line_total_currency').html(window.currency_symbol)
    OsbPlugins.applyDatePicker()
    OsbPlugins.selectUnselectAllCheckboxes()
    updateCurrencyUnitsAndDiscountSelect()
    OsbPlugins.updateMaterializeSelect()
    setDefaultDiscountValue()
    showClipboard()




  @changeTax = ->
    jQuery("select.tax1, select.tax2").on "change", ->
      if $(this).val() == ''
        $(this).parent('div').attr('title', I18n.t('views.common.please_select')).qtip()
      else
        vals = $(this).attr('id').split('_')
        per = $('#' + $(this).attr('id') + ' option:selected').data('tax_' + vals[vals.length - 1])
        $(this).parent('div').attr('title', per + '%').qtip()
      InvoiceCalculator.updateLineTotal(jQuery(this))
      InvoiceCalculator.updateInvoiceTotal()
    jQuery("#invoice_conversion_rate").on 'keyup', ->
      InvoiceCalculator.updateInvoiceTotal()


  @change_invoice_item  = (elem) ->

    $('.invoice_grid_fields select.items_list').on 'change', ->
      if parseInt($(this).find(':selected').val()) != -1
        OsbPlugins.hidePopover($("table#invoice_grid_fields tr.fields:visible:first td:nth-child(2)"))
        elem = $(this)
        if elem.val() == ''
          clearLineTotal elem
          InvoiceCalculator.updateInvoiceTotal()
          false
        else
          $.ajax load_item,
            type: 'POST'
            data: 'id=' + $(this).val()
            dataType: 'html'
            error: (jqXHR, textStatus, errorThrown) ->
              alert 'Error: ' + textStatus
            success: (data, textStatus, jqXHR) ->
              item = JSON.parse(data)
              container = elem.parents('tr.fields')
              container.find('textarea.description').val item[0]
              container.find('td.description').html item[0]
              container.find('input.cost').val item[1].toFixed(2)
              container.find('td.cost').html item[1].toFixed(2)
              container.find('input.qty').val item[2]
              container.find('td.qty').html item[2]
              #                OsbPlugins.empty_tax_fields(container)
              if item[3] != 0
                container.find('select.tax1').val(item[3]).trigger('contentChanged');
                container.find('input.tax-amount').val item[8]
                container.find('td.tax1').html item[6]
              if item[4] != 0
                container.find('select.tax2').val(item[4]).trigger('contentChanged');
                container.find('input.tax-amount').val item[9]
                container.find('td.tax2').html item[7]
              container.find('input.item_name').val item[5]

              InvoiceCalculator.updateLineTotal(elem)
              InvoiceCalculator.updateInvoiceTotal()

              $("#add_line_item").click ->
#              $('.invoice-client-select').material_select('destroy');
#                $('.select_2').select2();




  @setInvoiceDueDate = (invoice_date, term_days) ->
    $('#invoice_due_date_picker').on 'change', ->
      $('#invoice_payment_terms_id').val('4').select2()
    if term_days != null and invoice_date != null
      if term_days == '0' and $('#invoice_due_date_picker').val() != null
        $('#invoice_due_date_picker').val($('#invoice_date_picker').val())
        invoice_due_date_custom = $('#invoice_due_date_picker').val()
        if invoice_due_date_custom isnt ""
          $('#invoice_due_date_text').html invoice_due_date_custom
          $('#invoice_due_date').val invoice_due_date_custom
      else if term_days == '-1'

      else
        invoice_due_date = DateFormats.add_days_in_formated_date(invoice_date, parseInt(term_days))
        $('#invoice_due_date_picker').html invoice_due_date
        $('#invoice_due_date_picker').val invoice_due_date
    else
      $('#invoice_due_date').val ''

  updateCurrencyUnitsAndDiscountSelect = ->
    unit = $('#invoice_currency_id option:selected').text()
    if unit.length > 0
      $('#subtotal_currency_unit').text(unit)
      $('#discount_amount_currency_unit').text(unit)
      $('#tax_currency_unit').text(unit)
      $('#total_currency_unit').text(unit)
      $selectDropdown = $('#discount_type').empty().html(' ').prop("disabled", false)
      $selectDropdown.append($("<option></option>").attr("value", '%').text("%"))
      $selectDropdown.append($("<option></option>").attr("value", unit).text(unit))
      $selectDropdown.trigger('contentChanged')

  clearLineTotal = (elem) ->
    container = elem.parents('tr.fields')
    container.find('input.description').val ''
    container.find('input.cost').val ''
    container.find('input.qty').val ''
    InvoiceCalculator.updateLineTotal elem
    InvoiceCalculator.updateInvoiceTotal

  addLineItemRow = (elem) ->
    if elem.parents('tr.fields').next('tr.fields:visible').length == 1
      $('.invoice_grid_fields .add_nested_fields').click()

  setDefaultDiscountValue = ->
    setTimeout (->
      $('#discount_type').on 'change', ->
        $('#invoice_discount_percentage').val ''
        InvoiceCalculator.updateInvoiceTotal()
        $('#estimate_discount_percentage').val ''
        EstimateCalculator.updateEstimateTotal()
    ),1000

  showClipboard = ->
    $('.get_clipboard_url').click ->
      u = $(this).data('url')
      swal
        title: "URL"
        buttons: false
        timer: false
        text: u

$(document).ready ->
  $('#recurring').on 'change', ->
    if $(this).is(':not(:checked)')
      OsbPlugins.hidePopover($(".invoice_recurring_schedule_delivery_option"))
  if $('.occurrences_radio_button').eq(1).is(':checked')
    $('.remaining_occurrences').val($('.occurrences_radio_button').eq(1).attr('occurrence'))
  if $('#invoice_recurring_schedule_attributes_frequency').children('option:selected').html() == 'Custom'
    $('.custom-often').removeClass('hidden')
  setTimeout (->
    $('#invoice_recurring_schedule_attributes_frequency').on 'change', ->
      if $('#invoice_recurring_schedule_attributes_frequency').children('option:selected').html() == 'Custom'
        $('.custom-often').removeClass('hidden')
        $('.custom_frequency').on 'change', ->
          $('#invoice_recurring_schedule_attributes_frequency').children('option:selected').attr('number_of_days', DateFormats.get_next_issue_date($('#invoice_recurring_schedule_attributes_frequency_repetition').children('option:selected').val(),$('#invoice_recurring_schedule_attributes_frequency_type').children('option:selected').val()))
          $('#invoice_recurring_schedule_attributes_frequency').children('option:selected').val(DateFormats.get_next_issue_date($('#invoice_recurring_schedule_attributes_frequency_repetition').children('option:selected').val(),$('#invoice_recurring_schedule_attributes_frequency_type').children('option:selected').val()))
      else
        $('#invoice_recurring_schedule_attributes_frequency').children('option:contains("Custom")').removeAttr('number_of_days')
        $('#invoice_recurring_schedule_attributes_frequency').children('option:contains("Custom")').removeAttr('value')
        $('.custom-often').addClass('hidden')

  ),200

  $('.occurrence_input').on 'change', ->
    if $(document.getElementsByClassName('occurrence_input')[1]).is(':checked')
      $('.remaining_occurrences').prop('disabled', false)
      $('.occurrences_radio_button').eq(1).val($('.remaining_occurrences').val());
    else if $(document.getElementsByClassName('occurrence_input')[0]).is(':checked')
      $('.remaining_occurrences').val('')
      $('.remaining_occurrences').prop('disabled', true)

  $('#more_deleted_invoices').click ->
    $('.all-deleted-invoices').show()
    $('#more_deleted_invoices').hide()
  $('#less_deleted_invoices').click ->
    $('.all-deleted-invoices').hide()
    $('#more_deleted_invoices').show()

  $('#more_archived_invoices').click ->
    $('.all-archived-invoices').show()
    $('#more_archived_invoices').hide()
  $('#less_archived_invoices').click ->
    $('.all-archived-invoices').hide()
    $('#more_archived_invoices').show()

  #  $('.select_2').material_select('destroy');
  $('.select_2').select2();
  $('.form_select_2').select2({
    dropdownCssClass: "form_select_2"
  });
  $('.tax_select').select2({
    minimumResultsForSearch: -1,
    dropdownCssClass: "tax-dropdown"
  });
#  $('#invoice_recurring_schedule_attributes_frequency').append $('<option value=\'-2\'>Custom</option>')
  $('#invoice_recurring_schedule_attributes_frequency_repetition').select2()
  $('#invoice_recurring_schedule_attributes_frequency_type').select2()
  $('.currency-select').material_select();
  $('.dropdown-trigger').dropdown();

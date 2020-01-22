class @Estimate

  jQuery ->
    OsbPlugins.applyDatePicker()
    OsbPlugins.selectUnselectAllCheckboxes()
    updateCurrencyUnitsAndDiscountSelect()
    OsbPlugins.updateMaterializeSelect()


  @changeTax = ->
    jQuery("select.tax1, select.tax2").on "change", ->
      if $(this).val() == ''
        $(this).parent('div').attr('title', I18n.t('views.common.please_select')).qtip()
      else
        vals = $(this).attr('id').split('_')
        per = $('#' + $(this).attr('id') + ' option:selected').data('tax_' + vals[vals.length - 1])
        $(this).parent('div').attr('title', per + '%').qtip()
      EstimateCalculator.updateLineTotal(jQuery(this))
      EstimateCalculator.updateEstimateTotal()

  @change_estimate_item  = ->
    $('.estimate_grid_fields select.items_list').on 'change', ->
      if parseInt($(this).find(':selected').val()) != -1
        OsbPlugins.hidePopover($("table#estimate_grid_fields tr.fields:visible:first td:nth-child(2)"))
        elem = undefined
        elem = $(this)
        if elem.val() == ''
          clearLineTotal elem
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
              container.find('input.description').val item[0]
              container.find('td.description').html item[0]
              container.find('input.cost').val item[1].toFixed(2)
              container.find('td.cost').html item[1].toFixed(2)
              container.find('input.qty').val item[2]
              container.find('td.qty').html item[2]
#              OsbPlugins.empty_tax_fields(container)
              if item[3] != 0
                container.find('select.tax1').val(item[3]).trigger('contentChanged');
                container.find('input.tax-amount').val item[8]
                container.find('td.tax1').html item[6]
              if item[4] != 0
                container.find('select.tax2').val(item[4]).trigger('contentChanged');
                container.find('input.tax-amount').val item[9]
                container.find('td.tax2').html item[7]
              container.find('input.item_name').val item[5]
              EstimateCalculator.updateLineTotal(elem)
              EstimateCalculator.updateEstimateTotal()

  updateCurrencyUnitsAndDiscountSelect = ->
    unit = $('#estimate_currency_id option:selected').text()
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
    EstimateCalculator.updateLineTotal elem
    EstimateCalculator.updateEstimateTotal()

  addLineItemRow = (elem) ->
    if elem.parents('tr.fields').next('tr.fields:visible').length == 1
      $('.estimate_grid_fields .add_nested_fields').click()

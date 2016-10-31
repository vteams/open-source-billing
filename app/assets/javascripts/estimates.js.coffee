# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $("a.deleted_entry").click (e)->
    applyPopover($(this),"bottomMiddle","topLeft","Please recover to view details")
    e.preventDefault()
    return false

  window.applyChosen()

  window.tableListing()

  window.validateCreditCard()

  # Calculate the line total for invoice
  updateLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    cost = $(container).find("input.cost").val()
    qty = $(container).find("input.qty").val()
    cost = 0 if not cost? or cost is "" or not jQuery.isNumeric(cost)
    qty = 0 if not qty? or qty is "" or not jQuery.isNumeric(qty)
    line_total = ((parseFloat(cost) * parseFloat(qty))).toFixed(2)
    $(container).find(".line_total").text(line_total)

  # Calculate grand total from line totals
  updateInvoiceTotal = ->

    total = 0
    tax_amount = 0
    discount_amount = 0
    $("table.estimate_grid_fields tr:visible .line_total").each ->
      line_total = parseFloat($(this).text())
      total += line_total
      #update invoice sub total lable and hidden field
      $("#estimate_sub_total, #recurring_profile_sub_total").val(total.toFixed(2))
      $("#estimate_sub_total_lbl").text(total.toFixed(2))

      #update estimate total lable and hidden field
      $("#estimate_estimate_total, #recurring_profile_estimate_total").val(total.toFixed(2))
      $("#estimate_total_lbl").text(total.toFixed(2))

      tax_amount += applyTax(line_total,$(this))

    discount_amount = applyDiscount(total)

    #update tax amount label and tax amount hidden field
    $("#estimate_tax_amount_lbl").text(tax_amount.toFixed(2))
    $("#estimate_tax_amount, #recurring_profile_tax_amount").val(tax_amount.toFixed(2))

    #update discount amount lable and discount hidden field
#    $("#estimate_discount_amount_lbl").text(discount_amount.toFixed(2))
    $("#estimate_discount_amount, #recurring_profile_discount_amount").val((discount_amount * -1).toFixed(2))

    total_balance = (parseFloat($("#estimate_total_lbl").text() - discount_amount) + tax_amount)
    $("#estimate_estimate_total, #recurring_profile_estimate_total").val(total_balance.toFixed(2))
    $("#estimate_total_lbl").text(total_balance.toFixed(2))
    $("#estimate_total_lbl").formatCurrency({symbol: window.currency_symbol})

    window.taxByCategory()

  # Apply Tax on totals
  applyTax = (line_total,elem) ->
    tax1 = elem.parents("tr").find("select.tax1 option:selected").attr('data-tax_1')
    tax2 = elem.parents("tr").find("select.tax2 option:selected").attr('data-tax_2')
    tax1 = 0 if not tax1? or tax1 is ""
    tax2 = 0 if not tax2? or tax2 is ""
    # if line total is 0
    tax1=tax2=0 if line_total is 0
    discount_amount = applyDiscount(line_total)
    total_tax = (parseFloat(tax1) + parseFloat(tax2))
    (line_total - discount_amount) * (parseFloat(total_tax) / 100.0)

  # Apply discount percentage on subtotals
  applyDiscount = (subtotal) ->
    discount_percentage = $("#estimate_discount_percentage").val() || $("#recurring_profile_discount_percentage").val()
    discount_type = $("select#discount_type").val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    if discount_type == "%" then (subtotal * (parseFloat(discount_percentage) / 100.0)) else discount_percentage

  # Update line and grand total if line item fields are changed
  $("input.cost, input.qty").on "blur",null, ->
    updateLineTotal($(this))
    updateInvoiceTotal()

  $("input.cost, input.qty").on "keyup",null, ->
    updateLineTotal($(this))
    updateInvoiceTotal()
  #$(this).popover "hide"

  # Update line and grand total when tax is selected from dropdown
  $("select.tax1, select.tax2").on "change",null, ->
    updateInvoiceTotal()

  # Prevent form submission if enter key is press in cost,quantity or tax inputs.
  $("input.cost, input.qty").on "keypress",null, (e) ->
    if e.which is 13
      e.preventDefault()
      false

  # Load Items data when an item is selected from dropdown list
  $(".estimate_grid_fields").on "change",'select.items_list', ->
    # Add an empty line item row at the end if last item is changed.
    elem = $(this)
    if elem.val() is ""
      clearLineTotal(elem)
      false
    else
      addLineItemRow(elem)
      jQuery.ajax '/items/load_item_data',
        type: 'POST'
        data: "id=" + $(this).val()
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          alert "Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
          item = JSON.parse(data)
          container = elem.parents("tr.fields")
          # populate item's discription, cost, quantity and taxes.
          container.find("input.description").val(item[0])
          container.find("input.cost").val(item[1].toFixed(2))
          container.find("input.qty").val(item[2])
          container.find("select.tax1,select.tax2").val('').trigger("liszt:updated")
          container.find("select.tax1").val(item[3]).trigger("liszt:updated") if item[3] isnt 0
          container.find("select.tax2").val(item[4]).trigger("liszt:updated") if item[4] isnt 0
          container.find("input.item_name").val(item[5])
          updateLineTotal(elem)
          updateInvoiceTotal()

  # Add empty line item row
  addLineItemRow = (elem) ->
    if elem.parents('tr.fields').next('tr.fields:visible').length is 0
      $(".add_nested_fields").click()
  #applyChosen($('.estimate_grid_fields tr.fields:last .chzn-select'))

  $(".add_nested_fields").on "click",null, ->
    setTimeout "window.applyChosen($('.estimate_grid_fields tr.fields:last .chzn-select'))", 0

  # Re calculate the total estimate balance if an item is removed
  $(".remove_nested_fields").on "click",null, ->
    setTimeout (->
      updateInvoiceTotal()
    ), 100

  # Subtract discount percentage from subtotal
  $("#estimate_discount_percentage, #recurring_profile_discount_percentage").on "blur keyup", ->
    updateInvoiceTotal()

  # Subtract discount percentage from subtotal
  $("select#discount_type").change ->
    updateInvoiceTotal()

  # Don't allow nagetive value for discount
  $("#estimate_discount_percentage, #recurring_profile_discount_percentage,.qty").keydown (e) ->
    if e.keyCode is 109 or e.keyCode is 13
      e.preventDefault()
      false

  # Don't allow paste and right click in discount field
  $("#estimate_discount_percentage, #recurring_profile_discount_percentage, .qty").bind "paste contextmenu", (e) ->
    e.preventDefault()

  # Add date picker to estimate date , estimate due date and payment date.
  $("#estimate_estimate_date, #estimate_due_date, .date_picker_class").datepicker
    dateFormat: DateFormats.format()
    beforeShow: (input, inst) ->
      widget = $(inst).datepicker('widget')
      widget.css('margin-left', $(input).outerWidth() - widget.outerWidth())

  # Makes the estimate line item list sortable
  $("#estimate_grid_fields tbody").sortable
    handle: ".sort_icon"
    items: "tr.fields"
    axis: "y"

  # Calculate line total and estimate total on page load
  $(".estimate_grid_fields tr:visible .line_total").each ->
    updateLineTotal($(this))
    # dont use decimal points in quantity and make cost 2 decimal points
    container = $(this).parents("tr.fields")
    cost = $(container).find("input.cost")
    qty = $(container).find("input.qty")
    cost.val(parseFloat(cost.val()).toFixed(2)) if cost.val()
    qty.val(parseInt(qty.val())) if qty.val()
  updateInvoiceTotal()

  # dispute popup validation
  $("form.dispute_form").submit ->
    flag = true
    if $("#reason_for_dispute").val() is ""
      applyPopover($("#reason_for_dispute"),"bottomMiddle","topLeft","Enter reason for dispute")
      flag = false
    flag
  $("#reason_for_dispute").on "keyup",null, ->
    $(this).qtip("hide")

  # Validate client, cost and quantity on estimate save
  $(".estimate-form.form-horizontal").submit ->
    discount_percentage = $("#estimate_discount_percentage").val()
    discount_type = $("select#discount_type").val()
    sub_total = $('#estimate_sub_total').val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    item_rows = $("table#estimate_grid_fields tr.fields:visible")

    flag = true
    # Check if company is selected
    if $("#estimate_company_id").val() is ""
      applyPopover($("#estimate_company_id_chzn"),"bottomMiddle","topLeft","Select a company")
      flag = false
      # Check if client is selected
    else if $("#estimate_client_id").val() is ""
      applyPopover($("#estimate_client_id_chzn"),"bottomMiddle","topLeft","Select a client")
      flag = false
      # if currency is not selected
    else if $("#estimate_currency_id").val() is "" and $("#estimate_currency_id").is( ":hidden" ) == false
      applyPopover($("#estimate_currency_id_chzn"),"bottomMiddle","topLeft","Select currency")
      flag = false
      # check if estimate date is selected
    else if $("#estimate_estimate_date").val() is ""
      applyPopover($("#estimate_estimate_date"),"rightTop","leftMiddle","Select estimate date")
      flag =false
    else if $("#estimate_estimate_date").val() isnt "" and !DateFormats.validate_date($("#estimate_estimate_date").val())
      applyPopover($("#estimate_estimate_date"),"rightTop","leftMiddle","Make sure date format is in '#{DateFormats.format()}' format")
      flag = false
      # Check if discount percentage is an integer
    else if $("input#estimate_discount_percentage").val()  isnt "" and isNaN($("input#estimate_discount_percentage").val())
      applyPopover($("#estimate_discount_percentage"),"bottomMiddle","topLeft","Enter Valid Discount")
      flag = false
      # Check if no item is selected
    else if $("tr.fields:visible").length < 1
      applyPopover($("#add_line_item"),"bottomMiddle","topLeft","Add line item")
      flag = false
      # Check if item is selected
    else if item_rows.find("select.items_list option:selected[value='']").length is item_rows.length
      first_item = $("table#estimate_grid_fields tr.fields:visible:first").find("select.items_list").next()
      applyPopover(first_item,"bottomMiddle","topLeft","Select an item")
      flag = false
    else if discount_type == '%' and parseFloat(discount_percentage) > 100.00
      applyPopover($("#estimate_discount_percentage"),"bottomMiddle","topLeft","Percentage must be hundred or less")
      flag = false
    else if discount_type != '%' and parseFloat(discount_percentage) > parseFloat(sub_total)
      applyPopover($("#estimate_discount_percentage"),"bottomMiddle","topLeft","Discount must be less than sub-total")
      flag = false

      # Item cost and quantity should be greater then 0

    else
      $("tr.fields:visible").each ->
        row = $(this)
        if row.find("select.items_list").val() isnt ""
          cost = row.find(".cost")
          qty =  row.find(".qty")
          tax1 = row.find("select.tax1")
          tax2 = row.find("select.tax2")
          tax1_value = $("option:selected",tax1).val()
          tax2_value = $("option:selected",tax2).val()

          if not jQuery.isNumeric(cost.val()) and cost.val() isnt ""
            applyPopover(cost,"bottomLeft","topLeft","Enter valid Item cost")
            flag = false
          else hidePopover(cost)

          if not jQuery.isNumeric(qty.val())  and qty.val() isnt ""
            applyPopover(qty,"bottomLeft","topLeft","Enter valid Item quantity")
            flag = false
          else if (tax1_value is tax2_value) and (tax1_value isnt "" and tax2_value isnt "")
            applyPopover(tax2.next(),"bottomLeft","topLeft","Tax1 and Tax2 should be different")
            flag = false
          else hidePopover(qty)
    flag


  applyPopover = (elem,position,corner,message) ->
    elem.qtip
      content:
        text: message
      show:
        event: false
      hide:
        event: false
      position:
        at: position
      style:
        tip:
          corner: corner
    elem.qtip().show()
    elem.focus()

  useAsTemplatePopover = (elem,id,client_name) ->
    elem.qtip
      content:
        text: "<a href='/estimates/#{id}/edit/'>To create new estimate use the last estimate send to '#{client_name}'.</a><span class='close_qtip'>x</span>"
      show:
        event: false
      hide:
        event: false
      position:
        at: "rightTop"
      style:
        classes: 'use_as_template'
        tip:
          corner: "bottomLeft"
    elem.qtip().show()
    qtip = $(".qtip.use_as_template")
    qtip.css("top",qtip.offset().top - qtip.height())
    qtip.attr('data-top',qtip.offset().top - qtip.height())
    elem.focus()

  hidePopover = (elem) ->
    #elem.next(".popover").hide()
    elem.qtip("hide")

  # Hide use as template qtip
  $('.use_as_template').on "click",'.close_qtip', ->
    hidePopover($("#estimate_client_id_chzn"))

  $("#estimate_client_id_chzn,.chzn-container").on "click",null, ->
    $(this).qtip("hide")

  $("#add_line_item").on "click",null,->
    $(this).qtip('hide')

  $(".line_item_qtip").on "change",null,->
    $(this).qtip('hide')

  # Don't send an ajax request if an item is deselected.
  clearLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    container.find("input.description").val('')
    container.find("input.cost").val('')
    container.find("input.qty").val('')
    container.find("select.tax1,select.tax2").val('').trigger("liszt:updated")
    updateLineTotal(elem)
    updateInvoiceTotal()

  $('#active_links a').on 'click',null, ->
    $('#active_links a').removeClass('active')
    $(this).addClass('active')

  $(".estimate_action_links input[type=submit]").click ->
    $(this).parents("FORM:eq(0)").find("table.table_listing").find(':checkbox').attr()

  # Load last estimate for client if any
  $("#estimate_client_id").unbind 'change'
  $("#estimate_client_id").change ->
    client_id = $(this).val()
    hidePopover($("#estimate_client_id_chzn")) if client_id is ""
    $("#last_estimate").hide()
    if not client_id? or client_id isnt ""

      jQuery.get('/clients/'+ client_id + '/default_currency')

      jQuery.ajax '/clients/get_last_estimate',
        type: 'POST'
        data: "id=" + client_id
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          alert "Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
          data = JSON.parse(data)
          id = jQuery.trim(data[0])
          client_name = data[1]
          unless id is "no estimate"
            #useAsTemplatePopover($("#estimate_client_id_chzn"),id,client_name)
          else
            hidePopover($(".hint_text:eq(0)"))

  # Change currency of estimate
  $("#estimate_currency_id").unbind 'change'
  $("#estimate_currency_id").change ->
    currency_id = $(this).val()
    hidePopover($("#estimate_currency_id_chzn")) if currency_id is ""
    if not currency_id? or currency_id isnt ""
      jQuery.get('/estimates/selected_currency?currency_id='+ currency_id)


  jQuery.datepicker.setDefaults
    dateFormat: DateFormats.format()

  # Hide placeholder text on focus
  $("input[type=text],input[type=number]",".quick_create_wrapper").on("focus",null,->
    @dataPlaceholder = @placeholder
    @removeAttribute "placeholder"
  ).on("blur",null, ->
    @placeholder = @dataPlaceholder
    @removeAttribute "dataPlaceholder"
  ).on "keypress",null, (e) ->
    if e.which is 13
      e.preventDefault()
      $(".active-form .btn_save").trigger("click")
    hidePopover($(this))

  # Show quick create popups under create buttons
  $(".quick_create").click ->
    pos = $(this).position()
    height = $(this).outerHeight()
    $('.quick_create_wrapper').hide()
    $("##{$(this).attr('name')}").css(
      position: "absolute"
      top: (pos.top + height) + "px"
      left: pos.left + "px"
    ).show()

  $(".close_btn").on "click",null, ->
    $(this).parents('.quick_create_wrapper').hide().find("input").qtip("hide")

  # Alert on dispute if estimate is paid
  $('#dispute_link').click ->
    $('#reason_for_dispute').val('')
    flag = true
    status = $(this).attr "value"
    if status is "paid"
      alert "Paid estimate can not be disputed."
      flag = false
    flag

  $(".more").on "click",null, ->
    $(".toggleable").removeClass("collapse")

  $("#add_line_item").on "click",null, ->
    options = $('.items_list:first').html()
    $('.items_list:last').html(options).find('option:selected').removeAttr('selected')
    $('.items_list:last').find('option[data-type = "deleted_item"], option[data-type = "archived_item"], option[data-type = "other_company"], option[data-type = "active_line_item"]').remove()
    tax1 = $('.tax1:first').html()
    tax2 = $('.tax2:first').html()
    $('.tax1:last').html(tax1).find('option:selected').removeAttr('selected')
    $('.tax2:last').html(tax2).find('option:selected').removeAttr('selected')
    $('.tax1:last').find('option[data-type = "deleted_tax"], option[data-type = "archived_tax"], option[data-type = "active_line_item_tax"]').remove()
    $('.tax2:last').find('option[data-type = "deleted_tax"], option[data-type = "archived_tax"], option[data-type = "active_line_item_tax"]').remove()


  $(".less").on "click",null, ->
    $(".toggleable").addClass("collapse")

  #send only email to client on clicking send this note only link.
  $('#send_note_only').click ->
    jQuery.ajax '/estimates/send_note_only',
      type: 'POST'
      data: "response_to_client=" + $("#response_to_client").val() + "&inv_id=" + $("#inv_id").val()
      dataType: 'html'
      error: (jqXHR, textStatus, errorThrown) ->
        alert "Error: #{textStatus}"
      success: () ->
        $('.alert').hide();
        $(".alert.alert-success").show().find("span").html "This note has been sent successfully"

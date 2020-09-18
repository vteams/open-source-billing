class @Validation

  @UserSettingForm = ->
    $('#sub_user_form').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      ignore: 'input[type=hidden]'
      rules:
        user_name: required: true
        email: required: true
        role_id: required: true
        password: required: true
        password_confirmation:
          required: true

      messages:
        user_name: required: 'Full Name is required'
        email:  required: 'Email is required'
        role_id: required: 'Role is required'
        password: required: 'Password is required'
        password_confirmation: required: 'Password confirmation is required'


  @CompanySettingForm = ->
    $('#companyForm').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'company[company_name]': required: true
        'company[contact_name]': required: true
        'company[email]': required: true
      messages:
        'company[company_name]': required: 'Company Name is required'
        'company[contact_name]': required: 'Contact Name is required'
        'company[email]': required: 'Email is required'


  @RoleSettingForm = ->
    $('#role_side_form').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'role[name]': required: true
      messages:
        'role[name]': required: 'Name is required'


  @InvoiceForm = ->
    $('.invoice-client-select').on 'focusout', (e) ->
      $('#invoice_client_id').valid()

    $('#s2id_invoice_invoice_line_items_attributes_0_item_id').on 'focusout', (e) ->
      $('#invoice_invoice_line_items_attributes_0_item_id').valid()

    jQuery.validator.addMethod 'lessThan', ((value, element) ->
          return value <= $('#invoice_due_date_picker').val()
      ), 'Must be less or equal to invoice due date.'

    jQuery.validator.addMethod 'greaterThan', ((value, element) ->
          return value >= $('#invoice_date_picker').val()
      ), 'Must be greater or equal to invoice date.'

    $('.invoice-form').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      ignore: 'input[type=hidden]'
      rules:
        'invoice[client_id]': required: true
        'invoice[recurring_schedule_attributes][delivery_option]': required: '#recurring:checked'
        'invoice[invoice_date]': lessThan: true
        'invoice[due_date]': greaterThan: true
        'invoice[invoice_line_items_attributes][0][item_id]': required: true
      messages:
        'invoice[client_id]': required: 'Client is required'
        'invoice[recurring_schedule_attributes][delivery_option]': required: 'Select at least one delivery option'
        'invoice[invoice_line_items_attributes][0][item_id]': required: 'Line item is required'

      errorPlacement: ($error, $element) ->
        if ($element.attr('name') == 'invoice[client_id]')
          $('#s2id_invoice_client_id').append $error
        else if ($element.attr('name') == 'invoice[recurring_schedule_attributes][delivery_option]')
          $('.invoice_recurring_schedule_delivery_option').append $error
        else
          $error.insertAfter($element);



  @EstimateForm = ->
    $('.estimate-select-client').on 'focusout', (e) ->
      $('#estimate_client_id').valid()

    $('#s2id_estimate_estimate_line_items_attributes_0_item_id').on 'focusout', (e) ->
      $('#estimate_estimate_line_items_attributes_0_item_id').valid()

    $('.estimate-form').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      ignore: 'input[type=hidden]'
      rules:
        'estimate[client_id]': required: true
        'estimate[estimate_line_items_attributes][0][item_id]': required: true
      messages:
        'estimate[client_id]': required: 'Client is required'
        'estimate[estimate_line_items_attributes][0][item_id]': required: 'Line item is required'



  @ItemForm = ->
    $('.item_form').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'item[item_name]': required: true
        'item[item_description]': required: true
        'item[unit_cost]': required: true, number: true
        'item[quantity]': required: true, number: true

      messages:
        'item[item_name]': required: 'Name is required'
        'item[item_description]': required: 'Description is required'
        'item[unit_cost]': required: 'Unit Cost is required', number: 'Unit cost should be in numbers'
        'item[quantity]': required: 'Quantity is required', number: 'Quantity should be in numbers'



  @TaxForm = ->
    $('.tax_form').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'tax[name]': required: true
        'tax[percentage]': required: true, number: true
      messages:
        'tax[name]': required: 'Name is required'
        'tax[percentage]': required: 'Percentage is required', number: 'Percentage should be in numbers'



  @ClientForm = ->
    $('#newClient').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'client[organization_name]': required: true
        'client[first_name]': required: true
        'client[last_name]': required: true
        'client[email]': required: true
      messages:
        'client[organization_name]': required: 'Organization Name is required'
        'client[first_name]': required: 'First Name is required'
        'client[last_name]': required: 'Last Name is required'
        'client[email]': required: 'Email is required'



  @PaymentForm = ->
    $('#payments_form').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'payments[][payment_amount]': required: true, number: true
      messages:
        'payments[][payment_amount]': required: 'Amount is required', number: 'Please enter a valid amount'




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
        user_name: required: 'Name cannot be blank'
        email:  required: 'Email cannot be blank'
        role_id: required: 'Role cannot be blank'
        password: required: 'Password cannot be blank'
        password_confirmation: required: 'Password confirmation cannot be blank'


  @CompanySettingForm = ->
    $('#companyForm').submit ->
      $('.invalid-error').removeClass('hidden')
    $('.invalid-error').removeClass('hidden')
    $('#companyForm').validate
      onfocusout: (element) ->
        if !($("label[for='" + $(element).attr('id') + "']").hasClass('active'))
          $(element).valid()
        else
          $('#'+element.id+'-error').addClass('hidden')
      onkeyup: (element) ->
        $('#'+element.id+'-error').removeClass('hidden')
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'company[company_name]': required: true
        'company[contact_name]': required: true
        'company[email]': required: true
      messages:
        'company[company_name]': required: 'Company name cannot be blank'
        'company[contact_name]': required: 'Contact mame cannot be blank'
        'company[email]': required: 'Email cannot be blank'


  @RoleSettingForm = ->
    $('#new_role').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'role[name]': required: true
      messages:
        'role[name]': required: 'Name cannot be blank'


  @InvoiceForm = ->
    $('.invoice-client-select').on 'focusout', (e) ->
      $('#invoice_client_id').valid()

    $('#s2id_invoice_invoice_line_items_attributes_0_item_id').on 'focusout', (e) ->
      $('#invoice_invoice_line_items_attributes_0_item_id').valid()

    jQuery.validator.addMethod 'lessThan', ((value, element) ->
          return value <= $('#invoice_due_date_picker').val()
      ), 'Invoice date cannot be greater than due date'

    jQuery.validator.addMethod 'greaterThan', ((value, element) ->
          return value >= $('#invoice_date_picker').val()
      ), 'Due date cannot be less than invoice date'

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
        'invoice[invoice_date]': lessThan: true
        'invoice[due_date]': greaterThan: true
        'invoice[invoice_line_items_attributes][0][item_id]': required: true
      messages:
        'invoice[client_id]': required: 'Client cannot be blank'
        'invoice[invoice_line_items_attributes][0][item_id]': required: 'Item cannot be blank'



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
        'estimate[client_id]': required: 'Client cannot be blank'
        'estimate[estimate_line_items_attributes][0][item_id]': required: 'Item cannot be blank'



  @ItemForm = ->
    $('.item_form').submit ->
      $('.invalid-error').removeClass('hidden')
    $('.invalid-error').removeClass('hidden')
    $('.item_form').validate
      onfocusout: (element) ->
        if !($("label[for='" + $(element).attr('id') + "']").hasClass('active'))
          $(element).valid()
        else
          $('#'+element.id+'-error').addClass('hidden')
      onkeyup: (element) ->
        $('#'+element.id+'-error').removeClass('hidden')
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'item[item_name]': required: true
        'item[item_description]': required: true
        'item[unit_cost]': required: true, number: true
        'item[quantity]': required: true, number: true

      messages:
        'item[item_name]': required: 'Name cannot be blank'
        'item[item_description]': required: 'Description cannot be blank'
        'item[unit_cost]': required: 'Unit cost cannot be blank', number: 'Unit cost must be in numeric'
        'item[quantity]': required: 'Quantity cannot be blank', number: 'Quantity must be in numeric'



  @TaxForm = ->
    $('.tax_form').submit ->
      $('.invalid-error').removeClass('hidden')
    $('.invalid-error').removeClass('hidden')
    $('.tax_form').validate
      onfocusout: (element) ->
        if !($("label[for='" + $(element).attr('id') + "']").hasClass('active'))
          $(element).valid()
        else
          $('#'+element.id+'-error').addClass('hidden')
      onkeyup: (element) ->
        $('#'+element.id+'-error').removeClass('hidden')
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'tax[name]': required: true
        'tax[percentage]': required: true, number: true
      messages:
        'tax[name]': required: 'Name cannot be blank'
        'tax[percentage]': required: 'Percentage cannot be blank', number: 'Percentage must be in numeric'



  @ClientForm = ->
    $('#newClient').submit ->
      $('.invalid-error').removeClass('hidden')
    $('.invalid-error').removeClass('hidden')
    $('#newClient').validate
      onfocusout: (element) ->
        if !($("label[for='" + $(element).attr('id') + "']").hasClass('active'))
          $(element).valid()
        else
          $('#'+element.id+'-error').addClass('hidden')
      onkeyup: (element) ->
        $('#'+element.id+'-error').removeClass('hidden')
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'client[organization_name]': required: true
        'client[first_name]': required: true
        'client[last_name]': required: true
        'client[email]': required: true
      messages:
        'client[organization_name]': required: 'Organization name cannot be blank'
        'client[first_name]': required: 'First name cannot be blank'
        'client[last_name]': required: 'Last name cannot be blank'
        'client[email]': required: 'Email cannot be blank'



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
        'payments[][payment_amount]': required: 'Amount cannot be blank', number: 'Please enter a valid amount'




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
        user_name: required: true, alphanumeric: true
        email: required: true
        role_id: required: true
        password: required: true
        password_confirmation:
          required: true
        avatar: accept: 'jpg,jpeg,png'

      messages:
        user_name: required: 'Name cannot be blank'
        email:  required: 'Email cannot be blank'
        role_id: required: 'Role cannot be blank'
        password: required: 'Password cannot be blank'
        password_confirmation: required: 'Password confirmation cannot be blank'
        avatar: accept: 'Please upload image in these format only (jpg, jpeg, png).'

      errorPlacement: ($error, $element) ->
        if ($element.attr('name') == 'avatar')
          $('.file-field').append $error
        else
          $element.parent().closest('.input-field').append($error)

      $('.file-path').on 'change', ->
        $('#user_avatar').valid()


  @CompanySettingForm = ->
    jQuery.validator.addMethod 'alphanumeric', ((value, element) ->
      @optional(element) || /^[\w ]+$/i.test(value);
    ), 'Only Letters, Numbers and Underscores are allowed'

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
        'company[company_name]': required: true, alphanumeric: true
        'company[contact_name]': required: true, alphanumeric: true
        'company[email]': required: true
        'company[logo]': accept: 'jpg,jpeg,png'
      messages:
        'company[company_name]': required: 'Company name cannot be blank'
        'company[contact_name]': required: 'Contact name cannot be blank'
        'company[email]': required: 'Email cannot be blank'
        'company[logo]': accept: 'Please upload image in these format only (jpg, jpeg, png).'

      errorPlacement: ($error, $element) ->
        if ($element.attr('name') == 'company[logo]')
          $('.file-field').append $error
        else
          $element.parent().closest('.input-field').append($error)

      $('.file-path').on 'change', ->
        $('#company_logo').valid()



  @RoleSettingForm = ->
    $('#new_role').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'role[name]': required: true, alphanumeric: true
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

      jQuery.validator.addClassRules
        cost: min: 0
      jQuery.validator.addClassRules
        qtyy: min: 0

      jQuery.validator.messages.min = "Value should not be less than 0"



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
    jQuery.validator.addMethod 'dollarsscents', ((value, element) ->
      @optional(element) or /^\d{0,4}(\.\d{0,2})?$/i.test(value)
    ), 'Only two decimal places are allowed'

    jQuery.validator.addMethod 'alphanumeric', ((value, element) ->
      @optional(element) || /^[\w ]+$/i.test(value);
    ), 'Only Letters, Numbers and Underscores are allowed'

    $('.item_form').submit ->
        $('.invalid-error').removeClass('hidden')
      $('.invalid-error').removeClass('hidden')
    $('.item_form').validate
      onfocusin: (element) ->
        $(element).valid()
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
        'item[item_description]': required: true, alphanumeric: true
        'item[unit_cost]': required: true, number: true, dollarsscents: true
        'item[quantity]': required: true, number: true, dollarsscents: true
        'item[item_name]': required: true, alphanumeric: true, remote: {url: "/items/verify_item_name", type: "get", dataType: 'json', data: {
          'item_id': ->
            $('.item_id').html()
          'item_name': ->
            $('#item_item_name').val()
          'newItem': ->
            if ($('.item_form').hasClass('edit_item'))
              'edit_item'
        }
        }

      messages:
        'item[item_name]': required: 'Name cannot be blank', remote: 'Item with same name already exists'
        'item[item_description]': required: 'Description cannot be blank'
        'item[unit_cost]': required: 'Unit cost cannot be blank', number: 'Unit cost must be in numeric'
        'item[quantity]': required: 'Quantity cannot be blank', number: 'Quantity must be in numeric'



  @TaxForm = ->
    jQuery.validator.addMethod 'dollarsscents', ((value, element) ->
      @optional(element) or /^\d{0,4}(\.\d{0,2})?$/i.test(value)
    ), 'Only two decimal places are allowed'

    jQuery.validator.addMethod 'alphanumeric', ((value, element) ->
      @optional(element) || /^[\w ]+$/i.test(value);
      ), 'Only Letters, Numbers and Underscores are allowed'

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
        'tax[percentage]': required: true, number: true, max: 100, dollarsscents: true
        'tax[name]': required: true, alphanumeric: true, remote: {url: "/taxes/verify_tax_name", type: "get", dataType: 'json', data: {
          'tax_id': ->
            $('.tax_id').html()
          'tax_name': ->
            $('#tax_name').val()
          'newTax': ->
            if ($('.tax_form').hasClass('edit_tax'))
              'edit_tax'
        }
        }
      messages:
        'tax[percentage]': required: 'Percentage cannot be blank', number: 'Percentage must be in numeric', max: 'Tax percentage cannot exceeds to 100%'
        'tax[name]': required: 'Name cannot be blank', remote: 'Tax with same name already exists'



  @ClientForm = ->
    $('#newClient').submit ->
      $('.invalid-error').removeClass('hidden')
    $('.invalid-error').removeClass('hidden')

    jQuery.validator.addMethod 'emailRegex', ((value, element) ->
      return this.optional( element ) || /^.+@.+\..+$/.test( value );
    ), 'Please enter a valid email address'

    $('#newClient').validate
      onfocusin: (element) ->
        $(element).valid()
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
      ignore: 'input[type=hidden]'
      rules:
        'client[organization_name]': required: true, alphanumeric: true
        'client[first_name]': required: true, alphanumeric: true
        'client[last_name]': required: true, alphanumeric: true
        'client[role_id]': required: true
        'client[email]': required: true, emailRegex: true, remote: {url: "/clients/verify_email", type: "get", dataType: 'json', data: {
          'client_id': ->
            $('.client_id').html()
          'email': ->
            $('#client_email').val()
          'newClient': ->
            if ($('#newClient').hasClass('edit_client'))
              'edit_client'
        }
        }
      messages:
        'client[organization_name]': required: 'Organization name cannot be blank'
        'client[first_name]': required: 'First name cannot be blank'
        'client[last_name]': required: 'Last name cannot be blank'
        'client[role_id]': required: 'Role cannot be blank'
        'client[email]': required: 'Email cannot be blank', remote: "Email already exists"



  @PaymentForm = ->
    jQuery.validator.addMethod 'lessThanOrEqualToDueAmount', ((value, element) ->
      return value <= parseFloat($(element).closest('.small_field').find('span').html())
    ), 'Amount should not be greater than remaining amount'

    $('#payments_form').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      submitHandler: (form) ->
        valid = true
        jQuery('[id^=payments_payment_amount_]').each (e) ->
          if !$('#' + $(this).attr('id').split('-error')[0]).valid()
            valid = false
            return false
        if valid
         form.submit

      rules:
        'payments[][payment_amount]': required: true, number: true, min: 1, lessThanOrEqualToDueAmount: '.paid_full:checked'
      messages:
        'payments[][payment_amount]': required: 'Amount cannot be blank', number: 'Please enter a valid amount',
        min: 'Amount should be greater than 0'

      $('.payment_right').each ->
        parent = $(this)
        $(this).find('.paid_full').on 'change', ->
          parent.find('.payment_amount').valid()

    $('#new_payment').validate
      onfocusout: (element) ->
        $(element).valid()
      onkeyup: (element) ->
        $(element).valid()
      errorClass: 'error invalid-error'
      errorElement: 'span'
      rules:
        'payment[payment_amount]': required: true, number: true, min: 1, lessThanOrEqualToDueAmount: '.paid_full:checked'
      messages:
        'payment[payment_amount]': required: 'Amount cannot be blank', number: 'Please enter a valid amount',
        min: 'Amount should be greater than 0'

      $('#payment_paid_full').on 'change', ->
        $('#payment_payment_amount').valid()



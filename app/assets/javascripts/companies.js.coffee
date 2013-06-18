jQuery ->
  #/ Change selected company in companies list in header
  jQuery("a.header_company_link").live "click", ->
     company_id = jQuery(this).attr("company_id")
     jQuery.get "/application/new_selected_company_name?company_id=" + company_id, (response) ->
       jQuery("#current_selected_company").text(response)

  #update clients and items on company change
  #  jQuery('#invoice_company_id').change ->
  #    id = jQuery(this).attr('value')
  #    jQuery.ajax '/companies/get_clients_and_items',
  #                type: 'POST'
  #                data: "id=" + id
  #                dataType: 'html'
  #                error: (jqXHR, textStatus, errorThrown) ->
  #                  alert "Error: #{textStatus}"
  #                success: (data, textStatus, jqXHR) ->
  #                  data = JSON.parse(data)
  #                  if data[2] is 'Company'
  #                    jQuery('select#invoice_client_id').append(data[0]).trigger("liszt:updated")
  #                    jQuery('select.items_list').append(data[1]).trigger("liszt:updated")
  #                  else
  #                    jQuery("select#invoice_client_id option, select.items_list option").filter(->
  #                      @value or jQuery.trim(@value).length isnt 0
  #                    ).remove()
  #                    jQuery('select#invoice_client_id').append(data[0]).trigger("liszt:updated")
  #                    jQuery('select.items_list').append(data[1]).trigger("liszt:updated")


  # validate company on save and update
  jQuery("form#new_company,form.edit_company").submit ->
    flag = true
    pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
    if jQuery("#company_company_name").val() is ""
      applyQtip(jQuery("#company_company_name"), "This field is required")
      flag = false
    else if jQuery("#company_contact_name").val() is ""
      applyQtip(jQuery("#company_contact_name"), "This field is required")
      flag = false
    else if jQuery("#company_email").val() is ""
      applyQtip(jQuery("#company_email"), "This field is required")
      flag = false
    else unless pattern.test(jQuery("#company_email").val())
      applyQtip(jQuery("#company_email"), "Invalid email")
      flag = false
    flag

  applyQtip = (elem, message, direction) ->
    elem.qtip
      content:
        text: message
      show:
        event: false
      hide:
        event: false
      position:
        at: "topRight"
      style:
        tip:
          corner: "leftMiddle"
    elem.qtip().show()
    elem.focus()

  hideQtip = (elem) ->
    elem.qtip("hide")

  jQuery("#company_contact_name,#company_email,#company_company_name").keypress ->
    hideQtip(jQuery(this))

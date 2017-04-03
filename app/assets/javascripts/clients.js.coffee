# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
class @Client

  @load_functions = ->

    jQuery('#account_association').change ->
      if jQuery(this).is ':checked'
        $('.company_checkbox').prop('checked',true)

    $('.modal').modal complete: ->
      $('.qtip').remove()

    jQuery("form#newClient").submit ->
      flag = true
      pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
      client_email = jQuery("#client_email").val()
      client_fname = jQuery("#client_first_name").val()
      client_lname = jQuery("#client_last_name").val()
      client_phone = jQuery("#client_business_phone").val()
      client_mobile = jQuery("#client_mobile_number").val()
      pattern_phone = /^\d+$/
      if jQuery("#client_organization_name").val() is ""
        applyQtip(jQuery("#client_organization_name"), "Orangization name is required", 'topRight')
        flag = false
      else if client_fname is "" and client_lname is ""
        applyQtip(jQuery("#client_first_name"), "First or Last Name is required", 'topRight')
        flag = false
      else if client_email is ""
        applyQtip(jQuery("#client_email"), "Email is required", 'topRight')
        flag = false
      else unless pattern.test(client_email)
        applyQtip(jQuery("#client_email"), "Invalid email", 'topRight')
        flag = false
      else if client_phone isnt "" and !pattern_phone.test(client_phone)
        applyQtip(jQuery("#client_business_phone"), "Invalid business phone number", 'topRight')
        flag = false
      else  if client_mobile isnt "" and !pattern_phone.test(client_mobile)
        applyQtip(jQuery("#client_mobile_number"), "Invalid mobile number", 'topRight')
        flag = false
      else if $('#company_association').is(':checked')
        if $('.options_content input[type=checkbox]:checked').length is 0
          applyPopover($("#company_association"),"Select a company")
          flag = false
      else
        flag

    jQuery('#calculated_credit').change ->
      client_credit = jQuery(this)
      field = "<input id='available_credit' name='available_credit' type='hidden' value='#{client_credit.val()}'>"
      jQuery('#client_credit').html(field)

    jQuery("#client_organization_name, #client_mobile_number ,#client_business_phone, #client_email, #client_first_name, #client_last_name").on "blur keyup", ->
      hideQtip(jQuery(this))

  applyQtip = (elem, message, direction) ->
    elem.qtip
      content:
        text: message
      show:
        event: false
      hide:
        event: false
      position:
        at: direction
      style:
        tip:
          corner: "leftMiddle"
    elem.qtip().show()
    elem.focus()

  hideQtip = (elem) ->
    elem.qtip("hide")




jQuery ->
#  jQuery(".chzn-select").chosen({allow_single_deselect: true})
  # Show/hide additional client contact section
  jQuery("#contact").click ->
    jQuery("#adCntcts").toggle 500, ->
      action = $(this).find("#action")
      action_text = jQuery(action).html()
      action_text = (if action_text == "expand" then "collaps" else "expand")
      $(this).find("#id").html action_text

  jQuery("#detail").click ->
    jQuery("#add_Detail").toggle 500, ->
      action = $(this).find("#action")
      action_text = if jQuery(action).html() == "expand" then "collaps" else "expand"
      $(this).find("#id").html action_text


  # show details when client name is clicked.
  jQuery('table.client_listing .client_name').on 'click', ->
    row = jQuery(this).parents('tr')
    detail_row = row.next('tr.client_detail_row')

    # check if detail is already opened
    if detail_row.length
      detail_row.remove()
      row.removeAttr('style').find('td').removeAttr('style')
    else
      jQuery.ajax '/clients/client_detail',
                  type: 'POST'
                  data: "id=" + jQuery(this).attr 'value'
                  dataType: 'html'
                  error: (jqXHR, textStatus, errorThrown) ->
                    alert "Error: #{textStatus}"
                  success: (data) ->
                    row.css("background-color", "#f3f3f3").find('td').css("border-bottom", "none")
                    jQuery(data).insertAfter(row)
                    row.next().find(".scrollContainer").mCustomScrollbar scrollInertia: 150

  # remove client detail row by clicking cross
  jQuery('.client_container_top .cross_btn').on 'click', ->
    jQuery(this).parents('tr').prev('tr').find('.client_name').click()

  jQuery('#account_association').change ->
    if jQuery(this).is ':checked'
      $('.company_checkbox').prop('checked',true)
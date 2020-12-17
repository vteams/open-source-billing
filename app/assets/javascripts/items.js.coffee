# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('.invoice-card').on 'click', (e) ->
    if e.target == e.currentTarget
      $(this).parent().find('a.invoice_show_link').click()
    $("#company_association").prop('checked', true)
  # Validate client

class @Item

  applyPopover = (elem,message) ->
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

  hidePopover = (elem) ->
    elem.qtip("hide")

  @load_functions = ->

#    $('select').material_select()
    jQuery('#account_association').change ->
      if jQuery(this).is ':checked'
        $('.company_checkbox').prop('checked',true)
        $('#select_all_companies').prop('checked', false)


    jQuery('#company_association').change ->
      if jQuery(this).is ':checked'
        $('.company_checkbox').prop('checked',false)
        $('#select_all_companies').prop('checked', false)

    $('.modal').modal complete: ->
      $('.qtip').remove()

    jQuery("#item_item_name,#item_item_description,#item_unit_cost,#item_quantity").keypress ->
      hidePopover(jQuery(this))


  @check_uncheck_all_companies = ->
    $('#select_all_companies').on 'change', ->
      if $(this).is(':checked')
        $('.company_checkbox').prop 'checked', true
      else
        $('.company_checkbox').prop 'checked', false
      return

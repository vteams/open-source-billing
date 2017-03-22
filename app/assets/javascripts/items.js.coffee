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

    $('select').material_select()
    jQuery('#account_association').change ->
      if jQuery(this).is ':checked'
        $('.company_checkbox').prop('checked',true)

    $('.modal').modal complete: ->
      $('.qtip').remove()

    jQuery("#item_item_name, #item_item_description").keypress ->
      hidePopover(jQuery(this))




    $("form.item_form").submit ->
      flag = true
      if $.trim($("#item_item_name").val()) is ""
        applyPopover($("#item_item_name"),"Item name is required")
        flag = false
      else if $.trim($("#item_item_description").val()) is ""
        applyPopover($("#item_item_description"),"Description is required")
        flag = false
      else if ($('#company_association').is(':checked') is  false and $('#account_association').is(':checked') is  false)
        $("#company_association").prop('checked', true);
        flag = false
      else if $("#item_unit_cost").val() isnt "" and  isNaN($("#item_unit_cost").val())
        applyPopover($("#item_unit_cost"),"Must be numeric")
        flag = false
      else if ($("#item_tax_1").val() != "" or $("#item_tax_2").val() != "") and ($("#item_tax_1").val() == $("#item_tax_2").val())
        applyPopover($("#item_tax_2").parents('.select-wrapper'),"Same tax not applied on one item")
        flag = false
      else if $('#company_association').is(':checked')
        if $('.options_content input[type=checkbox]:checked').length is 0
          applyPopover($("#company_association"),"Select a company")
          flag = false
      flag







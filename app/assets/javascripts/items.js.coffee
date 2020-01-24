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

    $('.modal').modal complete: ->
      $('.qtip').remove()

    jQuery("#item_item_name,#item_item_description,#item_unit_cost,#item_quantity").keypress ->
      hidePopover(jQuery(this))

    $("form.item_form").submit ->
      flag = true
      association_name = $('input[name=association]:checked').attr("id")
      no_of_selected_companies = $('.company_checkbox:checked').length
      if $.trim($("#item_item_name").val()) is ""
        applyPopover($("#item_item_name"), I18n.t('views.items.name_required'))
        flag = false
      else if $.trim($("#item_item_description").val()) is ""
        applyPopover($("#item_item_description"), I18n.t('views.items.description_required'))
        flag = false
      else if ($('#company_association').is(':checked') is  false and $('#account_association').is(':checked') is  false)
        $("#company_association").prop('checked', true);
        flag = false
      else if $("#item_unit_cost").val() is ""
        applyPopover($("#item_unit_cost"), I18n.t('views.companies.field_requied'))
        flag = false
      else if $("#item_unit_cost").val() isnt "" and  isNaN($("#item_unit_cost").val())
        applyPopover($("#item_unit_cost"), I18n.t('views.items.must_be_numeric'))
        flag = false
#      else if $("#item_unit_cost").val() isnt "" and !isNaN($("#item_unit_cost").val())
#        applyPopover($("#item_unit_cost"), I18n.t('views.items.must_be_greater_than_zero'))
#        flag = false
      else if $("#item_quantity").val() is ""
        applyPopover($("#item_quantity"), I18n.t('views.items.quantity_required'))
        flag = false
      else if $("#item_quantity").val() isnt "" and  isNaN($("#item_quantity").val())
        applyPopover($("#item_quantity"), I18n.t('views.items.must_be_numeric'))
        flag = false
      else if $("#item_quantity").val() isnt "" and !isNaN($("#item_quantity").val()) and $('#item_quantity').val() < 0
        applyPopover($("#item_quantity"), I18n.t('views.items.must_be_greater_or_equal_to_zero'))
        flag = false
      else if ($("#item_tax_1").val() != "" or $("#item_tax_2").val() != "") and ($("#item_tax_1").val() == $("#item_tax_2").val())
        applyPopover($("#item_tax_2").parents('.select-wrapper'), I18n.t('views.items.same_tax_applied'))
        flag = false
      else if association_name == undefined
        applyPopover($("input[name=association]"),"topright","leftcenter", I18n.t('views.items.select_atleast_one_company'))
      else if (association_name == "company_association" and no_of_selected_companies == 0)
        applyPopover($("input[name=association]"),"topright","leftcenter", I18n.t('views.items.select_atleast_one_company'))
        flag = false
      else
        flag = true
        hidePopover($("input[name=association]"))
      flag

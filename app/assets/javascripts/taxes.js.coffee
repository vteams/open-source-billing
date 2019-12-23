# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
class @Tax

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
    jQuery("#tax_name,tax_percentage").keypress ->
      hidePopover(jQuery(this))
    jQuery("form#new_tax, form.edit_tax,form#create_tax").submit ->
      flag = true
      flag = if jQuery.trim(jQuery("#tax_name").val()) is ""
        applyPopover(jQuery("#tax_name"), I18n.t('views.taxes.enter_name'))
        false
      else if jQuery.trim(jQuery("#tax_percentage").val()) is ""
        applyPopover(jQuery("#tax_percentage"), I18n.t('views.taxes.enter_percentage'))
        false
      else if isNaN(jQuery("#tax_percentage").val())
        applyPopover(jQuery("#tax_percentage"), I18n.t('views.taxes.percentage_must_be_numeric'))
        false
      else if parseFloat(jQuery("#tax_percentage").val()) < 0
        applyPopover(jQuery("#tax_percentage"), I18n.t('views.taxes.greater_than_zero'))
        false
      else if parseFloat(jQuery("#tax_percentage").val()) > 100
        applyPopover(jQuery("#tax_percentage"), I18n.t('views.taxes.less_than_hundred'))
        false
      flag





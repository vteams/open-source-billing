// // This is a manifest file that'll be compiled into application.js, which will include all the files
// // This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery.min
//= require jquery_ujs
//= require jquery-ui.js
//= require materialize.min
//= require jquery.mCustomScrollbar.min
//= require range-slider
//= require custom
//= require highcharts
//= require exporting
//= require nested_fields
//= require nav.js
//= require chosen.jquery
//= require jquery.css3caching.js
//= require inline-forms.js.coffee
//= require projects.js.coffee
//= require estimates.js.coffee
//= require estimate_calculator
//= require expenses.js.coffee
//= require formatCurrency.js
//= require tableSorter.js
//= require tablesorter.staticrow.js
//= require jquery.metadata.js
//= require moment
//= require daterangepicker.min
//= require fullcalendar
//= require calendar.js
//= require logs.js
//= require clients.js.coffee
//= require client_additional_contacts.js.coffee
//= require client_contacts.js.coffee
//= require accounts.js.coffee
//= require dashboard.js.coffee
//= require invoice_line_items.js.coffee
//= require items.js.coffee
//= require activities.js.coffee
//= require notifications.js.coffee
//= require jqamp-ui-spinner.min.js
//= require jquery.qtip.min.js
//= require jwerty.js
//= require payments.js.coffee
//= require payment_terms.js.coffee
//= require reports.js.coffee
//= require taxes.js.coffee
//= require sonic.js
//= require progress_indicator.js.coffee
//= require jquery.tablehover.min.js
//= require tax_calculator.js.coffee
//= require jquery.formatCurrency-1.4.0.js
//= require table-listing.js.coffee
//= require credit-payment.js.coffee
//= require cc-validation.js.coffee
//= require jquery.customScrollbar.min.js
//= require users.js.coffee
//= require validate-forms.js.coffee
//= require jquery.ellipsis.js
//= require companies.js.coffee
//= require tasks.js.coffee
//= require staffs.js.coffee
//= require email_templates.js.coffee
//= require tinymce
//= require email_template.js
//= require recurring_profiles.js.coffee
//= require js/bootstrap/bootstrap-switch
//= require js/bootstrap/bootstrap-checkbox.min.js
//= require js/bootstrap/bootstrap-checkbox.js
//= require settings.js
//= require date_formats
//= require timer
//= require invoice_card
//= require invoice
//= require invoice_calculator
//= require osb_plugins
//= require import
//= require sub_user
//= require filter_bar
//= require filter_box
//= require select2.min
//= require search
//= require new_search
//= require popup
//= require js.cookie
//= require jstz
//= require browser_timezone_rails/set_time_zone
//= require i18n/translations
//= require sweetalert.min
//= require cocoon
//= require nouislider
//= require chartkick
//= require Chart.bundle
//= require jquery.infinite-pages
//= require introjs



jQuery(function () {
    $('#estimate_notes, #expense_note, #invoice_notes, #recurring_profile_notes, #log_notes').keypress(function(e) {
        var tval = $('textarea').val(), tlength = tval.length, max = 400,
        remain = parseInt(max - tlength);
       $('.text-limit').text(remain + "  characters remaining" );
    });

    jQuery("#nav .select .sub li").find("a.active").parents("ul.sub").prev("a").addClass("active");

//    jQuery("#nav ul.select > li").mouseenter(function () {
//        jQuery(".sub").hide();
//        jQuery(".sub", jQuery(this)).show();
//    });

    // Show sub menu on mouseover
    jQuery('#nav .select li.dropdown .dropdown-toggle,#nav .dropdown-menu').mouseover(function () {
        jQuery(this).parents('li.dropdown').find('.dropdown-menu').show();
        jQuery(".sub").hide();
        jQuery('#nav .dropup, #nav .dropdown').css('position', 'relative');
    }).mouseout(function () {
            jQuery(this).parents('li.dropdown').find('.dropdown-menu').hide();
            jQuery('#nav .dropup, #nav .dropdown').css('position', 'static');
        });
    // Hide other open header menu on mouseover
    jQuery('.primary_menu .dropdown').mouseover(function () {
        jQuery(this).siblings().removeClass('open');
    });

    jQuery("#nav").on("mouseleave", function (event) {
        if (event.pageY - $(window).scrollTop() <= 1) {
            jQuery(".sub").hide();
            jQuery("li a.active", jQuery(this)).next(".sub").show();
        }
        try {
            var e = event.toElement || event.relatedTarget;
            if (e.parentNode == jQuery(this).find('ul.select') || e == this)
                return;
            else {
                jQuery(".sub").hide();
                jQuery("li a.active", jQuery(this)).next(".sub").show();
            }
        }
        catch (e) {
        }
    });

    // toggle page effect by clicking on alpha tag
    jQuery(".logo_tag").click(function () {
        jQuery("#main-container").toggleClass("page-effect");
    }).qtip();

    (function ($) {
        initCustomConfirmPopUp();
        initLoginPageFormValidation();
        initCurrencySelect();
        $(window).load(function () {
            $(".scrollContainer").mCustomScrollbar({
                scrollInertia: 150,
                advanced: {
                    updateOnContentResize:true,
                    autoScrollOnFocus: false
                }
            });
        });
        $('.sent,.partial,.draft,.draft-partial,.paid,.disputed,.viewed').qtip();
        initPaginationSpanClick();
    })(jQuery);

    //jQuery(".revenue_by_client .grid_table table, .payments_collected .grid_table table").tableHover({colClass: 'col_hover', footCols: true, footRows: true, rowClass: 'row_hover'})
  initDateRangePicker(DateFormats.format().toUpperCase());
  initRangeSelector();
});

window.preventDeletedNavigation = function(){
    var applyPopover;

    applyPopover = function(elem, position, corner, message) {
        elem.qtip({
            content: {
                text: message
            },
            show: {
                event: false
            },
            hide: {
                event: false
            },
            position: {
                at: position
            },
            style: {
                tip: {
                    corner: corner
                }
            }
        });
        elem.qtip().show();
        return elem.focus();
    };

    bind_deleted_entry = function(){
        $("a.deleted_entry").unbind('click');
        $("a.deleted_entry").click(function(e){
            applyPopover(jQuery(this),"bottomMiddle","topLeft","Please Recover to View Details");
            e.preventDefault();
            return false;
        });
        $("a.deleted_entry").unbind('mouseleave');
        $("a.deleted_entry").mouseleave(function(e){
              $(this).qtip('hide');
              return false;
        });
    }
};
window.preventDeletedNavigation();
$(document).ready(function(){
    display_flash_notice_or_alert_with_toastr();
    bind_deleted_entry();

    $('.date-picker').pickadate({
        format: DateFormats.format()
    });

    $( ".btn-menu" ).click(function() {
        if($('#overly-container').hasClass('overlay') == false) {
            $('#overly-container').addClass('overlay');
            $('body').addClass('disable-scroll');
        }else if($('#overly-container').hasClass('overlay') == true) {
            $('#overly-container').removeClass('overlay');
            $('body').removeClass('disable-scroll');
        }
    });

    initSelectActionLink();
    initDemoLinksClick();
    disable_right_click_for_browser();
    disable_f12_key_in_browser();
});

function initCustomConfirmPopUp() {
    // Removing rails default confirm popup
    $.rails.confirm = function () { }

    $("[data-confirm]").off("click");
    $("[data-confirm]").on("click", function(e) {
        e.preventDefault();
        var link = this;

        // Showing Custom Popup
        swal({
            title: $(link).data('confirm'),
            text: $(link).data('text') ? $(link).data('text') : I18n.t('helpers.messages.not_be_recoverable'),
            icon: 'warning',
            buttons: [true, true],
        }).then(function(confirmed) {

            // If user confirm the action perform the action
            if(confirmed) {
                if($(link).data("method") === 'delete') {
                    $.ajax({
                        url: $(link).attr("href"),
                        dataType: "JSON",
                        method: "DELETE",
                        success: function () {
                            console.log('success')
                            swal(I18n.t('helpers.links.delete'), $(link).data('success'), 'success').then(
                                function (confirmed) {
                                    if($(link).data('redirect')) {
                                        window.location.href = $(link).data('redirect');
                                    } else {
                                        window.location.reload();
                                    }
                                });
                        },
                        error: function (obj) {
                            swal(I18n.t('helpers.links.delete'), obj.responseJSON.errors || I18n.t('helpers.messages.unable_to_delete'), 'error');
                        }
                    });
                } else {
                    window.location.href = $(link).attr("href");
                }
            }
        });
    });
}

function initLoginPageFormValidation() {
    $('#user_login').submit(function () {
        var flag = true;
        var pattern = /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i;
        if($('#email').val() === '') {
            applyPopover($("#email"), "bottomMiddle", "topLeft", I18n.t("views.companies.field_requied"));
            flag = false;
        } else if(!pattern.test($("#email").val())) {
            hidePopover($('#email'));
            applyPopover($("#email"), "bottomMiddle", "topLeft", I18n.t('views.companies.email_invalid'));
            flag = false;
        } else if ($('#password').val() === '') {
            hidePopover($('#email'));
            applyPopover($("#password"), "bottomMiddle", "topLeft", I18n.t("views.companies.field_requied"));
            flag = false;
        }
        return flag;
    });
}

function initCurrencySelect() {
    $('.search_currency').keyup(function(){
        var searchText = $(this).val().toLowerCase();
        $('#dropdown_currency > li:not(.search-bar)').each(function(){
            var currentLiText = $(this).text().toLowerCase(),
                showCurrentLi = currentLiText.indexOf(searchText) === -1;
            $(this).toggleClass('hide', showCurrentLi);
        });
    });
    $('#dLabel').click(function(e){
        $('#search_currency_bar').val('').keyup();
        $('#search_currency_bar').focus();
        $('#dropdown_currency').scrollTop(0);
    });

    var li = $('#dropdown_currency > li');
    var liSelected;
    $('.search_currency').on('keydown', function(e){
        var selected;
        if(e.which === 40){
            if(liSelected){
                liSelected.removeClass('selected');
                next = liSelected.nextAll('li').not('.hide').first();
                if(next.length > 0){
                    liSelected = next.addClass('selected');
                }else{
                    liSelected = li.eq(1).addClass('selected');
                }
            }else{
                liSelected = li.eq(1).addClass('selected');
            }
            $('#dropdown_currency').scrollTop($(liSelected).position().top - $('#dropdown_currency li:first').position().top);
        }else if(e.which === 38){
            if(liSelected){
                liSelected.removeClass('selected');
                next = liSelected.prevAll('li').not('.hide').first();
                if(next.length > 0){
                    liSelected = next.addClass('selected');
                }else{
                    liSelected = li.last().addClass('selected');
                }
            }else{
                liSelected = li.last().addClass('selected');
            }
            $('#dropdown_currency').scrollTop($(liSelected).position().top - $('#dropdown_currency li:first').position().top);
        }else if(e.which === 13){
            if(liSelected){
                liSelected.click();
            }
        }
    });
}

function showWarningSweetAlert(title, message, confirmCallback, cancelCallback) {
    swal({
        title: title,
        text: message,
        icon: 'warning',
        buttons: [true, true],
    }).then(function(confirmed) {

        // If user confirm the action perform the action
        if(confirmed) {
            confirmCallback();
        } else {
            if (cancelCallback) {
                cancelCallback();
            }
        }
    });

}

function initSelectActionLink(){
    $("select").off();
    $("select").on("change", function() {
        var controller_name;
        if (parseInt($(this).find(':selected').val()) == -1) {
            $(this).val('');
            controller_name = $(this).data('action-path');
            var position = $(this).attr('id');
            return $('#open_new_popup_link').attr('href', controller_name + "?type=add-new-popup&position="+position).click();
        }
    });
}

function disable_right_click_for_browser() {
    $("body").on("contextmenu", function () {
        return false;
    });
}

function disable_f12_key_in_browser(){
    document.onkeydown = function(e) {
        if(event.keyCode == 123) {
            return false;
        }
    }
}

function initDateRangePicker(format) {
  var options = {
    autoUpdateInput: false,
    locale: {format: format}
  };
  $.each($('input[class="date-range"]'), function(index, element) {
    $(element).daterangepicker(options, function(start, end) {
      $('#' + $(element).attr('id') + '_start_date').val(start.format(format));
      $('#' + $(element).attr('id') + '_end_date').val(end.format(format));
    });

    $(element).on('apply.daterangepicker', function(ev, picker) {
      $(this).val(picker.startDate.format(format) + ' - ' + picker.endDate.format(format));
    });

    $(element).on('cancel.daterangepicker', function(ev, picker) {
      $(this).val('');
      picker.element.val('');
      $('#' + $(element).attr('id') + '_start_date').val('');
      $('#' + $(element).attr('id') + '_end_date').val('');
    });
  });
}

function initRangeSelector() {
  $.each($('.range_selector'), function(index, element) {
    var min = parseInt($(element).attr('min'));
    var max = parseInt($(element).attr('max'));
    var hiddenInputs = [
      $('#' + $(element).attr('id') + '_min')[0],
      $('#' + $(element).attr('id') + '_max')[0]
    ];
    var labels = [
      $('#' + $(element).attr('id') + '_min_label')[0],
      $('#' + $(element).attr('id') + '_max_label')[0]
    ];
    noUiSlider.create(element, {
      start: [$(element).data('min') || min, $(element).data('max') || max],
      connect: true,
      step: 1,
      orientation: 'horizontal',
      range: {
        'min': min,
        'max': max
      }
    });
    element.noUiSlider.on('update', function( values, handle ) {
      hiddenInputs[handle].value = parseInt(values[handle]);
      labels[handle].innerHTML = parseInt(values[handle]);
    });

  });
}

function resetRangeSelectors() {
  $.each($('.range_selector'), function(index, element) {
    element.noUiSlider.destroy();
  });
  initRangeSelector();
}

function initFilterEvents(ids) {
  $(document).ready( function (event) {
    $('#toggle_filters').on('click', function (event) {
      toggleFilters();
    });
    $('#filter_reset_btn').on('click', function(event) {
      $('#filters select').val('');
      $(ids).val('');
      resetRangeSelectors();
      $('#filters_form').submit();
    });
    $('#filter_submit_btn').on('click', function (event) {
      $('#filters_form').submit();
    })
  });
}

function toggleFilters() {
  if($('#toggle_filters').attr('title') == I18n.t('views.common.show_filters')){
    $('#filters').slideDown('slow');
    $('#toggle_filters').attr('title', I18n.t('views.common.hide_filters'));
  } else {
    $('#filters').slideUp('slow');
    $('#toggle_filters').attr('title', I18n.t('views.common.show_filters'));
  }
}

function initDemoLinksClick() {
  $('.demo-mode').off('click');
  $('.demo-mode').on('click', function (event) {
    swal({
      title: 'Demo',
      text: I18n.t('views.common.demo_restriction_msg'),
      icon: 'info'
    });
  });
}

function display_flash_notice_or_alert_with_toastr(){

    var success_flash, flash_alert;
    var success_msg = $('#custom_flash_success').text().trim();
    var error_msg = $('#custom_flash_alert').text().trim();

    if(success_msg != ''){
        success_flash = $('#custom_flash_success').text();
    }
    else if(success_msg == '' && error_msg == ''){
        success_flash = $('#custom_flash_success').next('p').text();
    }
    else if(error_msg != ''){
        flash_alert = $('#custom_flash_alert').text();
    }
    else{
        flash_alert = $('#custom_flash_alert').next('p').text();
    }

    toastr.options = {
        'containerId': 'toast-container',
        'closeButton': true,
        'debug': false,
        'newestOnTop': false,
        'progressBar': false,
        'positionClass': "toast-top-center",
        'preventDuplicates': false,
        'onclick': null,
        'showDuration': "300",
        'hideDuration': "1000",
        "timeOut": "5000",
        'extendedTimeOut': "1000",
        'showEasing': "swing",
        'hideEasing': "linear",
        'showMethod': "fadeIn",
        'hideMethod': "fadeOut"
    };
    if (success_flash) {
        toastr.success('', success_flash);
    } else if(flash_alert) {
        toastr.error('', flash_alert);
    }
}

function initPaginationSpanClick() {
    $('nav.pagination span').click(function (event) {
        if( $(this).find('a').length > 0 ) {
            window.location.href = $(this).find('a').attr('href');
        }
    });
}
(function($) {
    $(function() {

        $('.dropdown-button').dropdown({
                inDuration: 300,
                outDuration: 225,
                hover: false, // Activate on hover
                belowOrigin: true, // Displays dropdown below the button
                alignment: 'right' // Displays dropdown with edge aligned to the left of button
            }
        );

    }); // End Document Ready
})(jQuery); // End of jQuery name space

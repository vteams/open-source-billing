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
//= require twitter/bootstrap
//= require materialize.min
//= require picker
//= require picker.date
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
//= require expenses.js.coffee
//= require formatCurrency.js
//= require tableSorter.js
//= require tablesorter.staticrow.js
//= require jquery.metadata.js
//= require application.js
//= require bootstrap.js.coffee
//= require moment
//= require fullcalendar
//= require calendar.js
//= require logs.js
//= require logs_invoice.js.coffee
//= require clients.js.coffee
//= require client_additional_contacts.js.coffee
//= require client_contacts.js.coffee
//= require accounts.js.coffee
//= require dashboard.js.coffee
//= require invoice_line_items.js.coffee
//= require items.js.coffee
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
//= require tax-calculations.js.coffee
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
//= require bootstrap-switch
//= require bootstrap-checkbox.min.js
//= require bootstrap-checkbox.js
//= require settings.js
//= require date_formats
//= require flipclock
//= require hourlycounter
//= require timer
//= require invoice_card
//= require new_invoice
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
    })(jQuery);

    //jQuery(".revenue_by_client .grid_table table, .payments_collected .grid_table table").tableHover({colClass: 'col_hover', footCols: true, footRows: true, rowClass: 'row_hover'})

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
    setTimeout(function() {
        $('#flash_message').fadeOut('slow');
    }, 5000);
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
            text: I18n.t('helpers.messages.not_be_recoverable'),
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
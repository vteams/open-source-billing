removeSideNavTitle = function(){
    $(".side-menu li > a").each(function(){
        $(this).removeAttr('title');
    });
}

addSideNavTitle = function(){
    $(".side-menu li > a").each(function(){
        var title = $(this).find('span').text()
        $(this).attr('title', title);
    });

}

$(document).ready(function(){
    $(".btn-search").click(function(){
        $(".header-right").addClass("search-show");
        $('.checkboxinfo').hide();
        $('.search-holder form').show();
    });
    $(".btn-back").click(function(){
        $(".header-right").removeClass("search-show");
        $(".chkbox-content .header-right").removeClass("chekbox-show");
    });
    //
    $(".btn-menu").click(function(){
      $('#graph_container').toggleClass('custom-graph');
      $('#graph_container').html('');
      Dashboard.plot_graph();
      $("#activity-sidebar").removeClass("show-activity");
      $("#side-nav,#main-content,#activity-sidebar, #flash_message").toggleClass("side-show");
      if($('#side-nav').hasClass('side-show'))
          removeSideNavTitle();
      else
        addSideNavTitle();


    });
    //
    $(".btn-activity").click(function(){
      $("#side-nav,#main-content,#activity-sidebar, #flash_message").removeClass("side-show");
      $("#activity-sidebar").toggleClass("show-activity");
    });
    //


    $('select').material_select();
    
     $('.modal').modal();
    
    $('#btn-help').click(function(){
        $(this).next().find('.total-income').toggleClass('show-panel');
    }); 
    
    $('.menudd').click(function(){
        $(this).parent().toggleClass('activedd'); 
     });
    
    
    //---Checkbox Items
    $('.checkbox-item > input[type="checkbox"]').on('change', function () {
        if(!$('.checkbox-item').hasClass('inline_team_member')){
            var n = $( "input[type='checkbox']:checked" ).length;
            if ($(this).is(':checked')){
                $('#header').addClass("chkbox-content");
                $(".header-right").addClass("chekbox-show");
                $('.checkbox-item').find('.invoice-name').css('opacity', '0');
                $('.checkbox-item').find('label').css('opacity', '1');
                $('.search-holder form').hide();
                $('.card-white-panel .action-btn-group').hide();
                $('.checkboxinfo').show();
                $('.checkboxinfo .action-btn-group .send').show();
            }
            else{
                $('#header').addClass("chkbox-content");
                $('.action-btn-group').hide();
                $('.checkboxinfo .action-btn-group').show();

                if(n == 0){
                    $('.card-white-panel .action-btn-group').show();
                    $('.checkbox-item').find('.invoice-name').css('opacity', '1');
                    $('.checkbox-item').find('label').css('opacity', '0');
                    $(".header-right").removeClass("chekbox-show");
                    $('#header').removeClass("chkbox-content");

                    $('.checkboxinfo .action-btn-group .edit').show();
                    $('.checkboxinfo .action-btn-group .send').show();
                }
                if(n == 1){
                    $('.checkboxinfo .action-btn-group .edit').show();
                    $('.checkboxinfo .action-btn-group .send').show();
                }
            }

            $( ".chk-text" ).text(n + " Selected");
        }

    });
    
    $(".checkbox-item").on("click", function(e){
        e.stopImmediatePropagation();
    });


    $(".header.action-btn-group a.delete").on('click', function(){
        $("input.top_links.destroy").click();
    });

    $(".header.action-btn-group a.send_active").on('click', function(){
        $("input.top_links.send_active").click();
    });

    $(".header.action-btn-group a.archive").on('click', function(){
        $("input.top_links.archive").click();
    });

    $(".header.action-btn-group a.payment").on('click', function(){
        $("input.top_links.payment").click();
    });

    $(".action-btn-group .single_archive").on('click', function(){
        $(this).parents(".invoice-card").find("input[type='checkbox']").prop("checked","checked")
        $("input.top_links.archive").click();
    });

    $(".header.action-btn-group a.recover_deleted").on('click', function(){
        $("input.top_links.recover_deleted").click();
    });

    $(".header.action-btn-group a.recover_archived").on('click', function(){
        $("input.top_links.recover_archived").click();
    });

    $(".header.action-btn-group a.destroy_archived").on('click', function(){
        $("input.top_links.destroy_archived").click();
    });

    $(".header.action-btn-group a.send_archived").on('click', function(){
        $("input.top_links.send_archived").click();
    });

    $(".action-btn-group .single_recover").on('click', function(){
        $(this).parents(".invoice-card").find("input[type='checkbox']").prop("checked","checked")
        $("input.top_links.recover_archived").click();
    });

    $(".action-btn-group .single_recover_deleted").on('click', function(){
        $(this).parents(".invoice-card").find("input[type='checkbox']").prop("checked","checked")
        $("input.top_links.recover_deleted").click();
    });

    $(".side-menu li > a").each(function(){
            if($(this).hasClass('active'))
                $(this).parent().addClass('active');
        }
    );

    $(".side-menu").mCustomScrollbar();

    $("a.multi_currency").click(function(){
        $("a.no_multi_currency").removeClass('active');
        $(this).addClass('active');
        $("input#multi_currency").attr('checked', 'checked').val('On');
    });

    $("a.no_multi_currency").click(function(){
        $("a.multi_currency").removeClass('active');
        $(this).addClass('active');
        $("input#multi_currency").attr('checked', false).val('Off');
    });

    $("a.side_nav_opened").click(function(){
        $("a.no_side_nav_opened").removeClass('active');
        $(this).addClass('active');
        $("input#side_nav_opened").attr('checked', 'checked').val('Open');
    });

    $("a.no_side_nav_opened").click(function(){
        $("a.side_nav_opened").removeClass('active');
        $(this).addClass('active');
        $("input#side_nav_opened").attr('checked', false).val('Close');
    });

    $('#invoices-list #radioBtn a').on('click', function(){
        var ind = $(this).index();
        if($(this).hasClass('active')){
            return
        }
        else{
            $("#invoices-list #radioBtn a").removeClass("active");
            $(this).addClass('active');
            $(".data-wrapper > ul").hide();
            $(".data-wrapper > ul").eq(ind).show();
        }
    });

    $(".modal-close").on('click', function(){
        $(this).parents(".modal").modal('close');
    });

    $('.activebar .card-white-panel').on('click',function(e){
        target = $(e.target)
        if ((!target.is( "a" ) && !target.is("i")) && !$(this).hasClass('noCollapse')){
            $(this).parents('.task-detail').find('.content-detail').slideUp();
            $(this).parent().slideUp();
            $(this).parent().next().slideDown();
        }
    });

    $('.mainbar .card-white-panel').on('click',function(){
        var $ele = $(this);
        $ele.parent().toggleClass('active');
        if($('.content-detail').is(":visible")){
            $ele.find('.btn-slide i.material-icons').text('keyboard_arrow_up');
        }
        else{
            $ele.find('.btn-slide i.material-icons').text('keyboard_arrow_down');
        }
        $(this).parents('.task-detail').find('.content-detail').slideToggle();
    });

    $("#add_member").on('click',function (){
        $('.edit-detail').click();
    })
    //project detail at task page
    $('.edit-detail').on('click',function(){
        $('.content-detail, .staff-list').find("input").removeAttr('disabled');
        $('.content-detail, .staff-list').find(".initialized").removeAttr('disabled');
        $('.content-detail, .staff-list').find(".not-editable").attr('disabled', true);
        $('select').material_select();
        $(".submitProject").removeClass('hidden');
        $(this).addClass('hidden')
        $("strong.project_name, span.project_description").attr('contenteditable', true);
        $('.activebar .card-white-panel').addClass('noCollapse');
    });

    $('.rkmd-slider input[type="range"] + span.thumb').remove();
    if($('.slider-handle').hasClass('is-active')){
        $('.slider-handle.is-active').parent().find('.slider-fill').addClass('a');
    }

    mobileSideMenu();
});

function mobileSideMenu(){
    var width = $(window).width();
    if (width <= 767) {
        $("#side-nav").removeClass("side-show");
    }
}

$(window).resize(function(){
    $(".side-menu").mCustomScrollbar();
    $(".activity-scroll-holder").mCustomScrollbar();
    $(".invoice-box").mCustomScrollbar();

    //mCustomScrollbar
    var width = $(window).width();
    if (width <= 767) {
        $(".side-menu").mCustomScrollbar("disable",true);
        $(".activity-scroll-holder").mCustomScrollbar("disable",true);
        $(".invoice-box").mCustomScrollbar("disable",true);
    }
    mobileSideMenu();
});


$(function () {
    $('[data-toggle="tooltip"]').tooltip();
    $(document)
        .ajaxStart(function() {
            $("#loading-indicator").removeClass('hidden'); // show on any Ajax event.
        })
        .ajaxStop(function() {
            $("#page-box").mCustomScrollbar();
            $("#loading-indicator").addClass('hidden'); // hide it when it is done.
        });
});

$('.list-buttons .addbtn').on('click',function(){
    $(this).parents('.user-list').find('.addContent').slideToggle();
});
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
  $(".btn-menu").click(function(){
      $("#activity-sidebar").removeClass("show-activity");
      $("#side-nav,#main-content,#activity-sidebar, #flash_message").toggleClass("side-show");
      if($('#side-nav').hasClass('side-show')) {
        removeSideNavTitle();
      }
      else {
        addSideNavTitle();
      }

      $('#graph_container').html('');
      Dashboard.plot_graph();
    });
  $(".btn-activity").click(function(){
      $("#side-nav,#main-content,#activity-sidebar, #flash_message").removeClass("side-show");
      $("#activity-sidebar").toggleClass("show-activity");
    });

  $('#btn-help').click(function(){
        $(this).next().find('.total-income').toggleClass('show-panel');
    });

  $('.menudd').click(function(){
        $(this).parent().toggleClass('activedd');
     });

  initBulkActionCheckboxes()

  $(".side-menu li > a").each(function(){
          if($(this).hasClass('active'))
              $(this).parent().addClass('active');
      }
  );

  $("a.multi_currency").click(function(){
      $("a.no_multi_currency").removeClass('active bold-white-txt');
      $(this).addClass('active bold-white-txt');
      $("input#multi_currency").attr('checked', 'checked').val('On');
  });

  $("a.no_multi_currency" +
  "").click(function(){
      $("a.multi_currency").removeClass('active bold-white-txt');
      $(this).addClass('active bold-white-txt');
      $("input#multi_currency").attr('checked', false).val('Off');
  });

  $("a.side_nav_opened").click(function(){
      $("a.no_side_nav_opened").removeClass('active bold-white-txt');
      $(this).addClass('active bold-white-txt');
      $("input#side_nav_opened").attr('checked', 'checked').val('Open');
  });

  $("a.no_side_nav_opened").click(function(){
      $("a.side_nav_opened").removeClass('active bold-white-txt');
      $(this).addClass('active bold-white-txt');
      $("input#side_nav_opened").attr('checked', false).val('Close');
  });

  $("a.index_page_format").click(function(){
      $("a.no_index_page_format").removeClass('active bold-white-txt');
      $(this).addClass('active bold-white-txt');
      $("input#index_page_format").attr('checked', 'checked').val('card');
  });

  $("a.no_index_page_format").click(function(){
      $("a.index_page_format").removeClass('active bold-white-txt');
      $(this).addClass('active bold-white-txt');
      $("input#index_page_format").attr('checked', false).val('table');
  });

  $('#invoices-list #radioBtn a').on('click', function(){
      var ind = $(this).index();
      if($(this).hasClass('active')){
          return
      }
      else{
          $("#invoices-list #radioBtn a").removeClass("active");
          $(this).addClass('active');
          $("#invoices-list .data-wrapper > ul").hide();
          $("#invoices-list .data-wrapper > ul").eq(ind).show();
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
      // $('select').material_select();
      $(".submitProject").removeClass('hidden');
      $(this).addClass('hidden')
      $("strong.project_name, span.project_description").attr('contenteditable', true);
      $('.activebar .card-white-panel').addClass('noCollapse');
  });

  $('.rkmd-slider input[type="range"] + span.thumb').remove();
  if($('.slider-handle').hasClass('is-active')){
      $('.slider-handle.is-active').parent().find('.slider-fill').addClass('a');
  }

  $(".breadcrum-bar select").on('change', function(e) {
      var inputVal = $('.breadcrum-bar .select-wrapper input.select-dropdown').val();
      $('.breadcrum-bar .select-wrapper > span.inputValue').remove();
      $(this).parent().prepend("<span class='inputValue'>"+inputVal+"</span>");
      var newInputValue = $('.inputValue').width();

      $('.breadcrum-bar .select-wrapper input.select-dropdown').css("width" , newInputValue + 80 );
      console.log(newInputValue );
  });

  mobileSideMenu();

  $(".filter-status").on('change', function(){
        $(this).parents("form").submit();
    })
});

function mobileSideMenu(){
    var width = $(window).width();
    if (width <= 767) {
        $("#side-nav").removeClass("side-show");
    }
}

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

function initBulkActionCheckboxes() {
  $(".btn-search").click(function(){
    $(".header-right").addClass("search-show");
    $('.checkboxinfo').hide();
    $('.search-holder form').show();
  });
  $(".btn-back").click(function(){
    $('.card-white-panel .action-btn-group').show();
    $('.table-view-body .action-btn-group').removeClass('disabled_link');
    $('.checkbox-item').find('.invoice-name').css('opacity', '1');
    $('.checkbox-item').find('label').css('opacity', '0');
    $(".header-right").removeClass("chekbox-show");
    $('#header').removeClass("chkbox-content");

    $('.checkboxinfo .action-btn-group .edit').show();
    $('.checkboxinfo .action-btn-group .send').show();
    $('.checkbox-item').find('input[type="checkbox"]').prop('checked', false);

    $(".header-right").removeClass("search-show");
    $('.checkboxinfo').show();
    $('.search-holder form').hide();
    if($('.select2-search-choice-close').size() == 1){
      $('a.select2-search-choice-close').click();
    }
  });
  // $('select').material_select();
  $('.modal').modal();
  //---Checkbox Items
  $('.checkbox-item > input[type="checkbox"]').on('change', function () {
    if(!$('.checkbox-item').hasClass('inline_team_member')){
      var n = $( ".checkbox-item > input:not(#select_all_items)[type='checkbox']:checked" ).length;
      if ($(this).is(':checked')){
        $('#header').addClass("chkbox-content");
        $(".header-right").addClass("chekbox-show");
        $('.checkbox-item').find('.invoice-name').css('opacity', '0');
        $('.checkbox-item').find('label').css('opacity', '1');
        $('.search-holder form').hide();
        $('.card-white-panel .action-btn-group').hide();
        $('.table-view-body .action-btn-group').addClass('disabled_link');
        $('.checkboxinfo').show();
        $('.checkboxinfo .action-btn-group .send').show();
      }
      else{
        $('#header').addClass("chkbox-content");
        $('.header.action-btn-group').hide();
        $('.checkboxinfo .action-btn-group').show();

        if(n == 0){
          $('.card-white-panel .action-btn-group').show();
          $('.table-view-body .action-btn-group').removeClass('disabled_link');
          $('.checkbox-item').find('.invoice-name').css('opacity', '1');
          $('.checkbox-item').find('label').css('opacity', '0');
          $(".header-right").removeClass("chekbox-show");
          $('#header').removeClass("chkbox-content");

          $('.checkboxinfo .action-btn-group .edit').show();
          $('.checkboxinfo .action-btn-group .send').show();
          $('#select_all_items').removeProp('checked');
        }
        if(n == 1){
          $('.checkboxinfo .action-btn-group .edit').show();
          $('.checkboxinfo .action-btn-group .send').show();
        }
      }

      $( ".chk-text" ).text(n + ' ' + I18n.t('views.common.selected'));
    }

  });
  // Select All Items Checkbox Click
  $('.checkbox-item > input#select_all_items[type="checkbox"]').on('change', function () {
    if($('#select_all_items').is(":checked")) {
      $('.checkbox-item > input[type="checkbox"]').prop('checked', 'checked');
      var n = $( ".checkbox-item > input:not(#select_all_items)[type='checkbox']:checked" ).length;

      $('#header').addClass("chkbox-content");
      $(".header-right").addClass("chekbox-show");
      $('.checkbox-item').find('.invoice-name').css('opacity', '0');
      $('.checkbox-item').find('label').css('opacity', '1');
      $('.search-holder form').hide();
      $('.card-white-panel .action-btn-group').hide();
      $('.table-view-body .action-btn-group').addClass('disabled_link');
      $('.checkboxinfo').show();
      $('.checkboxinfo .action-btn-group .send').show();
      $( ".chk-text" ).text(n + ' ' + I18n.t('views.common.selected'));
    } else {
      $('.checkbox-item > input[type="checkbox"]').removeProp('checked');
      $('#header').addClass("chkbox-content");
      $('.header.action-btn-group').hide();
      $('.checkboxinfo .action-btn-group').show();
      $('.card-white-panel .action-btn-group').show();
      $('.table-view-body .action-btn-group').removeClass('disabled_link');
      $('.checkbox-item').find('.invoice-name').css('opacity', '1');
      $('.checkbox-item').find('label').css('opacity', '0');
      $(".header-right").removeClass("chekbox-show");
      $('#header').removeClass("chkbox-content");
      $('.checkboxinfo .action-btn-group .edit').show();
      $('.checkboxinfo .action-btn-group .send').show();
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
    if($(this).parents(".invoice-card").length > 0) {
      $(this).parents(".invoice-card").find("input[type='checkbox']").prop("checked","checked")
      $("input.top_links.archive").click();
    }else {
      $(this).parents("tr").find("input[type='checkbox']").prop("checked","checked")
      $("input.top_links.archive").click();
    }
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
    if($(this).parents(".invoice-card").length > 0) {
      $(this).parents(".invoice-card").find("input[type='checkbox']").prop("checked","checked")
      $("input.top_links.recover_archived").click();
    }else {
      $(this).parents("tr").find("input[type='checkbox']").prop("checked","checked")
      $("input.top_links.recover_archived").click();
    }
  });
  $(".action-btn-group .single_recover_deleted").on('click', function(){
    if($(this).parents(".invoice-card").length > 0) {
      $(this).parents(".invoice-card").find("input[type='checkbox']").prop("checked","checked")
      $("input.top_links.recover_deleted").click();
    }else {
      $(this).parents("tr").find("input[type='checkbox']").prop("checked","checked")
      $("input.top_links.recover_deleted").click();
    }
  });

    $('.dashboard-whitebox #radioBtn a').on('click', function(){
        var ind = $(this).index();
        if($(this).hasClass('active')){
            return
        }
        else{
            $(".dashboard-whitebox #radioBtn a").removeClass("active");
            $(this).addClass('active');
            $(".dashboard-whitebox .data-wrapper > ul").hide();
            $(".dashboard-whitebox .data-wrapper > ul").eq(ind).show();
        }
    });

}
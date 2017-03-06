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
      $("#side-nav,#main-content,#activity-sidebar").toggleClass("side-show");


    });
    //
    $(".btn-activity").click(function(){
      $("#side-nav,#main-content,#activity-sidebar").removeClass("side-show");
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
    });
    
    $(".checkbox-item").on("click", function(e){
        e.stopImmediatePropagation();
    });

    $('#radioBtn a').on('click', function(){
        //Data Toggle
        var ind = $(this).index();

        if($(this).hasClass('active')){
            return
        }
        else{
            $("#radioBtn a").removeClass("active");
            $(this).addClass('active');

            $(".data-wrapper > ul").hide();
            $(".data-wrapper > ul").eq(ind).show();
        }
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

});




$(function () {
    $('[data-toggle="tooltip"]').tooltip();
});


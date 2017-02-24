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
    
    $('select').change(function () {
        //console.log($(this).val());
        //if ($(this).val() == 3) {
        //     console.log($(this).val());
        //    $('#CreatNewmodal').modal('open');
        //}
    });
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
            if (n > 1){
                $('.checkboxinfo .action-btn-group .edit').hide();
                $('.checkboxinfo .action-btn-group .send').hide();
            }
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
        //e.preventDefault();
        e.stopImmediatePropagation();
        //alert("sdf");
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
});




$(function () {
    $('[data-toggle="tooltip"]').tooltip();
});

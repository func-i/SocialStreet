//ALL Change of pages bindings
$(function(){
    $('.logo').click(function(){
        changePage('explore');
    });

    //    $('.result-event-link').live('click',function(){
    //        changePage('show_event', [$(this).parent().parent()]);
    //    });

    //    $('.result-event-link').live('click',function() {
    //
    //    });

    $('#add_streetmeet_btn').click(function(){
        changePage('create_event_what');
    });

    $('#explore_btn').click(function(){
        changePage('explore');
    });


    $('#create_what_next_arrow').click(function(){
        changePage('create_event_where');
    });

    $('#create_where_next_arrow').click(function(){
        changePage('create_event_when');
    });
});

function changePage(page_name, option_arr){
    cleanupBeforeLeaving();

    $('#current_page_name').val(page_name);

    hide_all_overlays();

    if(page_name == "explore"){
        setup_explore_page();

        $('#results_list_overlay').removeClass('hidden');
    }
    else if(page_name == "show_event"){
        setup_show_event(option_arr[0]);

        $('#event_overlay').removeClass('hidden');
    }
    else if(page_name == "create_event_what"){
        setup_create_event();

        $('#create_overlay').removeClass('hidden');
        $('#create_what').removeClass('hidden');
    }
    else if(page_name == "create_event_where"){
        setup_create_where();

        $('#create_overlay').removeClass('hidden');
        $('#create_where').removeClass('hidden');
    }
    else if(page_name == "create_event_when"){
        setup_create_when();

        $('#create_overlay').removeClass('hidden');
        $('#create_when').removeClass('hidden');
    }
}

function cleanupBeforeLeaving() {
    var page_name = $('#current_page_name').val();
    if(page_name == "explore"){
        hideExploreMarkers();

        $('#explore_btn').removeClass('hidden');
        $('#notify_me_btn').addClass('hidden');
    }
    else if(page_name == "show_event"){
        showMarker.setMap(null);
    }
    else if(page_name == "create_event_where"){
        $.each(createEventMarkerArr, function(index, marker){
            marker.setMap(null);
            delete marker;
        });
        delete createEventMarkerArr
    }
}

function hide_all_overlays(){
    //$.each($('.overlay-group'), function(index, value){
    //   $(value).addClass('hidden');
    //});
    $('#current_overlay').html('');
}

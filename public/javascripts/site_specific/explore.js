$('#remove_filters').live('click', function(){
    alert('Removing all Filters');
    $('#keyword').val("");
    $('#keyword').submit();
    event.preventDefault();
});

$('#keyword_filter_list li').live('click', function(li){
    selKeyword = $.trim($(this).text());
    alert('Filtering Results as ' + selKeyword + ' events only');
    $('#keyword').val(selKeyword);
    $('#keyword').submit();
    event.preventDefault(); // Prevent link from following its href
});

$('#explore_filter').live("pageshow",function() {
    var keyword = "";
    $('#filter_no_results').hide();

    $('.ui-input-text').live('keyup', function(){
        keyword = $(this).val();
        $('#filter_no_results a span').text(keyword);
        if($('.result:visible').length == 1) {
            if($('.result:visible a').text() == keyword || $('.result:visible a').text().toLowerCase() == keyword){
                $('#filter_no_results').hide();
            }

        }
        else if ($(this).val().length == 0){
            $('#filter_no_results').hide();
        }
        else
        {
            $('#filter_no_results').show();
        }
    });
});

function changeMapLocation(e, latLng) {
    if(latLng == null) {
        var loc = e.target.value;
        geocoder.geocode({
            address: loc
        }, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                exploreMap.setCenter(results[0].geometry.location);
                changeExploreLocationParams();

            }
            else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {
                alert('No Locations Found!');
            }
        });
    }
    else if(latLng != null) {
        exploreMap.setCenter(latLng);
        changeExploreLocationParams();
    }
}

function changeExploreLocationParams(event) {
    setTimeout(function() {
        var zoom = 15;
        $('#explore_map_zoom').val(zoom);

        $('#explore_event_details').hide();

        bounds = exploreMap.getBounds();
        ne = bounds.getNorthEast();
        sw = bounds.getSouthWest();
        c = bounds.getCenter();

        $('#explore_map_bounds').val(ne.lat() + ',' + ne.lng() + ',' + sw.lat() + ',' + sw.lng());
        $('#explore_map_center').val(c.lat() + ',' + c.lng());
        $('#explore_view_params').val("map");
        updateUserLocation(c.lat(), c.lng(), false);
        console.log("submitting explore form...");
        $('#explore_form').submit();

    }, 20);
}


function selectedMarker() {
    searchable_id = this.searchableID_;
    $('#display_results').empty();
    $('#searchable_'+searchable_id).clone().removeAttr('id').appendTo('#display_results');
    if(this.clusteredMarkers_.length > 0) {
        clustered_markers = this.clusteredMarkers_;
        for (i=0; i < clustered_markers.length; i++){
            searchable_id = clustered_markers[i].searchableID_;
            console.log("adding to display results");
            $('#searchable_'+searchable_id).clone().removeAttr('id').appendTo('#display_results');
            console.log("appended results to display results");
        }
    }
    $('#display_results').listview('refresh');
    $('#explore_event_details').toggle();
}


$('#explore_change_map_address').live("keydown", function(e) {
    if (e.keyCode == 13) {
        e.stopPropagation();
        $(this).blur();
        $('#explore_event_details').hide();
        changeMapLocation(e);
        return false;
    }
    return true;
});
  
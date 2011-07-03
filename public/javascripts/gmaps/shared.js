function clearMarkers() {
    $.each(markers, function(index, marker) {
        marker.setMap(null);
    });
    markers = [];
}

$(function() {
    function moveMap(e) {
        var loc = e.target.value;
        geocoder.geocode( {
            'address': loc
        }, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                map.setCenter(results[0].geometry.location);
                changeLocationParams();
                $('#location-not-found').hide();
            } else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {
                $('#location-not-found').show();
            }
        });
    }

    function changeLocationParams(event) {
        setTimeout(function() {
            var zoom = map.getZoom();
            $('#map_zoom').val(zoom);

            bounds = map.getBounds();
            ne = bounds.getNorthEast();
            sw = bounds.getSouthWest();
            c = bounds.getCenter();

            $('#map_bounds').val(ne.lat() + ',' + ne.lng() + ',' + sw.lat() + ',' + sw.lng());
            $('#map_center').val(c.lat() + ',' + c.lng());

            if(history && history.replaceState)
                history.replaceState(null, null, getSearchParams());
            refreshResults();
        }, 15);
    }

    google.maps.event.addListener(map, 'zoom_changed', changeLocationParams);
    google.maps.event.addListener(map, 'dragend', changeLocationParams);
    google.maps.event.addListener(map, 'resize', changeLocationParams);
});

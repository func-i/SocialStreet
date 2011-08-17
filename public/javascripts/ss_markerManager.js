function MarkerManager(opt_options)
{
    this.init(opt_options);
}

MarkerManager.prototype.init = function(opt_options)
{
    var options = opt_options || {};

    if(options['map'] == undefined){
    //TODO throw error
    }
    if(options['gridSize'] == undefined){
        options['gridSize'] = 15;
    }
    if(options['mapView'] == undefined){
        options['mapView'] = false;
    }
    if(options['listView'] == undefined){
        options['listView'] = false;
    }

    if(options['createEvent'] == undefined){
        options['createEvent'] = false;
    }

    this.setValues_(options);

    //Create markers when map is ready
    that = this;
    google.maps.event.addListenerOnce(this.map_, 'idle', function() {
        that.placeAllMarkers();
    });

    this.projectionHelper_ = new ProjectionHelperOverlay_(this.map_);

    this.infoWindow_ = new InfoWindow(this);

    if(this.mapView_){
        $.each($('.result-list-item'), function(index, rLI){
            $(rLI).hide();
        });
    }

};

MarkerManager.prototype.setValues_ = function(options)
{
    this.map_ = options['map'];
    this.gridSize_ = options['gridSize'];
    this.mapView_ = options['mapView'];
    this.listView_ = options['listView'];
    this.createEvent_ = options['createEvent'];
    this.allMarkers_ = [];
    this.selectedMarker_ = null;
};

MarkerManager.prototype.createMarker = function(location, searchableID, geocodableAddress, preserveMarker){
    var icoImage = "/images/map_pin.png";
    var selected = false;

    //If in explore map view and searchableid was selected, change image and select
    if(this.mapView_ || this.listView_){
        if(searchableID == $('#selected_searchable').val()){
            icoImage = '/images/ico-pin-selected.png';
            selected = true;
        }
    }
    else if(this.createEvent_){
        if(this.selectedMarker_ && this.selectedMarker_.getPosition().equals(location)){
            icoImage = '/images/ico-pin-selected.png';
            selected = true;
        }
    }

    //Create marker
    var marker = new google.maps.Marker({
        position: location,
        icon: icoImage,
        title: geocodableAddress
    });
    marker.setMap(null);
    marker.searchableID_ = searchableID;
    marker.geocodableAddress_ = geocodableAddress;
    marker.clusteredMarker_ = [];
    marker.selected_ = selected;
    marker.preserveMarker_ = preserveMarker

    //Create label
    marker.label_ = new Label();
    marker.label_.set('zIndex', marker.getZIndex() - 100);//TODO - doesn't work'
    marker.label_.bindTo('position', marker, 'position');
    marker.label_.set('text', '');

    //If marker should be selected, select
    if(selected){
        this.userSelectMarker_(marker);
    }

    //If explore map view, add listener for click
    if(this.mapView_ || this.listView_ || this.createEvent_){
        //Add listener for the click event
        var that = this;
        google.maps.event.addListener(marker, 'click', function()
        {
            marker.setIcon("/images/ico-pin-selected.png");
            that.userSelectMarker_(this);
            that.setSelectedMarker_(this);
        });
    }

    //Push marker onto marker array
    this.allMarkers_.push(marker);

    if(preserveMarker){
        marker.selected_ = true;
        this.placeAllMarkers();//Hack
    }
};

MarkerManager.prototype.clearMarkers = function(){
    var newMarkerArr = [];
    $.each(this.allMarkers_, function(index, marker){
        if(marker.preserveMarker_){
            newMarkerArr.push(marker);
        }else{
            marker.setMap(null);
            marker.label_.setMap(null);
        }
    });
    delete this.allMarkers_;
    this.allMarkers_ = newMarkerArr;

    $('.address').html('');
};

MarkerManager.prototype.placeAllMarkers = function(){
    var select_marker = null;

    //Copy allmarkers and empty
    var markerArr_ = this.allMarkers_.slice(0);
    this.allMarkers_ = [];

    //Loop through all the markers and replace
    for(var i =0; marker = markerArr_[i]; i++){
        //Reset all the custom marker fields
        this.resetMarker_(marker);

        //Check if the marker should be added to an already existing marker
        //If so, add to marker
        //Else, add to map
        if(!marker.preserveMarker_ && null != (ownerMarker = this.clusterWith_(marker))){
            //Add to existing marker
            if(!ownerMarker.clusteredMarkers_){
                ownerMarker.clusteredMarkers_ = [];
            }
            ownerMarker.clusteredMarkers_.push(marker);

            //If marker is selected, select the ownerMarker
            if(marker.selected_){
                select_marker = ownerMarker;
            }

            //Set existing marker label to reflect clustering
            ownerMarker.label_.set('text', ownerMarker.clusteredMarkers_.length + 1);
        }
        else{
            //If marker is selected, select
            if(marker.selected_){
                select_marker = marker
            }

            //Display marker and label
            marker.setMap(this.map_);
            marker.label_.set('map', this.map_);

            //Set grid bounds for future clustering
            var bounds = new google.maps.LatLngBounds(marker.getPosition(), marker.getPosition());
            marker.extendedBounds_ = this.getExtendedBounds_(bounds);
        }

        //Push marker back onto marker array
        this.allMarkers_.push(marker);
    }

    if(select_marker){
        //Set the selected marker/containing marker to selected state
        this.setSelectedMarker_(select_marker);
    }
    else if(this.mapView_)
    {
        //Set address to blank since nothing is selected
        $('.address').html('');
    }

    delete markerArr_;
    markerArr_ = null;
}

MarkerManager.prototype.resetMarker_ = function(marker){
    delete marker.clusteredMarkers_;
    marker.clusteredMarkers_= [];
    marker.extendedBounds_ = null;
    marker.setMap(null);
    marker.label_.set('text', '');
    marker.label_.set('map', null);
    marker.setIcon("/images/map_pin.png");
};

MarkerManager.prototype.userSelectMarker_ = function(marker){
    //Set marker to selected
    marker.selected_ = true;

    if(this.mapView_){
        //Set address of result list
        if(marker.geocodableAddress_ != null){
            $('.address').html('Near ' + marker.geocodableAddress_);
        }else{
            $('.address').html('');
        }

        //set searchable id field for maintaining on refresh
        $('#selected_searchable').val(marker.searchableID_);
    }
    else if(this.listView_){
        //set searchable id field for maintaining on refresh
        $('#selected_searchable').val(marker.searchableID_);
    }
    else if(this.createEvent_){
        
}
};

MarkerManager.prototype.setSelectedMarker_ = function(marker){
    //New selected marker - set old marker to regular icon
    if(this.selectedMarker_ != null && this.selectedMarker_ != marker)
    {
        this.selectedMarker_.setIcon("/images/map_pin.png");
        this.selectedMarker_.selected_ = false;
        if(this.selectedMarker_.clusteredMarkers_){
            $.each(this.selectedMarker_.clusteredMarkers_, function(index, marker){
                marker.selected_ = false;
            });
        }
    }

    //Set selected marker
    this.selectedMarker_ = marker;

    //Change icon
    this.selectedMarker_.setIcon("/images/ico-pin-selected.png");

    if(this.mapView_){
        //Hide each element in the map result list
        $.each($('.result-list-item'), function(index, rLI) {
            $(rLI).hide();
        });

        //Show each searchable attached to the selected marker
        $('#result_for_searchable_' + this.selectedMarker_.searchableID_).show();
        if(this.selectedMarker_.clusteredMarkers_){
            $.each(this.selectedMarker_.clusteredMarkers_, function(index, marker){
                $('#result_for_searchable_' + marker.searchableID_).show();
            });
        }
    }
    else if(this.listView_){
        //Unhighlight every element
        $.each($('.result-list-item'), function(index, rLI) {
            $(rLI).css('backgroundColor', 'transparent');
        });

        //Show each searchable attached to the selected marker
        $('#result_for_searchable_' + this.selectedMarker_.searchableID_).css('backgroundColor', '#FE6');;
        if(this.selectedMarker_.clusteredMarkers_){
            $.each(this.selectedMarker_.clusteredMarkers_, function(index, marker){
                $('#result_for_searchable_' + marker.searchableID_).css('backgroundColor', '#FE6');;
            });
        }
    }
    else if(this.createEvent_){
        this.infoWindow_.addInfoWindow_(this.selectedMarker_);

        var latlng = this.selectedMarker_.getPosition();
        $('#location-lat-field').val(latlng.lat());
        $('#location-lng-field').val(latlng.lng());
    }
};

MarkerManager.prototype.clusterWith_ = function(markerToPlace){
    //loop through every marker and choose closest marker to location
    var distance = 40000;//large number
    var markerToAddTo = null;
    var markerToPlacePosition = markerToPlace.getPosition();

    for(var i =0; placedMarker = this.allMarkers_[i]; i++){
        if(placedMarker.getMap()){
            var position = placedMarker.getPosition();
            if(position){
                var d = this.distanceBetweenPoints_(position, markerToPlacePosition);
                if(d < distance){
                    distance = d;
                    markerToAddTo = placedMarker;
                }
            }
        }
    }

    if(markerToAddTo && this.isWithinMarkerBound_(markerToAddTo, markerToPlacePosition)){
        return markerToAddTo;
    }
    else{
        return null;
    }
};

MarkerManager.prototype.distanceBetweenPoints_ = function(clusterPosition, markerToPlacePosition){
    if(!clusterPosition || !markerToPlacePosition){
        return 0
    }

    var R = 6371; //Radius of Earth in km
    var dLat = (markerToPlacePosition.lat() - clusterPosition.lat()) * Math.PI / 180;
    var dLon = (markerToPlacePosition.lng() - clusterPosition.lng()) * Math.PI / 180;
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    (Math.cos(clusterPosition.lat() * Math.PI / 180) * Math.cos(markerToPlacePosition.lat() * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2));
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c;
    return d;
};

MarkerManager.prototype.isWithinMarkerBound_ = function(markerToAddTo, markerToPlacePosition){
    return markerToAddTo.extendedBounds_.contains(markerToPlacePosition);
};

/*From MarkerClusterer*/
MarkerManager.prototype.getExtendedBounds_ = function(bounds){
    var projection = this.projectionHelper_.getProjection();

    // Turn the bounds into latlng.
    var tr = new google.maps.LatLng(bounds.getNorthEast().lat(),
        bounds.getNorthEast().lng());
    var bl = new google.maps.LatLng(bounds.getSouthWest().lat(),
        bounds.getSouthWest().lng());

    // Convert the points to pixels and the extend out by the grid size.
    var trPix = projection.fromLatLngToDivPixel(tr);
    trPix.x += this.gridSize_;
    trPix.y -= this.gridSize_;

    var blPix = projection.fromLatLngToDivPixel(bl);
    blPix.x -= this.gridSize_;
    blPix.y += this.gridSize_;

    // Convert the pixel points back to LatLng
    var ne = projection.fromDivPixelToLatLng(trPix);
    var sw = projection.fromDivPixelToLatLng(blPix);

    // Extend the bounds to contain the new bounds.
    bounds.extend(ne);
    bounds.extend(sw);

    return bounds;
}

/**@private
 * In V3 it is quite hard to gain access to Projection and Panes.
 * This is a helper class
 * @param {google.maps.Map} map
 */
function ProjectionHelperOverlay_(map) {
    google.maps.OverlayView.call(this);
    this.setMap(map);
}

ProjectionHelperOverlay_.prototype = new google.maps.OverlayView();
ProjectionHelperOverlay_.prototype.draw = function () {
    if (!this.ready) {
        this.ready = true;
        google.maps.event.trigger(this, 'ready');
    }
};

function InfoWindow(markerManager){
    this.markerManager_ = markerManager;

    this.infoBubble_ = new InfoBubble();
    this.infoBubble_.hideCloseButton();

    var that = this;
    
    $('#marker-name-field').live('click', function() {
        $(this).focus();
    });

    $('#marker-name-field').live('keyup', function(e) {
        if (e.keyCode == 13) {      
            
            if(this.value.length > 0)
            {
                $(this).siblings('a').html(this.value);
            }
            else{
                $(this).siblings('a').html("Add place name");
            }

            that.infoBubble_.setMinWidth($(this).siblings('a').html().length*6.5);//TODO - Horrible hack

            //that.infoBubble_.setMinHeight('auto');

            that.infoBubble_.setPadding(5);
            that.infoBubble_.setBorderWidth(5);

            $(this).siblings('a').show();
            $(this).hide();

            e.stopPropagation();
            return false;
        }
        else {
            $('#location-name-field').val(this.value);
            getCreateMarkerManager().selectedMarker_.setTitle(this.value);
            return true;
        }
        return false;
    });
};

InfoWindow.prototype.addInfoWindow_ = function(marker){
    //Set Infobox
    var linkTitle = (marker.title != "" && $('#location-name-field').val() == marker.title) ?  marker.title : 'Add place name';
    var linkText = "<div style='text-align:center;'><input id=\"marker-name-field\" type=\"text\" value=\"" + marker.title + "\" style='display:none; width: 200px; border:0; margin:0;'/>" +
    "<a href=\"#\" onclick=\"getCreateMarkerManager().infoWindow_.labelClicked(this); return false;\" id=\"infobubble-link\">" + linkTitle +
    "</a></div>";

    this.infoBubble_.setContent(linkText);

    this.infoBubble_.setMaxHeight(20);
    this.infoBubble_.setMinHeight(10);
    this.infoBubble_.setMinWidth(linkTitle.length*6.5);
    this.infoBubble_.setBorderWidth(5);
    this.infoBubble_.setPadding(5);
    this.infoBubble_.open(this.markerManager_.map_, marker);
};

InfoWindow.prototype.labelClicked = function(lnk){
    $(lnk).siblings('input').show().focus();

    this.infoBubble_.setMinHeight(20);
    this.infoBubble_.setMinWidth(200);

    this.infoBubble_.setPadding(0);
    this.infoBubble_.setBorderWidth(5);
    $(lnk).hide();
};

// Define the overlay, derived from google.maps.OverlayView
function Label(opt_options) {
    // Initialization
    this.setValues(opt_options);

    // Here go the label styles
    var span = this.span_ = document.createElement('span');
    span.style.cssText = 'position: relative; left: -50%; top: -10px; ' +
    'white-space: nowrap;color:#FF0000;' +
    'padding: 2px;font-family: Arial; font-weight: bold;' +
    'font-size: 8px;';

    var div = this.div_ = document.createElement('div');
    div.appendChild(span);
    div.style.cssText = 'position: absolute; display: none';
};

Label.prototype = new google.maps.OverlayView;

Label.prototype.onAdd = function() {
    var pane = this.getPanes().overlayImage;
    pane.appendChild(this.div_);

    // Ensures the label is redrawn if the text or position is changed.
    var me = this;
    this.listeners_ = [
    google.maps.event.addListener(this, 'position_changed',
        function() {
            me.draw();
        }),
    google.maps.event.addListener(this, 'text_changed',
        function() {
            me.draw();
        }),
    google.maps.event.addListener(this, 'zindex_changed',
        function() {
            me.draw();
        })
    ];
};

// Implement onRemove
Label.prototype.onRemove = function() {
    this.div_.parentNode.removeChild(this.div_);

    // Label is removed from the map, stop updating its position/text.
    for (var i = 0, I = this.listeners_.length; i < I; ++i) {
        google.maps.event.removeListener(this.listeners_[i]);
    }
};

// Implement draw
Label.prototype.draw = function() {
    var projection = this.getProjection();
    var position = projection.fromLatLngToDivPixel(this.get('position'));
    var div = this.div_;
    div.style.left = position.x + 'px';
    div.style.top = (position.y - 25) + 'px';
    div.style.display = 'block';
    div.style.zIndex = 1//this.get('zIndex'); //ALLOW LABEL TO OVERLAY MARKER
    this.span_.innerHTML = this.get('text').toString();
};


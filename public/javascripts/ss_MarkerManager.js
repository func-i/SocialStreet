function MarkerManager(opt_options)
{
    this.init(opt_options);
}

MarkerManager.prototype.init = function(opt_options)
{
    var options = opt_options || {};

    if(options['map'] == undefined){
        throw "Map is undefined in MarkerManager"
    //TODO throw error
    }
    if(options['gridSize'] == undefined){
        options['gridSize'] = 20;
    }

    this._setValues(options);

    this.projectionHelper_ = new ProjectionHelperOverlay(this.map_);
};

MarkerManager.prototype._setValues = function(options)
{
    this.map_ = options['map'];
    this.gridSize_ = options['gridSize'];
    this.allMarkers_ = [];
};

MarkerManager.prototype.addMarker = function(lat, lng){
    var marker = new google.maps.Marker({
        icon: '/images/green-pin.png',
//        shadow: new google.maps.MarkerImage('/images/pin-shadow.png', null, null, new google.maps.Point(0,26)),
        position: new google.maps.LatLng(lat, lng)
    });
    
    this.allMarkers_.push(marker);

    return marker;
};

MarkerManager.prototype.showAllMarkers = function(){
    if(undefined == this.map_.mapTypes[this.map_.mapTypeId]){
        that = this;
        google.maps.event.addListenerOnce(this.map_, 'idle', function() {
            that.showAllMarkers();
        });
        return;
    }

    var markerArr = this.allMarkers_.slice(0);
    this.allMarkers_ = [];

    for(var i = 0; i < markerArr.length; i++){
        var marker = markerArr[i];

        if(null != (ownerMarker = this._clusterWith(marker))){
            //Cluster with ownerMarker
            ownerMarker.clusteredMarkers_.push(marker);
            marker.ownerMarker_ = ownerMarker;
            marker.setMap(null);
        }
        else{
            marker.setMap(this.map_);
            marker.clusteredMarkers_ = [];
            marker.clusteredMarkers_.push(marker);
            marker.ownerMarker_ = marker;

            var bounds = new google.maps.LatLngBounds(marker.getPosition(), marker.getPosition());
            marker.extendedBounds_ = this._getExtendedBounds(bounds);
        }

        this.allMarkers_.push(marker);
    }

    delete markerArr;
    markerArr = null;
};

MarkerManager.prototype.deleteAllMarkers = function(){
    $.each(this.allMarkers_, function(index, marker){
        marker.setMap(null);
        delete marker.clusteredMarkers_;
    });
    delete this.allMarkers_;
    this.allMarkers_ = [];
};
MarkerManager.prototype.hideAllMarkers = function(){
    $.each(this.allMarkers_, function(index, marker){
        marker.setMap(null);        
    });
};

MarkerManager.prototype._clusterWith = function(markerToPlace){
    //loop through every marker and choose closest marker to location
    var distance = 40000;//large number
    var markerToAddTo = null;
    var markerToPlacePosition = markerToPlace.getPosition();

    for(var i=0; placedMarker = this.allMarkers_[i]; i++){
        if(placedMarker.getMap()){
            var position = placedMarker.getPosition();
            if(position){
                var d = this._distanceBetweenPoints(position, markerToPlacePosition);
                if(d < distance){
                    distance = d;
                    markerToAddTo = placedMarker;
                }
            }
        }
    }

    if(markerToAddTo && this._isWithinMarkerBound(markerToAddTo, markerToPlacePosition)){
        return markerToAddTo;
    }
    else{
        return null;
    }
};

MarkerManager.prototype._distanceBetweenPoints = function(marker1, marker2){
    if(!marker1 || !marker2){
        return 0
    }

    var R = 6371; //Radius of Earth in km
    var dLat = (marker2.lat() - marker1.lat()) * Math.PI / 180;
    var dLon = (marker2.lng() - marker1.lng()) * Math.PI / 180;
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    (Math.cos(marker1.lat() * Math.PI / 180) * Math.cos(marker2.lat() * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2));
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c;
    return d;
};

MarkerManager.prototype._isWithinMarkerBound = function(markerWithBounds, markerToTest){
    return markerWithBounds.extendedBounds_.contains(markerToTest);
};

MarkerManager.prototype._getExtendedBounds = function(bounds){
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
};

/**@private
 * In V3 it is quite hard to gain access to Projection and Panes.
 * This is a helper class
 * @param {google.maps.Map} map
 */
function ProjectionHelperOverlay(map) {
    google.maps.OverlayView.call(this);
    this.setMap(map);
}

ProjectionHelperOverlay.prototype = new google.maps.OverlayView();
ProjectionHelperOverlay.prototype.draw = function () {
    if (!this.ready) {
        this.ready = true;
        google.maps.event.trigger(this, 'ready');
    }
};

// Define the overlay, derived from google.maps.OverlayView
function IconLabel() {
    // Here go the label styles
    this.div_ = document.createElement('div');
    this.div_.style.cssText = 'position: absolute;';

    this.image_ = document.createElement('img');
    this.image_.src = '/images/event_types/streetmeet5.png';
    this.image_.style.cssText = "width:50px;height:50px";
    this.div_.appendChild(this.image_);
};

IconLabel.prototype = new google.maps.OverlayView;

IconLabel.prototype.onAdd = function() {
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

IconLabel.prototype.onRemove = function() {
    this.div_.parentNode.removeChild(this.div_);

    // Label is removed from the map, stop updating its position/text.
    for (var i = 0, I = this.listeners_.length; i < I; ++i) {
        google.maps.event.removeListener(this.listeners_[i]);
    }
};

// Implement draw
IconLabel.prototype.draw = function() {
    var projection = this.getProjection();

    var position = projection.fromLatLngToDivPixel(this.get('position'));
    var div = this.div_;
    div.style.display = 'block';

    div.style.left = (position.x - 25) + 'px';//25 for half the width of the icon
    div.style.top = (position.y - 78) + 'px';//50 for height of icon, 34 for height of base, -6 to get it to sit on base
};

IconLabel.prototype.setIcon = function(iconSrc){
    this.image_.src = iconSrc;
};

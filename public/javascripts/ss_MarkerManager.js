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
        options['gridSize'] = 15;
    }


    this._setValues(options);
};

MarkerManager.prototype._setValues = function(options)
{
    this.map_ = options['map'];
    this.gridSize_ = options['gridSize'];
    this.allMarkers_ = [];
};

MarkerManager.prototype.addMarker = function(lat, lng){
    var marker = new google.maps.Marker({
        position: new google.maps.LatLng(lat, lng)
    });
    
    this.allMarkers_.push(marker);

    return marker;
}

MarkerManager.prototype.showAllMarkers = function(){
    for(var i = 0; i < this.allMarkers_.length; i++){
        this.allMarkers_[i].setMap(this.map_);
    }
    return true;
}

MarkerManager.prototype.deleteAllMarkers = function(){
    $.each(this.allMarkers_, function(index, marker){
        marker.setMap(null);
    });
    delete this.allMarkers_;
    this.allMarkers_ = [];
}

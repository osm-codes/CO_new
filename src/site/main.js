var osmUrl	= 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
var osmAttrib	= '&copy; <a href="https://osm.org/copyright">OpenStreetMap contributors</a>';
var mapboxUrl	= 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw';
var mapboxAttr	= 'Tiles from <a href="https://www.mapbox.com">Mapbox</a>.';
var osmAndMapboxAttr	= osmAttrib + ' Tiles from <a href="https://www.mapbox.com">Mapbox</a>.';

var openstreetmap	= L.tileLayer(osmUrl,   {attribution: osmAttrib,detectRetina: true,minZoom: 0,maxZoom: 25 }),
    grayscale		= L.tileLayer(mapboxUrl,{id:'mapbox/light-v10',attribution: osmAndMapboxAttr,detectRetina: true,maxZoom: 25 }),
    streets 		= L.tileLayer(mapboxUrl,{id:'mapbox/streets-v11',attribution: osmAndMapboxAttr,detectRetina: true,maxZoom: 25 }),
    satellite		= L.tileLayer(mapboxUrl,{id:'mapbox/satellite-v9',attribution: mapboxAttr,detectRetina: true,maxZoom: 25 }),
    satellitestreet	= L.tileLayer(mapboxUrl,{id:'mapbox/satellite-streets-v11',attribution: mapboxAttr,detectRetina: true,maxZoom: 25 })
    ;

var baseLayers = {
    'Grayscale': grayscale,
    'OpenStreetMap': openstreetmap,
    'Streets': streets,
    'Satellite': satellite,
    'Satellite and street': satellitestreet
};

var code = new L.LayerGroup();
var all_codes = new L.LayerGroup();

var overlays = {
    'Current': code,
    'All': all_codes
};

var mapOptions = {
    center: [3.5,-72.3],
    zoom: 6,
    current_zoom: 6
};

var map = L.map('map',{
    center: mapOptions.center,
    zoom:   mapOptions.zoom,
    zoomControl: false,
    renderer: L.svg(),
    layers: [grayscale, code]
});
map.attributionControl.setPrefix(false);
map.on('zoom', function(e){mapOptions.current_zoom = map.getZoom();});
map.on('click', onMapClick);

var LeafIcon = L.Icon.extend({
    options: {
        iconSize:[24, 24],
        iconAnchor:[12, 24],
        popupAnchor:[0, -26]
    }
});

var userIcon = new LeafIcon({iconUrl: 'images/user-marker.svg'});

var zoom   = L.control.zoom({position:'topleft'});
var layers = L.control.layers(baseLayers, overlays,{position:'topright'});
var escala = L.control.scale({position:'bottomright',imperial: false});

var searchJurisdiction = L.control({position: 'topleft'});
searchJurisdiction.onAdd = function (map) {
    this.container = L.DomUtil.create('div');
    this.label     = L.DomUtil.create('label', '', this.container);
    this.search    = L.DomUtil.create('input', '', this.container);
    this.button    = L.DomUtil.create('button','leaflet-control-button',this.container);
    
    this.search.type = 'text';
    this.search.placeholder = 'e.g.: CO-ANT-Medellin';
    this.search.id = 'textsearchjurisdiction';
    this.button.type = 'button';
    this.button.innerHTML= "Jurisdiction";
    
    L.DomEvent.disableScrollPropagation(this.button);
    L.DomEvent.disableClickPropagation(this.button);
    L.DomEvent.disableScrollPropagation(this.search);
    L.DomEvent.disableClickPropagation(this.search);
    L.DomEvent.on(this.button, 'click', search_decode2, this.container);
    L.DomEvent.on(this.search, 'keyup', function(data){if(data.keyCode === 13){search_decode2(data);}}, this.container);
        
    return this.container;
};

var searchDecode = L.control({position: 'topleft'});
searchDecode.onAdd = function (map) {
    this.container = L.DomUtil.create('div');
    this.search    = L.DomUtil.create('input', '', this.container);
    this.button    = L.DomUtil.create('button','leaflet-control-button',this.container);
    
    this.search.type = 'text';
    this.search.placeholder = 'geocode, e.g.: 3D5';
    this.search.id = 'textsearchbar';
    this.button.type = 'button';
    this.button.innerHTML= "Decode";
    
    L.DomEvent.disableScrollPropagation(this.button);
    L.DomEvent.disableClickPropagation(this.button);
    L.DomEvent.disableScrollPropagation(this.search);
    L.DomEvent.disableClickPropagation(this.search);
    L.DomEvent.on(this.button, 'click', search_decode, this.container);
    L.DomEvent.on(this.search, 'keyup', function(data){if(data.keyCode === 13){search_decode(data);}}, this.container);
    
    return this.container;
};

var precision = L.control({position: 'topleft'});
precision.onAdd = function (map) {
    this.container = L.DomUtil.create('div');
    this.search    = L.DomUtil.create('input', '', this.container);
    this.button    = L.DomUtil.create('button','leaflet-control-button',this.container);
    this.label     = L.DomUtil.create('label', '', this.container);
    this.select    = L.DomUtil.create('select', '', this.container);
    this.label2    = L.DomUtil.create('label', '', this.container);
    this.checkbox  = L.DomUtil.create('input', '', this.container);

    this.label2.for= 'grid';
    this.label2.innerHTML= ' view child cells: ';
    this.checkbox.id = 'grid';
    this.checkbox.type = 'checkbox';
    this.checkbox.value = 1;
    this.search.type = 'text';
    this.search.placeholder = 'lat,lng, e.g.: 3.5,-72.3';
    this.search.id = 'latlngtextbar';
    this.button.type = 'button';
    this.button.innerHTML= "Encode";
    this.select.id = 'digits_size';
    this.select.name = 'dig';
    this.select.innerHTML = '<option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option>';
    this.label.for= 'dig';
    this.label.innerHTML= '<br>Precision: ';

    L.DomEvent.disableScrollPropagation(this.container);
    L.DomEvent.disableClickPropagation(this.container);
    L.DomEvent.on(this.button, 'click', search_encode, this.container);
    L.DomEvent.on(this.search, 'keyup', function(data){if(data.keyCode === 13){search_encode(data);}}, this.container);

    return this.container;
};

var clear = L.control({position: 'topleft'});
clear.onAdd = function (map) {
    this.container = L.DomUtil.create('div');
    this.button    = L.DomUtil.create('button','leaflet-control-button',this.container);

    this.button.type = 'button';
    this.button.innerHTML= "Clear all";
    
    L.DomEvent.disableScrollPropagation(this.button);
    L.DomEvent.disableClickPropagation(this.button);
    L.DomEvent.on(this.button, 'click', function(e){code.clearLayers(); all_codes.clearLayers();map.setView(mapOptions.center, mapOptions.zoom);}, this.container);
        
    return this.container;
};

function search_decode(data)
{
    let input = document.getElementById('textsearchbar').value

    if(input !== null && input !== '')
    {
        code.clearLayers();
        load_geojson("https://osm.codes/co/d/" + input.toUpperCase(),style,onEachFeature);
        document.getElementById('textsearchbar').value = '';
    }
}

function search_decode2(data)
{
    let input = document.getElementById('textsearchjurisdiction').value

    if(input !== null && input !== '')
    {
        code.clearLayers();
        load_geojson("https://osm.codes/co/i/" + input,style2,onEachFeature2);
        document.getElementById('textsearchjurisdiction').value = '';
    }
}

function search_encode(data)
{
    let input = document.getElementById('latlngtextbar').value

    if(input !== null && input !== '')
    {
        let dig = document.getElementById('digits_size').value
        let grid = document.getElementById('grid')
        var uri = "https://osm.codes/co/" + (grid.checked ? 'x' : 'e') +"/" + dig + "/geo:" + input

        var popupContent = "latlng: " + input;
        console.log(popupContent);
        code.clearLayers();
        L.marker(input.split(','),{icon: userIcon}).addTo(code).bindPopup(popupContent);
        load_geojson(uri,style,onEachFeature)
        document.getElementById('latlngtextbar').value = '';
    }
}

layers.addTo(map);
escala.addTo(map);
zoom.addTo(map);
searchJurisdiction.addTo(map);
searchDecode.addTo(map);
precision.addTo(map);
clear.addTo(map);

function onEachFeature(feature,layer)
{
    sufix_area =(feature.properties.area<10000)? 'm2': 'km2';
    value_area =(feature.properties.area<10000)? feature.properties.area: Math.round((feature.properties.area*100/10000))/100;
    sufix_side =(feature.properties.side<1000)? 'm': 'km';
    value_side =(feature.properties.side<1000)? Math.round(feature.properties.side*100.0)/100 : Math.round(feature.properties.side*100.0/1000)/100;

    var popupContent = "";
    popupContent += "Code: " + feature.properties.code + "<br>";
    popupContent += "Area: " + value_area + " " + sufix_area + "<br>";
    popupContent += "Side: " + value_side + " " + sufix_side + "<br>";

    if(feature.properties.short_code )
    {
        popupContent += "Short code: " + feature.properties.short_code + "<br>";
    }

    if(feature.properties.prefix )
    {
        popupContent += "Prefix: " + feature.properties.prefix + "<br>";
    }

    if(feature.properties.code_subcell )
    {
        popupContent += "Code_subcell: " + feature.properties.code_subcell + "<br>";
    }

    layer.bindPopup(popupContent);

    if(feature.properties.code_subcell)
    {
        layer.bindTooltip(feature.properties.code_subcell,{permanent:true,direction:'center'});
    }
    else if(feature.properties.short_code)
    {
        layer.bindTooltip(feature.properties.short_code,{permanent:true,direction:'center'});
    }
    else
    {
        layer.bindTooltip(feature.properties.code,{permanent:true,direction:'center'});
    }
}

function onEachFeature2(feature,layer)
{
    var popupContent = "";
    popupContent += "osm_id: " + feature.properties.osm_id + "<br>";
    popupContent += "jurisd_base_id: " + feature.properties.jurisd_base_id + "<br>";
    popupContent += "jurisd_local_id: " + feature.properties.jurisd_local_id + "<br>";
    popupContent += "parent_id: " + feature.properties.parent_id + "<br>";
    popupContent += "admin_level: " + feature.properties.admin_level + "<br>";
    popupContent += "name: " + feature.properties.name + "<br>";
    popupContent += "parent_abbrev: " + feature.properties.parent_abbrev + "<br>";
    popupContent += "abbrev: " + feature.properties.abbrev + "<br>";
    popupContent += "wikidata_id: " + feature.properties.wikidata_id + "<br>";
    popupContent += "lexlabel: " + feature.properties.lexlabel + "<br>";
    popupContent += "isolabel_ext: " + feature.properties.isolabel_ext + "<br>";
    popupContent += "lex_urn: " + feature.properties.lex_urn + "<br>";
    popupContent += "name_en: " + feature.properties.name_en + "<br>";
    popupContent += "isolevel: " + feature.properties.isolevel + "<br>";
    popupContent += "area: " + feature.properties.area + "<br>";
    popupContent += "jurisd_base_id: " + feature.properties.jurisd_base_id + "<br>";

    layer.bindPopup(popupContent);
}

function style(feature)
{
    return {color: 'black', fillColor: 'black', fillOpacity: 0.1};               
}

function style2(feature)
{
    return {color: 'black', fillColor: 'none', fillOpacity: 0.1};               
}

function load_geojson(uri,style,onEachFeature) {
    fetch( uri )
    .then(response => {return response.json()})
    .then(data =>
    {
        var geojson = L.geoJSON(data.features,{
            style: style,
            onEachFeature: onEachFeature,
        }).addTo(code);

	map.fitBounds(geojson.getBounds());

        L.geoJSON(data.features,{
            style: style,
            onEachFeature: onEachFeature
        }).addTo(all_codes);
    })
    .catch(err => {})
}

function onMapClick(e) {
    let dig = document.getElementById('digits_size').value
    let grid = document.getElementById('grid')
    var uri = "https://osm.codes/co/" + (grid.checked ? 'x' : 'e') +"/" + dig + "/geo:" + e.latlng['lat'] + "," + e.latlng['lng']

    var popupContent = "latlng: " + e.latlng['lat'] + "," + e.latlng['lng'];
    code.clearLayers();
    L.marker(e.latlng,{icon: userIcon}).addTo(code).bindPopup(popupContent);

    load_geojson(uri,style,onEachFeature)
}


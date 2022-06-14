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

var overlays = {
    'Current': code
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

var zoom   = L.control.zoom({position:'topleft'});
var layers = L.control.layers(baseLayers, overlays,{position:'topright'});
var escala = L.control.scale({position:'bottomright',imperial: false});

var uri = window.location.href;
var uri2 = uri.replace(/\/([dexi])([dexi])\//, "/$1/");

load_geojson(uri2,style,onEachFeature);

layers.addTo(map);
escala.addTo(map);
zoom.addTo(map);

let text = window.location.pathname;

function onEachFeature(feature,layer)
{
    if (text.match(/\/jj\//))
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
    else
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
}

function style(feature)
{
    return {color: 'black', fillColor: 'black', fillOpacity: 0.1};               
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

    })
    .catch(err => {})
}

var hospitalMap;

var selectedDonors = [];

function renderSelectedDonors() {
  $('#donor-list').html(null);
  selectedDonors.forEach(function(donor) {
    $('#donor-list').append('<li>' + donor.name + '</li>')
  });
}

$(function() {
  var Map = ol.Map;
  var OSM = ol.source.OSM;
  var Tile = ol.layer.Tile;
  var View = ol.View;
  var fromLonLat = ol.proj.fromLonLat;
  var Point = ol.geom.Point;

  function makeView() {
    return new View({
      center: fromLonLat([-122.457402676806, 37.76307]),
      zoom: 9
    });
  }

  function makeOSMTile() {
    return new Tile({ source: new OSM() })
  }

  function makeMap(target) {
    return new Map({
      target: target,
      layers: [makeOSMTile()],
      view: makeView()
    });
  }

  hospitalMap = makeMap('hospital-map');

  function hospitalStyleFn(feature, resolution) {
    var fontSize = (100 / resolution) + 10;
    if (fontSize > 15) fontSize = 15;
    var display = resolution < 150;
    var opacity = display ? 1 : 0;
    var cirlceRadius = (resolution / 100) + 6;
    return [
      new ol.style.Style({
        declutter: true,
        image: new ol.style.Circle({
          radius: cirlceRadius,
          fill: new ol.style.Fill({
            color: 'rgba(200, 0, 0, 0.5)'
          }),
          stroke: new ol.style.Stroke({
            color: 'rgba(255, 0, 0, 1)',
            width: 1
          })
        }),
      })
    ];
  }

  var hospitalFeatures = hospitalData.map(function(hospital) {
    return new ol.Feature({
      title: hospital.organization,
      geometry: new ol.geom.Point(fromLonLat([hospital.longitude, hospital.latitude])),
    });
  });

  var hospitalVectorSource = new ol.source.Vector({
    features: hospitalFeatures
  });

  var hospitalVectorLayer = new ol.layer.Vector({
    source: hospitalVectorSource,
    name: 'Hospitals',
    style: hospitalStyleFn
  });

  hospitalMap.addLayer(hospitalVectorLayer);


  function donorStyleFn(feature, resolution) {
    var fontSize = (100 / resolution) + 10;
    if (fontSize > 15) fontSize = 15;
    var display = resolution < 150;
    var opacity = display ? 1 : 0;
    var cirlceRadius = (200 / resolution) + 2;
    return [
      new ol.style.Style({
        declutter: true,
        image: new ol.style.Circle({
          radius: cirlceRadius,
          fill: new ol.style.Fill({
            color: 'rgba(0, 200, 200, 0.5)'
          }),
          stroke: new ol.style.Stroke({
            color: 'rgba(0, 200, 200, 1)',
            width: 1
          })
        }),
      })
    ]
  }

  var donorFeatures = donorData.map(function(donor) {
    return new ol.Feature({
      title: donor.name,
      geometry: new ol.geom.Point(fromLonLat([donor.longitude, donor.latitude])),
    });
  });

  var donorVectorSource = new ol.source.Vector({
    features: donorFeatures
  });

  donorVectorLayer = new ol.layer.Vector({
    source: donorVectorSource,
    name: 'Donors',
    style: donorStyleFn
  });

  hospitalMap.addLayer(donorVectorLayer);

  hospitalMap.on("click", function(e) {
    hospitalMap.forEachFeatureAtPixel(e.pixel, function (feature, layer) {
      var style = feature.getStyle() || new ol.style.Style()
      var donor = _.find(donorData, function(el) { return el.name == feature.get('title') });
      if (feature.get('selected')) {
        feature.set('selected', false);
        console.log(donor.name);
        if (donor) {
          selectedDonors = _.without(selectedDonors, donor)
        }
      } else {
        feature.set('selected', true);
        if (donor && !_.contains(selectedDonors, donor)) {
          selectedDonors.push(donor)
        }
      }
      renderSelectedDonors();
    })
  });
});

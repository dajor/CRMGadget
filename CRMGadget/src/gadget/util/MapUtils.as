package gadget.util
{
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapType;
	import com.google.maps.controls.NavigationControl;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.services.ClientGeocoder;
	import com.google.maps.services.Directions;
	import com.google.maps.services.GeocodingEvent;
	import com.google.maps.services.GeocodingResponse;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import gadget.dao.Database;
	
	import mx.controls.HTML;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class MapUtils
	{
		
		public static const SHIPPING_ADDRESS:String = "Shipping";
		public static const BILLING_ADDRESS:String = "Billing";
		private static var map:Map;
		private static var gmap:UIComponent;
		
		private static var apiKey:Object; //key {url,key}
		private static var info:Object; //info {title,addr,icon}
		
		private static var showNavigator:Boolean;
		
		/*
		*	MapUtils.getMapControl({url:strURL, key:strAPIKey},{title:strTitle, addr:strAddr, icon:Class});
		*/
		public static function getMapControl(apiKey:Object, info:Object, showNavigator:Boolean = false):UIComponent {
			MapUtils.showNavigator = showNavigator;
			MapUtils.apiKey = apiKey
			MapUtils.info = info;
			MapUtils.gmap = new UIComponent();
			MapUtils.gmap.addEventListener(FlexEvent.INITIALIZE, MapUtils.onGMapCreated);
			MapUtils.gmap.addEventListener(ResizeEvent.RESIZE, MapUtils.onGMapResized);
			MapUtils.gmap.percentHeight = 100;
			MapUtils.gmap.percentWidth = 100;
			return MapUtils.gmap;
		}
		
		private static function onGMapCreated(event:Event):void {
			MapUtils.map = new Map();
			MapUtils.map.key = apiKey.key;
			MapUtils.map.url = apiKey.url;
			MapUtils.map.addEventListener(MapEvent.MAP_READY, MapUtils.onMapReady);
			MapUtils.gmap.addChild(map);
		}
		
		private static function onGMapResized(event:Event):void {
			MapUtils.map.setSize(new Point(gmap.width, gmap.height));
		}
		
		private static function onMapReady(event:Event):void {
			if(MapUtils.showNavigator) MapUtils.map.addControl(new NavigationControl());
			MapUtils.map.enableScrollWheelZoom();
			MapUtils.map.enableContinuousZoom();
			MapUtils.doGeocode(event as GeocodingEvent);
			trace("dragging is " + MapUtils.map.draggingEnabled());
		}	
		
		private static function doGeocode(event:GeocodingEvent):void {
			var geocoder:ClientGeocoder = new ClientGeocoder();
			geocoder.addEventListener(GeocodingEvent.GEOCODING_SUCCESS,
				function(event:GeocodingEvent):void {
					var placemarks:Array = event.response.placemarks;
					if (placemarks.length > 0) {
						map.setCenter(placemarks[0].point, 15, MapType.NORMAL_MAP_TYPE);
						var icon:Class = MapUtils.info.icon;
						var markerOptions:MarkerOptions = new MarkerOptions();
						markerOptions.icon = new icon();
						markerOptions.tooltip = MapUtils.info.title;
						markerOptions.iconAlignment = MarkerOptions.ALIGN_HORIZONTAL_CENTER;
						markerOptions.iconOffset = new Point(2, 2);
						
						var marker:Marker = new Marker(map.getCenter(), markerOptions);
						map.addOverlay(marker);
						
						marker.addEventListener(MapMouseEvent.CLICK, function(event:MapEvent):void {
							marker.openInfoWindow(new InfoWindowOptions({
								title: MapUtils.info.title,
								content: placemarks[0].address
							}));
						});
						map.addEventListener(MapMouseEvent.CLICK,  function(event:Event):void {
							map.closeInfoWindow();
						});	
						
					}
				});
			geocoder.addEventListener(GeocodingEvent.GEOCODING_FAILURE,
				function(event:GeocodingEvent):void {
					trace("Geocoding failed");
				});
			
			if(MapUtils.info.addr != "")
				geocoder.geocode(MapUtils.info.addr);
		}	
		
		public static function getGoogleMapControl(apiKey:Object, info:Object):DisplayObject {
			var htmlComponent:HTML = new HTML();
			htmlComponent.height = 300;
			var file:File = Utils.writeStringFile( 'googlemap_' + DateUtils.getCurrentDateAsSerial() + '.html', getGoogleMapHTML( info.addr,apiKey.key ) );
			if(file!=null) htmlComponent.location = file.url;
			htmlComponent.validateNow();
			return htmlComponent;
		}
		
		private static function getGoogleMapHTML(addr:String,key:String):String {
			var strHTML:String = 
				'<html>' + 
					'<head>' +
						'<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />' +
						'<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>' +
						'<style type="text/css">' +
						'	html { height: 100% }' +
						'	body { height: 100%; margin: 0px; padding: 0px }' +
						'	#map_canvas { height: 100% }' +
						'</style>' +
						'<title>Google Maps JavaScript API v3 Example: Map Simple</title>' +
						'<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false&key="'+key+'></script>' +
						'<script type="text/javascript">' +
							'function initialize() {' +
								//'var myLatlng = new google.maps.LatLng(48.8903420, 2.3285920);' +
								'var myOptions = {' +
								'	zoom: 13,' +
								//'	center: myLatlng,' +
								'	mapTypeId: google.maps.MapTypeId.ROADMAP' +
								'};' +
								'var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);' +
								'var geocoder = new google.maps.Geocoder();' +
								'if (geocoder) {' +
								'	geocoder.geocode( { "address": "' + addr.replace("'","\'") + '"}, function(results, status) {' +
								'		if (status == google.maps.GeocoderStatus.OK) {' +
								'			var infoContent = "";' +
								'			for(var i=0; i<results[0].address_components.length; i++){' +
								'				var e = results[0].address_components[i];' +
								'				infoContent += e.long_name;' +
								'				if( i != (results[0].address_components.length - 1) ) infoContent += ", ";' + 
								'			}' +
								'			var infowindow = new google.maps.InfoWindow({' +
								'				content: infoContent' +
								'			});' +
								'			map.setCenter(results[0].geometry.location);' +
								'			var marker = new google.maps.Marker({' +
								'				map: map,' +
								'				position: results[0].geometry.location' +
								'			});' +
								'			google.maps.event.addListener(marker, "click", function() {' +
								'				infowindow.open(map,marker);' +
								'			});' + 
								'		} else {' +
								'			document.getElementById("map_canvas").style.display = "none";' +
								'			document.getElementById("map_canvas_invalid").style.display = "block";' +
								'		}' +
								'	});' +
								'}' +
							'}' +
						'</script>' +
					'</head>' +
					'<body onload="initialize()">' +
						'<div id="map_canvas"></div>' +
						'<div id="map_canvas_invalid" style="display:none"> Invalid address </div>' +
					'</body>' +
				'</html>';
			return strHTML;
		}
		
		/**
		 *​​​
		 * Generate Travel Map in HTML Flex's Component
		 * 
		 * @param apiKey Map API Key
		 * 
		 * @param info Object  
		 * 		@attributes 
		 * 			title : String,
		 * 			icon  : Class,
		 * 			addr  : Object  @attributes Start and End are location String, Waypoints is Object {location:""}
		 * 
		 * @return ​DisplayObject
		 * 
		 */
		public static function getGoogleMapTravelControl(apiKey:Object, info:Object):DisplayObject {
			var htmlComponent:HTML = new HTML();
			htmlComponent.height = 300;
			var addresses:Array = new Array();
			var file:File = Utils.writeStringFile( 'googlemaptravel_' + DateUtils.getCurrentDateAsSerial() + '.html', info.travel ? getGoogleMapTravelHTML( info.addr,info.locations ) : getGoogleMapMultiMarkerHTML(info.locations,info.mapColor));
			if(file!=null) htmlComponent.location = file.url;
			htmlComponent.validateNow();
			return htmlComponent;
		}
		private static function getGoogleMapMultiMarkerHTML(locations:String,mapColor:String=""):String {
			var strHTML:String = 
				'<html>' + 
				'<head>' +
				'<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />' +
				'<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>' +
				'<style type="text/css">' +
				'	html { height: 100% }' +
				'	body { height: 100%; margin: 0px; padding: 0px }' +
				'	#map_canvas { height: 100% }' +
				'</style>' +
				'<title>Google Maps JavaScript API v3 Example: Map Simple</title>' +
				'<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>' +
				'<script type="text/javascript">' +
				'function makeCallback(strIcon,map) {'+
				
				'	var geocodeCallBack =function(results, status) {' +
				'			var icon = strIcon;'+
				'			if (status == google.maps.GeocoderStatus.OK) {' +
				'				var infoContent = "";' +
				'				for(var i=0; i<results[0].address_components.length; i++){' +
				'					var e = results[0].address_components[i];' +
				'					infoContent += e.long_name;' +
				'					if( i != (results[0].address_components.length - 1) ) infoContent += ", ";' + 
				'				}' +
				'				var infowindow = new google.maps.InfoWindow({' +
				'					content: infoContent' +
				'				});' +
				'				map.setCenter(results[0].geometry.location);' +
				'				var marker = new google.maps.Marker({' +
				'					map: map,' +
				'					position: results[0].geometry.location,' +
				'					icon: icon'+
				'				});' +
				'				google.maps.event.addListener(marker, "click", function() {' +
				'					infowindow.open(map,marker);' +
				'				});' + 
				'			} else {' +
				'				document.getElementById("map_canvas").style.display = "none";' +
				'				document.getElementById("map_canvas_invalid").style.display = "block";' +
				'			}' +
				'	} '+
				'\n '+
				'	return geocodeCallBack;'+
				'}'+
				
				'function initialize() {' +
				'   var labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R","S", "T", "U", "V", "W", "X", "Y", "Z"];'+
				'	var locations=['+ locations + '];' +
				'	var mapColor=['+ mapColor + '];' +
				'	var myOptions = {' +
				'		zoom: 2,' +
				'		mapTypeId: google.maps.MapTypeId.ROADMAP' +
				'	};' +
				'	var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);' +
				'	for(var k=0;k<locations.length;k++){'+
				'		var geocoder = new google.maps.Geocoder();' +
				'       var icon = "https://chart.googleapis.com/chart?chst=d_map_pin_letter&chld=" + (k+1) + "|"+mapColor[k]+"|000000";'+
				'		if (geocoder) {' +
				'			geocoder.geocode( { "address": locations[k] },makeCallback(icon,map));'+
				'		}' +
				'	}'+
				'}' +
				
				
				'</script>' +
				'</head>' +
				'<body onload="initialize()">' +
				'<div id="map_canvas"></div>' +
				'<div id="map_canvas_invalid" style="display:none"> Invalid address </div>' +
				'</body>' +
				'</html>';
			return strHTML;
		}
		
		public static function getDuration(original:String, destination:String,callBack:Function):void{
			var url:String = "http://maps.googleapis.com/maps/api/distancematrix/json?origins="+encodeURI(original)+"&destinations="+encodeURI(destination)+"&mode=driving&sensor=false&language=en";
			trace("url request driving mode:" + url);
			var service:HTTPService = new HTTPService();
			service.url = url;
			service.addEventListener(ResultEvent.RESULT, callBack);
			service.addEventListener(FaultEvent.FAULT,callBack);
			service.send();
			
		}
		/**
		 * Generate String HTML to Build Map
		 * 
		 * @param addr Object  
		 * 		@attributes 
		 * 			Start 		: String,
		 * 			End   		: String,
		 * 			Waypoints 	: Object @attributes location	: String
		 * @return String Write to Temporary File
		 * 
		 */
		private static function getGoogleMapTravelHTML(addr:Object,locations:String):String {
			var strHTML:String = 
				'<html>' + 
				'<head>' +
				'<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />' +
				'<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>' +
				'<style type="text/css">' +
				'	html { height: 100% }' +
				'	body { height: 100%; margin: 0px; padding: 0px }' +
				'	#map_canvas { height: 100% }' +
				'</style>' +
				'<title>Google Maps JavaScript API v3 Example: Map Simple</title>' +
				'<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>' +
				'<script type="text/javascript">' +
				'var directionsDisplay;' +
				//---------------------------------------------------
				//bug #4855
				'function makeCallback(strIcon,map) {'+
					
				'	var geocodeCallBack =function(results, status) {' +
				'			var icon = strIcon;'+
				'			if (status == google.maps.GeocoderStatus.OK) {' +
				'				var infoContent = "";' +
				'				for(var i=0; i<results[0].address_components.length; i++){' +
				'					var e = results[0].address_components[i];' +
				'					infoContent += e.long_name;' +
				'					if( i != (results[0].address_components.length - 1) ) infoContent += ", ";' + 
				'				}' +
				'				var infowindow = new google.maps.InfoWindow({' +
				'					content: infoContent' +
				'				});' +
				'				map.setCenter(results[0].geometry.location);' +
				'				var marker = new google.maps.Marker({' +
				'					map: map,' +
				'					position: results[0].geometry.location,' +
				'					icon: icon'+
				'				});' +
				'				google.maps.event.addListener(marker, "click", function() {' +
				'					infowindow.open(map,marker);' +
				'				});' + 
				'			} else {' +
				'				document.getElementById("map_canvas").style.display = "none";' +
				'				document.getElementById("map_canvas_invalid").style.display = "block";' +
				'			}' +
				'	} '+
				'\n '+
				'	return geocodeCallBack;'+
				'}'+
				
				'function initPoints() {' +
				'   var labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R","S", "T", "U", "V", "W", "X", "Y", "Z"];'+
				'	var locations=['+ locations + '];' +
				'	var myOptions = {' +
				'		zoom: 2,' +
				'		mapTypeId: google.maps.MapTypeId.ROADMAP' +
				'	};' +
				'	var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);' +
				'	for(var k=0;k<locations.length;k++){'+
				'		var geocoder = new google.maps.Geocoder();' +
				'       var icon = "https://chart.googleapis.com/chart?chst=d_map_pin_letter&chld= " + labels [k] + "|66BC4B|000000";'+
				'		if (geocoder) {' +
				'			geocoder.geocode( { "address": locations[k] },makeCallback(icon,map));'+
				'		}' +
				'	}'+
				'}' +
				
				//-----------------------------------------------------------------------
				'function initialize() {' +
				//'var myLatlng = new google.maps.LatLng(48.8903420, 2.3285920);' +
				'var myOptions = {' +
				'	zoom: 13,' +
				//'	center: myLatlng,' +
				'	mapTypeId: google.maps.MapTypeId.ROADMAP' +
				'};' +
				
				'directionsDisplay = new google.maps.DirectionsRenderer();' + 

				'var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);' +
				'directionsDisplay.setMap(map);' +
				
				'var directionsService = new google.maps.DirectionsService();' +
				'var request = {' +
					'origin:"' + addr.Start.replace("'","\'") + '",' + 
					'destination:"' + addr.End.replace("'","\'") + '",' +
					'durationInTraffic: true,'+
					'waypoints:' + addr.Waypoints.replace('"','\"\g') + ',' +
					'optimizeWaypoints: true,' +
					'travelMode: google.maps.DirectionsTravelMode.DRIVING' +
				'};' +
				
				'directionsService.route(request, function(response, status) {'+
				'	if (status == google.maps.DirectionsStatus.OK) {' +
				'		directionsDisplay.setDirections(response);' +
//				'		var route = response.routes[0];' +
//				'		var summaryPanel = document.getElementById("directions_panel");' +
//				'		summaryPanel.innerHTML = "";' +
//						// For each route, display summary information.
//				'		for (var i = 0; i < route.legs.length; i++) {' +
//				'			var routeSegment = i + 1;' +
//				'			summaryPanel.innerHTML += "<b>Route Segment: " + routeSegment + "</b><br />";' +
//				'			summaryPanel.innerHTML += route.legs[i].start_address + " to ";' +
//				'			summaryPanel.innerHTML += route.legs[i].end_address + "<br />";' +
//				'			summaryPanel.innerHTML += route.legs[i].distance.text + "<br /><br />";' +
//				'		}' +
				'	}else if(status == google.maps.DirectionsStatus.ZERO_RESULTS){' +
				'       initPoints();'+
				'}'+
				'});' +
				
				'}' +
				
				'</script>' +
				'</head>' +
				'<body onload="initialize()">' +
				//'<div id="directions" style="width: 275px"></div>' +
				'<div id="map_canvas"></div>' +
				'<div id="map_canvas_invalid" style="display:none"> Invalid address </div>' +
				'</body>' +
				'</html>';
			return strHTML;
		}

	}
}
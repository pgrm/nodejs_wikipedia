// Using OpenStreetMap in Wikipedia.
// (c) 2008 by Magnus Manske
// heavily altered by [[m:User:Danmichaelo]], [[m:User:Hoo man]]
// Released under GPL

mw.loader.using('mediawiki.util', function() {
	function openStreetMapToggle() {
		var a = $( '#coordinates a' ),
			link = '',
			url = '';
		if (a.length === 0) {
			return;
		}
	 
		if ($('#openstreetmap').length > 0) {
			$('#openstreetmap').toggle();
			return false;
		}
		
		$.each(a, function(index, value) {
			if ( value.href.indexOf('geohack') === -1 ) {
				return true; // Returning non-false is the same as a continue
			}
			link = value.href;
			return false; // break
		});
		if (link === '') {
			return false; // No geohack link found
		}
		
		url = '//toolserver.org/~kolossos/openlayers/kml-on-ol.php?lang=' + osm_proj_lang + '&uselang=' + mw.config.get('wgUserLanguage') + '&params=' + link.split('params=')[1] + '&title=' + mw.util.wikiUrlencode( mw.config.get( 'wgTitle' ) );
		if ( window.location.protocol === 'https:' ) {
			url += '&secure=1';
		}
		$('#contentSub').append(
			// src has to be passed using .attr as it could contain malicious html!
			$('<iframe id="openstreetmap" style="width:100%; height: 350px; clear:both;"></iframe>').attr('src', url)
		);
	 
		return false;
	}
	$(document).ready(function() {
		var a = $('#coordinates a'),
			geohack = false;
		if (a.length === 0) {
			return;
		}

		$.each(a, function(index, value) {
			if ( value.href.indexOf('geohack') === -1 ) {
				return true;
			}
			if (value.href.indexOf('_globe:') !== -1) {
				return true; // no OSM for moon, mars, etc
			}
			geohack = true;
			return false;
		});
		if (!geohack) {
			return;
		}

		$('#coordinates').append(
			' (',
			$('<a id="coordinates_map" href="#">' + osm_proj_map + '</a>').click(openStreetMapToggle),
			')   '
		);
	});
});
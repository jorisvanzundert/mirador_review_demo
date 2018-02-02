/**
 * EventEmitter v4.0.3 - git.io/ee
 * Oliver Caldwell
 * MIT license
 */(function(e){"use strict";function t(){}function i(e,t){if(r)return t.indexOf(e);var n=t.length;while(n--)if(t[n]===e)return n;return-1}var n=t.prototype,r=Array.prototype.indexOf?!0:!1;n.getListeners=function(e){var t=this._events||(this._events={});return t[e]||(t[e]=[])},n.addListener=function(e,t){var n=this.getListeners(e);return i(t,n)===-1&&n.push(t),this},n.on=n.addListener,n.removeListener=function(e,t){var n=this.getListeners(e),r=i(t,n);return r!==-1&&(n.splice(r,1),n.length===0&&(this._events[e]=null)),this},n.off=n.removeListener,n.addListeners=function(e,t){return this.manipulateListeners(!1,e,t)},n.removeListeners=function(e,t){return this.manipulateListeners(!0,e,t)},n.manipulateListeners=function(e,t,n){var r,i,s=e?this.removeListener:this.addListener,o=e?this.removeListeners:this.addListeners;if(typeof t=="object")for(r in t)t.hasOwnProperty(r)&&(i=t[r])&&(typeof i=="function"?s.call(this,r,i):o.call(this,r,i));else{r=n.length;while(r--)s.call(this,t,n[r])}return this},n.removeEvent=function(e){return e?this._events[e]=null:this._events=null,this},n.emitEvent=function(e,t){var n=this.getListeners(e),r=n.length,i;while(r--)i=t?n[r].apply(null,t):n[r](),i===!0&&this.removeListener(e,n[r]);return this},n.trigger=n.emitEvent,typeof define=="function"&&define.amd?define(function(){return t}):e.EventEmitter=t})(this);
/*

/**
 * TextViewer
 * Author: J.J. van Zundert
 * Date: 7 July 2017
 * License: MIT
 *
 * Dependecies:
 * JQuery
 */

// TODO: mirador_event_emitter should be 1) in a options hash, 2) optional
function TextViewer( element_id, mirador_event_emitter ) {

  // This protects all other code to whatever we are doing.
  // 'Private' methods should be properties of this variable.
  var _text_viewer = {};

  // This protects any elements outside out context to whatever we are doing.
  // All bindings from this object should be to an element descendant from _this.
  var _this = $( element_id );

  // This is a local event emitter to synchronise GUI stuff of the text viewer only.
  var _event_emitter = new EventEmitter();

  // Highlighting of clicked tab
  _event_emitter.addListener( 'tab_clicked', function( tab ) {
    var other_tabs = _this.find( '.text_viewer .tabs .tab' ).toArray().filter( function( any_tab ){
      return !( any_tab === tab );
    })
    $( other_tabs ).removeClass( 'active' );
    if( !$(tab).hasClass( 'active' ) ) { $(tab).addClass( 'active' ) };
  });

  // Loading of text when a tab is clicked
  _event_emitter.addListener( 'tab_clicked', function( tab ) {
    var text_type_selected = ( _text_viewer.text_types.filter( function( text_type ){
      return $(tab).hasClass( text_type );
    }))[0];
    _text_viewer.get_text( text_type_selected );
  });

  // Load text on image change
  _event_emitter.addListener( 'image_id_set', function() {
    var selected_tab = _this.find( '.text_viewer .tabs .tab.active' ).first();
    var text_type_selected = ( _text_viewer.text_types.filter( function( text_type ){
       return $(selected_tab).hasClass( text_type );
    }))[0];
    _text_viewer.get_text( text_type_selected );
  });

  _text_viewer.get_text = function( text_type ) {
    xhr_url = _text_viewer.xhr_url + text_type;
    if( text_type != 'xml_as_html' ) {
      var folio = _text_viewer.image_id.split( '/' ).pop().split( '_' )[1]
      xhr_url = xhr_url + '/folio/' + folio;
    };
    $.get( xhr_url, function( data, status ) {
      _this.find( '.content_pane' ).html( $(data) );
      _event_emitter.emitEvent( 'transcription_loaded' );
    });
  }

  _event_emitter.addListener( 'transcription_loaded', function() {
    // find all anno ids in transcription
    // then add an onclick to their elements that publish the click to mirador_event_emitter
    _this.find( '[data-facs]' ).click( function() {
      mirador_event_emitter.publish( 'request_fit_bounds', $( this ).attr( 'data-facs' ) );
    });
    mirador_event_emitter.publish( 'text_viewer_ready' );
  });

  _text_viewer.set_events = function() {
    _this.find( '.text_viewer .tabs .tab' ).click( function() {
      _event_emitter.emitEvent( 'tab_clicked', $(this) );
    });
  };

  // init
  $.get( 'http://localhost:9099/reynaert', function( data, status ) {
    _this.html( $(data) );

    // 'instance' variables
    _text_viewer.window_id = null;
    _text_viewer.text_types = [ 'diplomatic', 'critical', 'xml_as_html' ];
    _text_viewer.xhr_url = 'http://localhost:9099/reynaert/';
    _text_viewer.set_events();

    // listen for window id (it's broadcast when mirador_event_emitter receives a 'text_viewer_ready' event)
    mirador_event_emitter.subscribe( 'emit_window_id', function( event, window_id ) {
      if( _text_viewer.window_id == undefined ) {
        _text_viewer.window_id = window_id;
        // listen for image changes
        mirador_event_emitter.subscribe( 'SET_CURRENT_CANVAS_ID.' + _text_viewer.window_id, function( event, image_id ) {
          _text_viewer.image_id = image_id;
          _event_emitter.emitEvent( 'image_id_set' );
        });
      }
    });
    $.get( 'http://localhost:9099/reynaert/diplomatic/folio/192v', function( data, status ) {
      _text_viewer.image_id = "http://localhost:9999/reynaert_fragment/folios/folio_192v";
      _this.find( '.content_pane' ).html( $(data) );
      _event_emitter.emitEvent( 'transcription_loaded' );
    });
  });

  return _text_viewer;
}

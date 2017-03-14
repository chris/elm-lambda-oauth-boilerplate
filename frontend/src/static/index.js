// pull in desired CSS/SASS files
require( './styles/main.scss' );
var $ = jQuery = require( '../../node_modules/jquery/dist/jquery.js' );           // <--- remove if Bootstrap's JS not needed
require( '../../node_modules/bootstrap-sass/assets/javascripts/bootstrap.js' );   // <--- remove if Bootstrap's JS not needed

// Get JWT token from the URL if we have one, and then clear the browser history
function jwtFromUrl() {
  var jwtFlagRegExp = /jwt=([\w\.]+)/;
  var match = jwtFlagRegExp.exec(window.location.search);
  var jwt = null;
  if (match) {
    jwt = match[1];
    localStorage.setItem("jwt", jwt);
    history.replaceState({}, "Elm Lambda OAuth Boilerplate", "/");
  }
  return jwt;
}

function jwtFromLocalStorage() {
  return localStorage.getItem("jwt");
}

function getJwt() {
  return jwtFromUrl() || jwtFromLocalStorage() || "";
}

// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );
var app = Elm.Main.embed( document.getElementById( 'main' ), getJwt() );

app.ports.logout.subscribe(function() {
  localStorage.removeItem("jwt");
});

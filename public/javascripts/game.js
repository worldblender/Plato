var TICK_INTERVAL = 8000; // in milliseconds
var map;
var myLocation;
var playerIndex = -1;
var zIndexTop = 0;
var allPlayers = [<%- @players.each do |user| -%>
  [<%= user.latitude %>, <%= user.longitude %>, "<%= user.name %>", <%= user.facebook_id %>, "<%= user.deadtime %>", null, <%= user.hp %>, <%= user.curScore.round %>],
<%- end -%>];
var allBombs = [<%- @bombs.each do |bomb| %>
  <%- if !bomb.isExploded? -%>[<%= bomb.latitude %>, <%= bomb.longitude %>, <%= bomb.timeLeft * 1000 %>, null, null, "<%= User.find(bomb.owner_id).name %>",<%= bomb.srcLat %>, <%=  bomb.srcLng %>],<% end %>
<%- end %>];
var gCanvasElement;
var gDrawingContext;
var gOverlayProjection;
var kPixelWidth = 1196;
var kPixelHeight= 736;
var bombPathOverlay;

BombPathOverlay.prototype = new google.maps.OverlayView();

function BombPathOverlay(map) {
  this.setMap(map);
}

BombPathOverlay.prototype.draw = function() {
  if (gDrawingContext)
  {
    drawGame()
  }
}

BombPathOverlay.prototype.onAdd = function() {
  gOverlayProjection = this.getProjection();

  var sw = gOverlayProjection.fromLatLngToDivPixel(map.getBounds().getSouthWest());
  var ne = gOverlayProjection.fromLatLngToDivPixel(map.getBounds().getNorthEast());

  var div = document.createElement('DIV');
  div.style.left = sw.x + 'px';
  div.style.top = ne.y + 'px';
  div.style.width = (ne.x-sw.x) + 'px';
  div.style.height = (sw.y-ne.y) + 'px';
  div.style.border = "none";
  div.style.borderWidth = "0px";
  div.style.position = "absolute";
  div.innerHTML = "<div><canvas id='gameLayer' height='" + div.style.height + "' width='" + div.style.width + "' ></canvas></div>";

  var panes = this.getPanes();
  panes.overlayLayer.appendChild(div);
  gCanvasElement = document.getElementById('gameLayer');
  if (gCanvasElement != null && gCanvasElement.getContext)
  {
    gCanvasElement.width = gCanvasElement.width;
    gCanvasElement.height = gCanvasElement.height;
    gDrawingContext = gCanvasElement.getContext('2d');
  }
}

function createBomb() {
  var marker = new MarkerWithLabel({
    position: myLocation,
    map: map,
    title: "Your bomb",
    icon: "/images/dragBomb.png",
    draggable: true,
    zIndex: 100000,
    labelContent: "",
    labelAnchor: myLocation
  });

  <% if current_user.curScore and current_user.curScore < 100 %>
    var helpInfobox = new InfoBox({
      content: "Drag your bomb to where you want to drop it, and then double-click to light the fuse!",
      boxStyle: { width: "250px" },
      closeBoxURL: ""
    });
    setTimeout(function(){helpInfobox.close()}, 8000);
    helpInfobox.open(map, marker);
  <%- end -%>
  google.maps.event.addListener(marker, "dragend", function() {
    var distance = haversineDistance(myLocation.lat(), myLocation.lng(), this.getPosition().lat(), this.getPosition().lng());
    var displayedBombTime = Math.round(<%= clientCalcDuration %>);
    this.setOptions({labelContent: displayedBombTime});
  });
  google.maps.event.addListener(marker, "dblclick", function() {
    this.setMap(null);
    var bombLat1 = this.getPosition().lat();
    var bombLng1 = this.getPosition().lng();
    var distance = haversineDistance(myLocation.lat(), myLocation.lng(), bombLat1, bombLng1);
    var bombTime = 1000 * <%= clientCalcDuration %>;
    allBombs.push([bombLat1, bombLng1, bombTime, null, null, "<%= current_user.name %>",myLocation.lat(),myLocation.lng()]);
    var targetUrl = "/game/dropBomb?lat=" + this.getPosition().lat() + "&lng=" + this.getPosition().lng();
    pushData = new Image();
    pushData.src = targetUrl;
  });
}

function mapTypeExperiment() {
  var platoMapStyles = [
  {
    featureType: "road.arterial",
    elementType: "geometry",
    stylers: [
      { visibility: "simplified" },
      { hue: "#f6ff00" },
      { gamma: 0.38 }
    ]
  },{
    featureType: "water",
    elementType: "all",
    stylers: [
      { lightness: 36 }
    ]
  },{
    featureType: "road.highway",
    elementType: "all",
    stylers: [
      { visibility: "simplified" },
      { gamma: 0.76 }
    ]
  },{
    featureType: "all",
    elementType: "labels",
    stylers: [
      { visibility: "off" }
    ]
  },{
    featureType: "road.local",
    elementType: "all",
    stylers: [
      { visibility: "off" }
    ]
  },{
    featureType: "transit",
    elementType: "all",
    stylers: [
      { visibility: "off" }
    ]
  },{
    featureType: "administrative",
    elementType: "labels",
    stylers: [
      { visibility: "on" },
      { gamma: 0.39 },
      { lightness: -4 },
      { saturation: 100 }
    ]
  },{
    featureType: "landscape.man_made",
    elementType: "all",
    stylers: [
      { visibility: "off" }
    ]
  },{
    featureType: "all",
    elementType: "all",
    stylers: [
      { invert_lightness: true }
    ]
  },{
    featureType: "poi",
    elementType: "all",
    stylers: [
      { visibility: "off" }
    ]
  }];
  var platoMap = new google.maps.StyledMapType(platoMapStyles, {name: "Plato Style" });
  map.mapTypes.set('platoMap', platoMap);
  map.setMapTypeId('platoMap');
}


function gotPositionCallback(position) {
  myLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
  pushData = new Image();
  pushData.src = "/game/playerMoved?lat=" + position.coords.latitude + "&lng=" + position.coords.longitude;
  map.setCenter(myLocation);
  <% if !current_user.deadtime and !current_user.bomb_id %>
    createBomb();
  <% end %>
  if(playerIndex >= 0 && allPlayers[playerIndex] != null)
  {
    allPlayers[playerIndex][0] = position.coords.latitude;
    allPlayers[playerIndex][1] = position.coords.longitude;
  }

  navigator.geolocation.watchPosition(function(position) {
    //console.log("position: " + position.coords.latitude + ',' + position.coords.longitude + '; myLocation: ' + myLocation.lat() + ', ' + myLocation.lng());
    if (myLocation.lat() == position.coords.latitude && myLocation.lng() == position.coords.longitude)
      return;
    pushData = new Image();
    pushData.src = "/game/playerMoved?lat=" + position.coords.latitude + "&lng=" + position.coords.longitude;
    myLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
    allPlayers[playerIndex][5].setPosition(myLocation);
  });
}
function setMapLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(gotPositionCallback); // TODO(jeff): catch on error
  } else {
    alert("Your browser does not support geolocation. Please try a different browser.");
  }
}

function drawGame() {
  if(gDrawingContext != null)
  {
    gDrawingContext.clearRect(0, 0, kPixelWidth, kPixelHeight);
    for(var i=0;i<allPlayers.length;i++) {
      if (allPlayers[i][3] == <%= current_user.facebook_id %>) {
        playerIndex = i;
        continue;
      }
      drawPlayer(allPlayers[i])
    }
    gDrawingContext.beginPath();
    for(var j=0;j<allBombs.length;j++) {
      drawMissleAndPath(allBombs[j]);
    }
    gDrawingContext.strokeStyle = "#FFF";
    gDrawingContext.stroke();
  }
}
function drawImpactArea(b) {
}
function drawMissleAndPath(b) {
  var targetLatLng=new google.maps.LatLng(b[0], b[1]);
  var sourceLatLng=new google.maps.LatLng(b[6], b[7]);
  var targetLocation = gOverlayProjection.fromLatLngToDivPixel(targetLatLng);
  var launchLocation = gOverlayProjection.fromLatLngToDivPixel(sourceLatLng);
  if (b[2] > 0) {
    gDrawingContext.moveTo(launchLocation.x, launchLocation.y);
    gDrawingContext.lineTo(targetLocation.x, targetLocation.y);
    var distance = haversineDistance(b[0], b[1], b[6], b[7]);
    duration=<%= clientCalcDuration %>*1000;
    dOnPath=b[2]/duration;
    var x = launchLocation.x*(dOnPath)+targetLocation.x*(1-dOnPath);
    var y = launchLocation.y*(dOnPath)+targetLocation.y*(1-dOnPath);
    var missle=new Image();
    missle.src="/images/rocket_06.png";
    missle.onload=function(){
      gDrawingContext.drawImage(missle,x-missle.width/2,y-missle.height/2);
      // add in the animation for this missle
      jQuery(missle).animate({x: targetLocation.x,y:targetLocation.y},5000, function () {
        // animation complete
        });
    }
  }
}
function drawPlayer(p) {
  var targetLocation = gOverlayProjection.fromLatLngToDivPixel(new google.maps.LatLng(p[0], p[1]));
  var person=new Image();
  if (p[4]) {
    person.src = "/images/tombstone.gif";
  }
  else {
    person.src = "http://graph.facebook.com/" + p[3] + "/picture";
  }
  person.onload=function(){
    gDrawingContext.drawImage(person,targetLocation.x-person.width/2,targetLocation.y-person.height/2);
  }
}
function initialize() {
  var mapOptions = {
    zoom: 14,
    mapTypeIds: [google.maps.MapTypeId.TERRAIN, "platoMap"],
    navigationControl: true,
    navigationControlOptions: { style: google.maps.NavigationControlStyle.SMALL },
    mapTypeControl: false,
    streetViewControl: false
  };
  map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
  setMapLocation();
  mapTypeExperiment();
  addOverlay();
  tick();
}

function addOverlay() {
  bombPathOverlay = new BombPathOverlay(map);
}

function haversineDistance(lat1, lon1, lat2, lon2) {
  var R = 6371 * 1000; // meters;
  var dLat = (lat2-lat1) * Math.PI / 180;
  var dLon = (lon2-lon1) * Math.PI / 180;
  var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLon/2) * Math.sin(dLon/2);
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  var d = R * c;
  return d;
}

function tick() {
  setTimeout("tick()", TICK_INTERVAL);
  if (gDrawingContext)
  {
    drawGame();
  }
}
window.onload = initialize;

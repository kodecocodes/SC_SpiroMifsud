
var express = require('express');
var connection = require('./connection');
var bodyParser = require ('body-parser');
var app = express();

var socketserver = require('http').createServer();
var io = require('socket.io')(socketserver);

app.use(bodyParser.json())

// Webhook GET destination for Strava to hit with a random token to return for subsription call
app.get ('/stravasubscriptions', function (request, response,err){
response.json(request.query['hub.challenge']);

});

// Webhook POST destination from Strava
app.post ('/stravasubscriptions', function (request, response,err){
emitActivityEvent()
response.json({status: 200});
});
// event called on Socket.IO connection
io.on('connect', function(client)
{
	// incoming parameters
	var clientID = client.id;
	var token = client.handshake.query.token;
	console.log ("connected: " + client.id); // print to console the incoming socket ID
})

function emitActivityEvent()
{
	io.sockets.emit('activitiesUpdated');
	// Note: you would probably want to keep track of the socketIDs and tokens/IDs and emit specifically to those activities from 
	//io.sockets.connected[socket_value.socketid].emit('activitiesUpdated');
    
};

socketserver.listen(8080); // Socket.IO, port 8080
app.listen (3000); // API, port 3000

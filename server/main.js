var app = require('express')();
var http = require('http').Server(app);
var fs = require("fs");
var socketio = require('socket.io');
var io = socketio.listen(http);

app.get('/', function(req, res){
  res.sendFile(__dirname + '/webClient/index.html');
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});

io.on('connection', function(socket){
  console.log('a user connected');
  socket.emit('ready');

  socket.on('msg', function (msg) {
    console.log('msg', msg);
  });
});


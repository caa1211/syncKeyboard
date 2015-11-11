var app = require('express')();
var http = require('http').Server(app);
var fs = require("fs");
var io = require('socket.io').listen(3001);
//var io = socketio.listen(http);

app.get('/', function(req, res){
  res.sendFile(__dirname + '/webClient/index.html');
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});

io.sockets.on('connection', function(socket, aaa){

  console.log('a user connected');
  socket.on('set nickname', function (name) {

    socket.set('nickname', name, function () { 
    	console.log("name", name);
    	socket.emit('ready'); 
    });

  });

  socket.on('message', function (message) {
  	console.log("message", message);
   
  });


  socket.on('joinRoom', function (roomName) {
    socket.join(roomName);
    socket.emit('roomJoined', {room: roomName, data: "room joined"});

    var clients = io.sockets.clients(roomName);
    console.log("join room:" +roomName+ ", now connection:" + clients.length);
  });

   socket.on('leaveRoom', function (roomName) {
       socket.leave(roomName);
       socket.emit('roomLeft', {room: roomName, data: "room left"});
       
       var clients = io.sockets.clients(roomName);
       console.log("leave room:" +roomName+ ", now connection:" + clients.length);
   });
    

  socket.on('sendMsg', function (param) {
  	console.log("sendMsg to room", param.room);
    socket.broadcast.to(param.room).emit('receiveMsg', param); 
  });

   socket.on('sendCtlMsg', function (param) {
        console.log("sendCtlMsg to room", param.room);
        socket.broadcast.to(param.room).emit('receiveCtrlMsg', param);
   });

});


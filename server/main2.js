var ip   = "127.0.0.1",
    port = 1337,
    http = require('http'),
    url = require("url"),
    path = require("path"),
    fs = require("fs");

function onRequest(request, response) {
    
    var pathname = url.parse(request.url).pathname;
    console.log("Request for " + pathname + " received.");

    var queryData = url.parse(request.url, true).query;
    console.log("query data ", queryData);


    // ROUTE: cube page
    if(pathname == "/"){
	    var filename = "../webClient/index.html";
		    response.writeHead(200, {
	        "Content-Type": "text/html"
	    });
	    fs.readFile(filename, "utf8", function(err, data) {
	        if (err) throw err;
	        response.write(data);
	        response.end();
	    });
	}

    // ROUTE: api
	else if(pathname == "/api"){
	    var argv = queryData && queryData["argv"] || "";
		
	}
    // ROUTE: 404
	else {
		response.writeHead(200);
		response.write("404 Not Found\n");
		response.end();
	}
  
}
http.createServer(onRequest).listen(port, ip);
console.log("Server has started: http://"+ip+":"+port);
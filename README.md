
# RakuDoc renderer inside a container

	Renders RakuDoc sources into HTML and returns HTML

----

## Table of Contents

<a href="#Overview">Overview</a>   
<a href="#Websocket">Websocket</a>   
<a href="#Generating_the_Image">Generating the Image</a>   
<a href="#Running_the_container">Running the container</a>   
<a href="#Example_inside_browser">Example inside browser</a>   
<a href="#Credits">Credits</a>   


<div id="Overview"></div>

## Overview
<span class="para" id="ca9fdec"></span>Repo for the creation of a docker container with Cro. 

<span class="para" id="653ffa1"></span>Maintained as `docker.io/finanalyst/rakuast-render-websocket` 

<span class="para" id="4b405a2"></span>Intended to render a RakuDoc source payload delivered via a websocket into a single file HTML (all assets and in HTML text), and return via same websocket. 

<div id="Websocket"></div>

## Websocket
<span class="para" id="15dc813"></span>The websocket name is `rakudoc_render`. 

<span class="para" id="93fbeed"></span>Assuming an incoming json payload with one of two keys: 


<span style="font-weight: 600; font-style: italic">1.&nbsp;source</span>

&nbsp;&nbsp;<span style="background-color: lightgrey;">Valid RakuDoc source </span>

<span style="font-weight: 600; font-style: italic">2.&nbsp;loaded</span>

&nbsp;&nbsp;<span style="background-color: lightgrey;">A boolean requesting a handshake to indicate the websocket is established </span>

<span class="para" id="2637111"></span>Then a json payload is returned. If **loaded** was sent, 


<span style="font-weight: 600; font-style: italic">connection</span>

&nbsp;&nbsp;<span style="background-color: lightgrey;">Value is 'Confirmed' and websocket is established. </span>

<span class="para" id="5d81796"></span>If **source** was sent, 


<span style="font-weight: 600; font-style: italic">html</span>

&nbsp;&nbsp;<span style="background-color: lightgrey;"><span class="para" id="eb60d6f"></span>The `single-file` HTML rendering as defined for RenderDocs in the Rakuast-RakuDoc-Render distribution 

</span>

<span style="font-weight: 600; font-style: italic">err</span>

&nbsp;&nbsp;<span style="background-color: lightgrey;">Any errors as an HTML div </span>


<div id="Generating the Image"></div><div id="Generating_the_Image"></div>

## Generating the Image
<span class="para" id="bfc3816"></span>The DockerFile will generate an image based on the Alpine image, compile Rakudo, zef, Cro, and Rakuast::RakuDoc::Render and run the Cro service. 

<span class="para" id="8cc8a95"></span>The image can be obtained with `````` sudo docker pull docker.io/finanalyst/rakudoc-render-socket:latest `````` 


<div id="Running the container"></div><div id="Running_the_container"></div>

## Running the container
<span class="para" id="20af9fd"></span>In the server, after the docker pull `````` sudo docker run --rm -d -p 50005:50005 docker.io/finanalyst/rakudoc-render-socket:latest `````` 


<div id="Example inside browser"></div><div id="Example_inside_browser"></div>

## Example inside browser
<span class="para" id="9f3dd00"></span>Once the container is running, the following bare (no CSS) HTML page will push Rakudoc source to the container. 


```
<html>
    <head>
        <title>Test</title>
        <script>
            var websocketHost = "some-domain-where-container-is-running.org";
            var preview;
            var socketIndicator;
            // credit: This javascript file is adapted from
            // https://fjolt.com/article/javascript-websockets
            // Connect to the websocket
            var socket;
            // This will let us create a connection to our Server websocket.
            const connect = function() {
                // Return a promise, which will wait for the socket to open
                return new Promise((resolve, reject) => {
                    // This calculates the link to the websocket.
                    const socketUrl = `wss://${websocketHost}/rakudoc_render`;
                    socket = new WebSocket(socketUrl);

                    // This will fire once the socket opens
                    socket.onopen = (e) => {
                        // Send a little test data, which we can use on the server if we want
                        socket.send(JSON.stringify({ "loaded" : true }));
                        // Resolve the promise - we are connected
                        resolve();
                    }

                    // This will fire when the server sends the user a message
                    socket.onmessage = (data) => {
                        let parsedData = JSON.parse(data.data);
                        if (parsedData.connection == 'Confirmed') {
                            socketIndicator.dataset.openchannel = 'on';
                        }
                        else {
                            preview.srcdoc = parsedData.html;
                        }
                    }
                    // This will fire on error
                    socket.onerror = (e) => {
                        // Return an error if any occurs
                        console.log(e);
                        socketIndicator.dataset.openchannel = 'off';
                        resolve();
                        // Try to connect again
                        connect();
                    }
                });
            }

            // @isOpen
            // check if a websocket is open
            const isOpen = function(ws) {
                return ws.readyState === ws.OPEN
            }
            function sendSource() {
                let source = content.innerText;
                if(isOpen(socket)) {
                    socket.send(JSON.stringify({
                        "source" : source
                    }))
                }
            }
            document.addEventListener('DOMContentLoaded', function () {
                content = document.getElementById('initContent');
                preview = document.getElementById('preview');
                renderContent = document.getElementById('getHTML');
                socketIndicator = document.getElementById('socketIndicator');
                connect();
                sendSource();
                renderContent.addEventListener('click', () => {
                    sendSource();
                });
            });
        </script>
    </head>
    <body>
        <button id="getHTML">Render Source</button>
        <div data-openchanel="off">Render Server</div>
        <iframe id="preview"></iframe>
        <div id="initContent">=begin rakudoc
=head A heading

Some text
=end rakudoc
        </div>
    </body>
</html>
```
<div id="Credits"></div>

## Credits
Richard Hainsworth aka finanalyst




<div id="VERSION"></div><div id="VERSION_0"></div>

## VERSION
 <div class="rakudoc-version">v0.1.0</div> 



----

----

Rendered from docs/README.rakudoc/README at 12:53 UTC on 2025-03-31

Source last modified at 12:52 UTC on 2025-03-31


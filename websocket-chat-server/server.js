const WebSocket = require('ws');
const http = require('http');

// Create HTTP server
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('WebSocket chat server\n');
});

// Create WebSocket server
const wss = new WebSocket.Server({ server });

// Store connected clients and chat history
const clients = new Set();
const chatHistory = [];

wss.on('connection', (ws) => {
  console.log('New client connected');
  clients.add(ws);

  // Send chat history to the new client
  ws.send(JSON.stringify({ type: 'history', data: chatHistory }));

  ws.on('message', (message) => {
    console.log(`Received: ${message}`);

    // Parse the message
    const data = JSON.parse(message);
    chatHistory.push(data);

    // Broadcast the message to all clients
    clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ type: 'message', data: data }));
      }
    });
  });

  ws.on('close', () => {
    console.log('Client disconnected');
    clients.delete(ws);
  });

  ws.on('error', (error) => {
    console.error('WebSocket error:', error);
  });
});

// Start the server
const PORT = 8080;
server.listen(PORT, () => {
  console.log(`Server is listening on port ${PORT}`);
});
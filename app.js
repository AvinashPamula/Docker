const express = require('express');
const app = express();
const port = 9000;

app.get('/', (req, res) => {
  res.send('Hello from a Multi-Stage Docker Container!');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});

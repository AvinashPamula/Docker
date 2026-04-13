const express = require('express');
const app = express();
const port = 9000;

// Feature flag from environment variable
const NEW_FEATURE_ENABLED = process.env.NEW_FEATURE_ENABLED === 'true';

app.get('/', (req, res) => {
  res.send('Hello from a Multi-Stage Docker Container!');
});

// New feature endpoint
app.get('/new-feature', (req, res) => {
  if (!NEW_FEATURE_ENABLED) {
    return res.status(403).send('New Feature is disabled');
  }
  res.send('🎉 New Feature is ENABLED!');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
  console.log(`New Feature Enabled: ${NEW_FEATURE_ENABLED}`);
});

const express = require('express');
const LaunchDarkly = require('launchdarkly-node-server-sdk');

const app = express();
const port = 9000;

// Initialize LaunchDarkly client
const ldClient = LaunchDarkly.init(process.env.LAUNCHDARKLY_SDK_KEY);

// Ensure LD is ready
async function getFlagValue() {
  await ldClient.waitForInitialization();

  const user = { key: "user-123" };

  const flagValue = await ldClient.variation(
    "NEW_FEATURE_ENABLED", // flag key in LaunchDarkly
    user,
    false // default value
  );

  return flagValue;
}

app.get('/', (req, res) => {
  res.send('Hello from a Multi-Stage Docker Container!');
});

// New feature endpoint
app.get('/new-feature', async (req, res) => {
  try {
    const isEnabled = await getFlagValue();

    if (!isEnabled) {
      return res.status(403).send('New Feature is disabled');
    }

    res.send('🎉 New Feature is ENABLED!');
  } catch (error) {
    console.error("LaunchDarkly error:", error);
    res.status(500).send("Error fetching feature flag");
  }
});

app.listen(port, async () => {
  console.log(`App listening at http://localhost:${port}`);

  try {
    const isEnabled = await getFlagValue();
    console.log(`New Feature Enabled: ${isEnabled}`);
  } catch (err) {
    console.log("LaunchDarkly not ready yet");
  }
});

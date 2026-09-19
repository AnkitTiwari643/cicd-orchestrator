const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
app.use(express.json());

app.get('/health', (req, res) => res.status(200).send('ok'));
app.get('/api/version', (req, res) => res.json({ version: process.env.APP_VERSION || 'dev' }));

if (require.main === module) {
  app.listen(PORT, () => console.log(`app on ${PORT}`));
}
module.exports = app;

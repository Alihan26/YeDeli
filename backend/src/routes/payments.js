const express = require('express');
const router = express.Router();

router.post('/create-intent', (req, res) => {
  res.json({ success: true, data: { clientSecret: 'mock_secret' } });
});

module.exports = router;



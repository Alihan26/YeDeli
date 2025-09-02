const express = require('express');
const router = express.Router();

// Minimal stub routes to satisfy server imports. Replace with real handlers later.
router.get('/', (req, res) => {
  res.json({ success: true, message: 'Users route stub' });
});

module.exports = router;



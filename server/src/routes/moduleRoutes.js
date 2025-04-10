const express = require('express');
const router = express.Router();
const Module = require('../models/Modules');

// CREATE Module
router.post('/create', async (req, res) => {
  try {
    const { name, description, userId } = req.body;
    const module = new Module({ name, description, userId });
    await module.save();
    res.status(201).json({ message: 'Module created', module });
  } catch (err) {
    res.status(500).json({ error: 'Error creating module', details: err });
  }
});

// GET all modules for a user
router.get('/all/:userId', async (req, res) => {
  try {
    const modules = await Module.find({ userId: req.params.userId });
    res.json(modules);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching modules' });
  }
});

// GET single module by moduleId
router.get('/get/:moduleId', async (req, res) => {
  try {
    const module = await Module.findOne({ moduleId: req.params.moduleId });
    if (!module) return res.status(404).json({ message: 'Module not found' });
    res.json(module);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching module' });
  }
});

// UPDATE by moduleId
router.put('/update/:moduleId', async (req, res) => {
  try {
    const updated = await Module.findOneAndUpdate(
      { moduleId: req.params.moduleId },
      req.body,
      { new: true }
    );
    if (!updated) return res.status(404).json({ message: 'Module not found' });
    res.json({ message: 'Module updated', module: updated });
  } catch (err) {
    res.status(500).json({ error: 'Error updating module' });
  }
});

// DELETE by moduleId
router.delete('/delete/:moduleId', async (req, res) => {
  try {
    const deleted = await Module.findOneAndDelete({ moduleId: req.params.moduleId });
    if (!deleted) return res.status(404).json({ message: 'Module not found' });
    res.json({ message: 'Module deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Error deleting module' });
  }
});

module.exports = router;

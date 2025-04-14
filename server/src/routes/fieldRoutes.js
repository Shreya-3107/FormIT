const express = require('express');
const router = express.Router();
const Field = require('../models/Fields');
const authMiddleware = require('../middleware/authMiddleware');

// 👉 Create Field
router.post('/create', authMiddleware, async (req, res) => {
  try {
    const { moduleId, name, type, orgId } = req.body;

    if (!moduleId || !name || !orgId) {
      return res.status(400).json({ message: 'orgId, moduleId, and name are required' });
    }

    const newField = new Field({
      orgId,
      moduleId,
      name,
      type
    });

    const savedField = await newField.save();
    res.json({ message: 'Field created successfully', field: savedField });
  } catch (error) {
    res.status(500).json({ message: 'Error creating field', error });
  }
});

// 👉 Get Fields by Module
router.get('/getall/:moduleId', authMiddleware, async (req, res) => {
  try {
    const { moduleId } = req.params;
    const { orgId } = req.query;

    if (!orgId) {
      return res.status(400).json({ message: 'orgId is required' });
    }

    const fields = await Field.find({ orgId, moduleId });
    res.json({ fields });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching fields', error });
  }
});

// 👉 Get Field dets by field ID
router.get('/getfield/:fieldId', authMiddleware, async (req, res) => {
  try{
    const field = await Field.findOne({ fieldId: req.params.fieldId });
    if (!field) return res.status(404).json({ message: 'Field not found' });
    res.json({ field });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching field', error });
  }
});

// 👉 Update Field
router.put('/update/:fieldId', authMiddleware, async (req, res) => {
  try {
    const { fieldId } = req.params;
    const { name, type, orgId } = req.body;

    if (!orgId) {
      return res.status(400).json({ message: 'orgId is required' });
    }

    const updatedField = await Field.findOneAndUpdate(
      { fieldId, orgId },
      { name, type },
      { new: true }
    );

    if (!updatedField) {
      return res.status(404).json({ message: 'Field not found or org mismatch' });
    }

    res.json({ message: 'Field updated', field: updatedField });
  } catch (error) {
    res.status(500).json({ message: 'Error updating field', error });
  }
});

// 👉 Delete Field
router.delete('/delete/:fieldId', authMiddleware, async (req, res) => {
  try {
    const { fieldId } = req.params;
    const { orgId } = req.body;

    if (!orgId) {
      return res.status(400).json({ message: 'orgId is required' });
    }

    const deleted = await Field.findOneAndDelete({ fieldId, orgId });

    if (!deleted) {
      return res.status(404).json({ message: 'Field not found or org mismatch' });
    }

    res.json({ message: 'Field deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting field', error });
  }
});

module.exports = router;

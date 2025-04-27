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

    // Get the maximum index for the module and increment by 1
    const lastField = await Field.findOne({ moduleId }).sort({ index: -1 }).exec();
    const newIndex = lastField ? lastField.index + 1 : 0;

    const newField = new Field({
      orgId,
      moduleId,
      name,
      type,
      index: newIndex,  // Add index here
    });

    const savedField = await newField.save();
    res.json({ message: 'Field created successfully', field: savedField });
  } catch (error) {
    res.status(500).json({ message: 'Error creating field', error });
  }
});

// 👉 Get Fields by Module
router.get('/getforMod/:moduleId', authMiddleware, async (req, res) => {
  try {
    const { moduleId } = req.params;

    const fields = await Field.find({ moduleId }).sort({ index: 1 });  // Sort by index
    res.json({ fields });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching fields', error });
  }
});

// 👉 Get Field dets by field ID
router.get('/getfield/:fieldId', authMiddleware, async (req, res) => {
  try{
    const field = await Field.findById(req.params.fieldId);
    if (!field) return res.status(404).json({ message: 'Field not found' });
    res.json({ field });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching field', error });
  }
});

// 👉 Update Field
router.put('/update/:fieldId', authMiddleware, async (req, res) => {
  try {
    const { name, type, index } = req.body;

    const field = await Field.findById(req.params.fieldId);

    field.name = name || field.name;
    field.type = type || field.type;
    field.index = index !== undefined ? index : field.index;  // Allow updating index

    await field.save();

    res.json({ message: 'Field updated successfully', field: field });
  } catch (error) {
    res.status(500).json({ message: 'Error updating field', error });
  }
});


// 👉 Delete Field
router.delete('/delete/:fieldId', authMiddleware, async (req, res) => {
  try {
    const { fieldId } = req.params;

    const deleted = await Field.findOneAndDelete({ _id: fieldId });

    if (!deleted) {
      return res.status(404).json({ message: 'Field not found or org mismatch' });
    }

    res.json({ message: 'Field deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting field', error });
  }
});

module.exports = router;

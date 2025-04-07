const express = require("express");
const router = express.Router();
const Record = require("../models/Records");
const authMiddleware = require("../middleware/authMiddleware");

// ✅ Create a record
router.post("/create", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { moduleId, data } = req.body;

    if (!moduleId || !Array.isArray(data)) {
      return res.status(400).json({ message: "moduleId and data are required" });
    }

    // Auto-increment recordId
    const lastRecord = await Record.findOne({ moduleId }).sort({ recordId: -1 });
    const nextRecordId = lastRecord ? lastRecord.recordId + 1 : 1;

    const newRecord = new Record({
      userId,
      moduleId,
      recordId: nextRecordId,
      data
    });

    await newRecord.save();
    res.status(201).json({ message: "Record created", record: newRecord });
  } catch (error) {
    res.status(500).json({ message: "Error creating record", error });
  }
});

// ✅ Get all records for a module (list view)
router.get("/list/:moduleId", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { moduleId } = req.params;

    const records = await Record.find({ userId, moduleId });

    // Send list view: recordId + optionally the first data field as title
    const list = records.map(r => ({
      recordId: r.recordId,
      title: r.data[0]?.value || `Record ${r.recordId}`
    }));

    res.json({ records: list });
  } catch (error) {
    res.status(500).json({ message: "Error fetching records", error });
  }
});

// ✅ Get detailed view of a record
router.get("/detailed/:moduleId/:recordId", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { moduleId, recordId } = req.params;

    const record = await Record.findOne({ userId, moduleId, recordId });

    if (!record) {
      return res.status(404).json({ message: "Record not found" });
    }

    res.json({ record });
  } catch (error) {
    res.status(500).json({ message: "Error fetching record", error });
  }
});

// ✅ Update record
router.put("/update/:moduleId/:recordId", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { moduleId, recordId } = req.params;
    const { data } = req.body;

    const updated = await Record.findOneAndUpdate(
      { userId, moduleId, recordId },
      { data },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({ message: "Record not found" });
    }

    res.json({ message: "Record updated", record: updated });
  } catch (error) {
    res.status(500).json({ message: "Error updating record", error });
  }
});

// ✅ Delete record
router.delete("/delete/:moduleId/:recordId", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { moduleId, recordId } = req.params;

    const deleted = await Record.findOneAndDelete({ userId, moduleId, recordId });

    if (!deleted) {
      return res.status(404).json({ message: "Record not found" });
    }

    res.json({ message: "Record deleted" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting record", error });
  }
});

module.exports = router;

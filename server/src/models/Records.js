const mongoose = require("mongoose");

const recordSchema = new mongoose.Schema({
  orgId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', required: true },
  moduleId: { type: String, required: true },
  recordId: { type: Number, required: true },
  data: [
    {
      fieldName: { type: String, required: true },
      value: { type: String, required: true }
    }
  ]
}, { timestamps: true });

module.exports = mongoose.model("Record", recordSchema);

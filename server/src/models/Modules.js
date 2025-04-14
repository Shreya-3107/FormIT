const mongoose = require('mongoose');

const ModuleSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  orgId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', required: true }
}, { timestamps: true });

module.exports = mongoose.model('Module', ModuleSchema);

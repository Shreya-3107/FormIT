const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const ModuleSchema = new mongoose.Schema({
  moduleId: { type: String, default: () => uuidv4(), unique: true },
  name: { type: String, required: true },
  description: { type: String },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }
}, { timestamps: true });

module.exports = mongoose.model('Module', ModuleSchema);

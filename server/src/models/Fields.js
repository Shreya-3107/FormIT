const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const fieldSchema = new mongoose.Schema({
  fieldId: { type: String, default: uuidv4, unique: true },
  orgId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization', required: true },
  moduleId: { type: String, required: true },
  name: { type: String, required: true },
  type: { type: String, default: 'text' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Field', fieldSchema);

const mongoose = require('mongoose');

const organizationSchema = new mongoose.Schema({
  orgName: { type: String, required: true},
  industry: { type: String, required: true},
  description: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  createdAt: { type: Date, default: Date.now },
});

const Organization = mongoose.model('Organization', organizationSchema);

module.exports = Organization;

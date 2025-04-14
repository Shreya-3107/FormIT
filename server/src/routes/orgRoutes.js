const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const Organization = require('../models/Organization');
const authMiddleware = require('../middleware/authMiddleware');

// **Create Organization**
router.post('/create', authMiddleware, async (req, res) => {
    try {
      const { orgName, description, industry } = req.body;
      const userId = req.user.userId || req.user._id; // depending on your authMiddleware
  
      if (!orgName || !description) {
        return res.status(400).json({ message: 'orgName and description are required' });
      }
  
      const newOrg = new Organization({ orgName, description, industry, userId });
      await newOrg.save();
      
      res.status(201).json({ message: 'Organization created successfully', org: newOrg });
    } catch (error) {
      console.error("Org creation error:", error);
      res.status(500).json({ message: "Error creating organization", error: error.message || error });
    }
});

// Get all organizations for logged-in user
router.get('/getall', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId; // Use userId from the decoded token

    const organizations = await Organization.find({ userId });

    res.status(200).json({ organizations });
  } catch (error) {
    console.error("Error fetching orgs:", error);
    res.status(500).json({ message: "Failed to fetch organizations", error });
  }
});

// **Get a Single Organization**
router.get('/:orgId', authMiddleware, async (req, res) => {
  try {
    const org = await Organization.findById(req.params.orgId);
    
    if (!org) {
      return res.status(404).json({ message: 'Organization not found' });
    }

    res.json({ organization: org });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching organization', error });
  }
});

// **Update Organization**
router.put('/:orgId', authMiddleware, async (req, res) => {
  try {
    const { orgName, industry, description } = req.body;
    const org = await Organization.findById(req.params.orgId);
    
    if (!org) {
      return res.status(404).json({ message: 'Organization not found' });
    }

    org.orgName = orgName || org.orgName;
    org.industry = industry || org.industry;
    org.description = description || org.description;
    
    await org.save();
    res.json({ message: 'Organization updated successfully', organization: org });
  } catch (error) {
    res.status(500).json({ message: 'Error updating organization', error });
  }
});

// **Delete Organization**
router.delete('/:orgId', authMiddleware, async (req, res) => {
  try {
    const { orgId } = req.params;
    const userId = req.user.userId; // Extract userId from token

    // Ensure orgId is a valid MongoDB ObjectId
    if (!mongoose.Types.ObjectId.isValid(orgId)) {
      return res.status(400).json({ message: 'Invalid Organization ID format' });
    }

    // Find the organization by ID
    const org = await Organization.findById(orgId);

    // Check if the organization exists
    if (!org) {
      return res.status(404).json({ message: 'Organization not found' });
    }

    // Ensure the user is the owner of the organization
    if (org.userId.toString() !== userId) {
      return res.status(403).json({ message: 'Not authorized to delete this organization' });
    }

    // Delete the organization
    await org.deleteOne();
    res.json({ message: 'Organization deleted successfully' });
  } catch (error) {
    console.error("Error deleting organization:", error);
    res.status(500).json({
      message: 'Error deleting organization',
      error: error.message || error.stack
    });
  }
});

module.exports = router;

const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/Users");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// **User Signup**
router.post("/signup", async (req, res) => {
    try {
        const { name, email, username, password } = req.body;

        if (!name || !email || !username || !password) {
            return res.status(400).json({ message: "All fields are required" });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "Email already registered" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({ name, email, username, password: hashedPassword });
        await newUser.save();

        res.status(201).json({ message: "User created successfully" });
    } catch (error) {
        res.status(500).json({ message: "Error signing up", error });
    }
});

// **User Login**
router.post("/login", async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: "Email and password required" });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({ message: "Invalid credentials" });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: "Invalid credentials" });
        }

        const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: "30d" });

        res.json({ message: "Login successful", token });
    } catch (error) {
        res.status(500).json({ message: "Error logging in", error });
    }
});

//Get user ID by email or username
router.get("/get-id", authMiddleware, async (req, res) => {
    try {
      const { email, username } = req.query;
  
      if (!email && !username) {
        return res.status(400).json({ message: "Please provide email or username" });
      }
  
      // Find user based on email or username
      const user = await User.findOne({ 
        $or: [{ email: email }, { username: username }] 
      });
  
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
  
      res.json({ userId: user._id });
    } catch (error) {
      res.status(500).json({ message: "Error fetching user ID", error });
    }
});

// Get User Details by ID
router.get("/user/getDetails", authMiddleware, async (req, res) => {
    try {
      const userId = req.user.userId;
  
      // Find the user by ID
      const user = await User.findById(userId).select("-password"); // Exclude password from response
  
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
  
      res.json({ user });
    } catch (error) {
      res.status(500).json({ message: "Error fetching user", error });
    }
  });

// **Update User**
router.put("/user/update", authMiddleware, async (req, res) => {
  try {
    const { name, email, username } = req.body;
    const userId = req.user.userId;

    // Find the user and update details
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { name, email, username },
      { new: true } // Return updated user
    );

    if (!updatedUser) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({ message: "User updated successfully", user: updatedUser });
  } catch (error) {
    res.status(500).json({ message: "Error updating user", error });
  }
});

// **Delete User**
router.delete("/user/delete", authMiddleware, async (req, res) => {
    try {
        await User.findByIdAndDelete(req.user.userId);
        res.json({ message: "User deleted successfully" });
    } catch (error) {
        res.status(500).json({ message: "Error deleting user", error });
    }
});

module.exports = router;

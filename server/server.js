const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const cors = require("cors");

dotenv.config();

const app = express();

// Middleware
app.use(express.json()); // Parse JSON requests
app.use(cors()); // Enable CORS

// Import routes
const authRoutes = require("./src/routes/authRoutes");
const moduleRoutes = require("./src/routes/moduleRoutes");

// Use routes
app.use("/api/auth", authRoutes);

//Module routes
app.use("/api/modules", moduleRoutes);

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log("MongoDB connected"))
    .catch(err => console.log(err));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

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
const orgRoutes = require("./src/routes/orgRoutes");
const moduleRoutes = require("./src/routes/moduleRoutes");
const fieldRoutes = require('./src/routes/fieldRoutes');
const recordRoutes = require('./src/routes/recordRoutes');
const geminiRoutes = require('./src/routes/geminiRoutes');

// User routes
app.use("/api/auth", authRoutes);

//Org routes
app.use("/api/orgs", orgRoutes);

//Module routes
app.use("/api/modules", moduleRoutes);

//Field routes
app.use("/api/fields", fieldRoutes);

//Record routes
app.use("/api/records", recordRoutes);

//Gemini AI routes
app.use('/api/gemini', geminiRoutes);

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log("MongoDB connected"))
    .catch(err => console.log(err));

const PORT = process.env.PORT || 3000;
if (!PORT) {
    throw new Error("❌ PORT not defined! Make sure you're on Render or define PORT manually for local dev.");
  }
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

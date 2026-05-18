import express from "express";
import dotenv from "dotenv";
import { pool } from "./src/config/pgconnection";

dotenv.config();

const app = express();
const PORT = process.env.PORT;

const startServer = async () => {
  try {
    const client = await pool.connect();
    console.log("Database connected successfully");

    client.release();
    app.listen(PORT, () => {
      console.log(`Server listening on port ${PORT}`);
    });
  } catch (error: any) {
    console.error("Database connection failed:", error.message);
    process.exit(1);
  }
};

startServer();

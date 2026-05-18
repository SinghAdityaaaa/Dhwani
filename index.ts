import express from "express";
import dotenv from "dotenv";
import { pool } from "./src/config/pgconnection";
import redisClient from "./src/config/redisconnection";

dotenv.config();

const app = express();
app.get()
const PORT = Number(process.env.PORT) || 5000;

const startServer = async () => {
  try {
    if (!process.env.REDIS_URL) {
      throw new Error("REDIS_URL is missing");
    }

    // PostgreSQL
    const client = await pool.connect();
    console.log("Database connected successfully");
    client.release();

    // Redis
    await redisClient.connect();

    // Server
    app.listen(PORT, () => {
      console.log(`Server listening on port ${PORT}`);
    });
  } catch (error: any) {
    console.error("Startup failed:", error.message);
    process.exit(1);
  }
};

const shutdown = async () => {
  console.log("\nShutting down gracefully...");

  try {
    await redisClient.quit();
    await pool.end();
    console.log("Connections closed");
    process.exit(0);
  } catch (error) {
    console.error("Shutdown error:", error);
    process.exit(1);
  }
};

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);

startServer();
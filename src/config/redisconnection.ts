import { createClient } from "redis";
import dotenv from "dotenv";

dotenv.config();

const redisUrl = process.env.REDIS_URL;

const redisClient = createClient({
  url: redisUrl!
});

redisClient.on("connect", () => {
  console.log("Redis connected");
});

redisClient.on("error", (err) => {
  console.error("edis error:", err.message);
});

redisClient.on("reconnecting", () => {
  console.log("Redis reconnecting...");
});

export default redisClient;
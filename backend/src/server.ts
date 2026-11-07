import dotenv from "dotenv";
import app from "./app";
import { applyMissingMigrations } from "./config/migrate";

dotenv.config();

const PORT = process.env.PORT || 3000;

// Bring an existing database up to date before taking requests.
applyMissingMigrations()
  .catch((error) => console.error("Database migration failed:", error))
  .finally(() => {
    app.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  });

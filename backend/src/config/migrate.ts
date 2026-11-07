import fs from "fs";
import path from "path";
import type { RowDataPacket } from "mysql2";
import pool from "./db";

// Migrations under database/ that schema.sql does not include. Each one is skipped
// when its table (or column) already exists. Keep in sync with docker/initdb.sh.
const MIGRATIONS: Array<{ table: string; column?: string; file: string }> = [
  { table: "pr_number_counter", file: "add_pr_number_reservations.sql" },
  { table: "attachment", column: "file_name", file: "add_attachment_file_name.sql" },
  { table: "pr", column: "budget_code", file: "add_pr_budget_code.sql" },
  { table: "pr", column: "main_group", file: "add_pr_detail_columns.sql" },
  { table: "pr", column: "approval_round", file: "add_approval_rounds.sql" },
  { table: "pr_item", column: "item_name", file: "add_pr_item_detail_columns.sql" },
];

// Apply the migrations this database has not had yet.
export async function applyMissingMigrations(): Promise<void> {
  for (const migration of MIGRATIONS) {
    const [rows] = migration.column
      ? await pool.query<RowDataPacket[]>(`SHOW COLUMNS FROM ${migration.table} LIKE ?`, [migration.column])
      : await pool.query<RowDataPacket[]>("SHOW TABLES LIKE ?", [migration.table]);
    if (rows.length) continue;
    console.log(`Applying database/${migration.file} ...`);
    const statements = fs.readFileSync(path.resolve(__dirname, "../../database", migration.file), "utf8")
      .split(";")
      .map((statement) => statement.replace(/^\s*--.*$/gm, "").trim())
      .filter((statement) => statement && !/^USE\s/i.test(statement));
    for (const statement of statements) await pool.query(statement);
  }
}

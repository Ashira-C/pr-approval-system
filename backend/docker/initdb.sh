#!/bin/bash
# Runs once, on an empty data volume. Applies schema + seed, then each migration
# under database/ that schema.sql does not already include (same checks as
# src/scripts/seed-demo.ts). The entrypoint would otherwise run the files
# alphabetically, migrations before schema.
set -eo pipefail

sql() { mysql --default-character-set=utf8mb4 -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" "$@"; }

apply() { echo "initdb: applying $1"; sql < "/sql/$1"; }

# migrate <file> <table> [column] — skipped when the table/column already exists
migrate() {
  local file=$1 table=$2 column=${3:-}
  local q="SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = '$table'"
  [ -n "$column" ] && q="SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = '$table' AND column_name = '$column'"
  if [ "$(sql -N -e "$q")" != "0" ]; then echo "initdb: skipping $file (already in schema)"; return; fi
  apply "$file"
}

apply schema.sql
apply seed_data.sql
migrate add_pr_number_reservations.sql pr_number_counter
migrate add_attachment_file_name.sql   attachment file_name
migrate add_pr_budget_code.sql         pr budget_code
migrate add_pr_detail_columns.sql      pr main_group
migrate add_approval_rounds.sql        pr approval_round
migrate add_pr_item_detail_columns.sql pr_item item_name

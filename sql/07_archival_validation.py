# Databricks notebook source
import re

base = "s3://salessprintt9"

active_zones = {
    "customers": f"{base}/sftp/customers/",
    "sales": f"{base}/sftp/sales/"
}

archive_zones = {
    "customers": f"{base}/archive/customers/",
    "sales": f"{base}/archive/sales/"
}

failures = []

def valid_filename(name):
    pattern = r".+_\d{14}\.csv$"
    return re.match(pattern, name) is not None

# COMMAND ----------

# Check active zones have only latest timestamp file
print(" ACTIVE ZONE VALIDATION \n")

for entity, path in active_zones.items():

    print(f"Checking active zone: {entity}")

    files = [f.name for f in dbutils.fs.ls(path) if f.name.endswith(".csv")]

    print(f"Files found: {files}")

    if len(files) != 1:
        failures.append(
            f"{entity}: Expected only 1 latest file in active SFTP, found {len(files)}"
        )

    for file in files:

        if valid_filename(file):
            print(f" Valid timestamp format: {file}")

        else:
            failures.append(
                f"{entity}: Invalid filename format - {file}"
            )

    print()

# COMMAND ----------

print(" ARCHIVE ZONE VALIDATION \n")

for entity, path in archive_zones.items():

    print(f"Checking archive zone: {entity}")

    try:
        files = [f.name for f in dbutils.fs.ls(path) if f.name.endswith(".csv")]

        print(f"Archived files: {files}")

        if len(files) == 0:
            failures.append(
                f"archive/{entity}: No archived files found"
            )

        for file in files:

            if valid_filename(file):
                print(f" Archived filename valid: {file}")

            else:
                failures.append(
                    f"archive/{entity}: Invalid archived filename - {file}"
                )

    except Exception:
        failures.append(
            f"archive/{entity}: Archive folder not found"
        )

    print()

# COMMAND ----------

print(" ARCHIVE ZONE VALIDATION \n")

for entity, path in archive_zones.items():

    print(f"Checking archive zone: {entity}")

    try:
        files = [f.name for f in dbutils.fs.ls(path) if f.name.endswith(".csv")]

        print(f"Archived files: {files}")

        if len(files) == 0:
            failures.append(
                f"archive/{entity}: No archived files found"
            )

        for file in files:

            if valid_filename(file):
                print(f"Archived filename valid: {file}")

            else:
                failures.append(
                    f"archive/{entity}: Invalid archived filename - {file}"
                )

    except Exception:
        failures.append(
            f"archive/{entity}: Archive folder not found"
        )

    print()

# COMMAND ----------

print(" FINAL ARCHIVAL VALIDATION REPORT \n")

if failures:

    print("ARCHIVAL VALIDATION FAILED\n")

    for f in failures:
        print("FAILED", f)

else:

    print("ARCHIVAL VALIDATION PASSED\n")

    print("✅ Previous files archived successfully")
    print("✅ Only latest files present in active SFTP")
    print("✅ Date-time naming convention validated")
    print("✅ Archive folders contain historical files")
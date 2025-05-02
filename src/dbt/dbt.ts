import { parseArgs } from "../arg-parser";
import {
  runWithDBTDocker,
  pullDBTImage,
  testDocker,
  ensureGcloud,
} from "./dbt-utils";

const dbt = async () => {
  const { flags } = parseArgs();
  console.log("🧪 Running DBT with Docker 🐳");
  await runWithDBTDocker(process.argv, "dbt", flags.dbtDir);
};

const test = async () => {
  try {
    await ensureGcloud();
  } catch (error) {
    console.error(
      `Gcloud is required to run DBT with Token Terminal. ${error}`
    );
  }

  try {
    await testDocker();
    console.log("🐳 Docker is installed");
  } catch (error) {
    console.error(
      `Docker is required to run DBT with Token Terminal. ${error}`
    );
  }

  try {
    console.log(`🚀 Pulling the latest DBT image`);
    await pullDBTImage();
    console.log(`🚀 Pulled the latest DBT image`);
  } catch (error) {
    console.log(
      `Failed to pull the latest DBT image. ${error}, trying to login`
    );
    const logs = (error as any).logs;
    //If errors include Unauthenticated requests then run login
    if (
      logs.stdErr.includes("Unauthenticated request") ||
      logs.stdErr.includes("Unauthenticated request")
    ) {
      console.log(`Re-attempting to pull the latest DBT image`);
      try {
        await pullDBTImage();
      } catch (error) {
        console.log(
          `Failed to pull the latest DBT image. Ensure permissions or talk with Jarmo ${error}`
        );
      }
    }
  }
  console.log(`🚀 tt-dbt is installed and ready to use`);
};

const sqlfluff = async () => {
  const { flags } = parseArgs();
  console.log("🧪 Running sqlfluff with Docker 🐳");

  await runWithDBTDocker(process.argv, "sqlfluff", flags.dbtDir);
};

const docsServe = async () => {
  const { flags } = parseArgs();
  console.log("🧪 Running dbt docs serve with Docker 🐳");

  // Create a completely new array with just the necessary arguments
  // This removes any reference to the original 'docs-serve' command
  const newArgs = [process.argv[0], process.argv[1]]; // Keep just the node and script path
  await runWithDBTDocker(newArgs, "dbt", flags.dbtDir, [
    "docs",
    "serve",
    "--port",
    "8080",
    "--host",
    "0.0.0.0",
  ]);
};

const help = async () => {
  console.log(`Run sqlfluff or dbt with Docker 🐳 with the Token Terminal configuration.

DBT usage:

  tt-dbt [dbt args]

  Use any dbt args as you would with the dbt CLI. For example:

  $ tt-dbt run -m my_model

SQLFluff usage:

  tt-dbt sqlfluff [sqlfluff args]

  Use any sqlfluff args as you would with the dbt CLI. For example:

  $ tt-dbt sqlfluff lint models/
  
Docs serve usage:

  tt-dbt docs-serve

  This will run 'dbt docs serve' and expose it on port 8080.`);
};

export const commands: Record<string, () => Promise<void>> = {
  dbt,
  "test-installation": test,
  sqlfluff,
  "docs-serve": docsServe,
  help,
};

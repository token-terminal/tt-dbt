import { spawn } from "child_process";
import { join } from "path";
import * as os from "os";

import Debug from "debug";

const debug = Debug("tt-dbt:runwithdocker");

// Define the Docker image to use, use major for now
const dbtImage = `ghcr.io/token-terminal/tt-dbt:v1`;

function isAppleSiliconMac(): boolean {
  const arch = os.arch();
  const platform = os.platform();
  const cpus = os.cpus();

  // Check if the architecture is arm64 and platform is darwin (macOS)
  if (arch === "arm64" && platform === "darwin") {
    // Additional check for specific Apple Silicon CPUs
    const isAppleSilicon = cpus.some((cpu) => cpu.model.includes("Apple"));
    return isAppleSilicon;
  }
  return false;
}

export async function runWithDBTDocker(argv: string[], command: "dbt" | "sqlfluff", _dbtDir: string) {
  const splitIndex = argv.indexOf(command);
  const dbtArgs = argv.slice(splitIndex + 1);
  const dbtDir = process.cwd();
  if (command === "sqlfluff") {
    dbtArgs.splice(1, 0, "--config");
    if (process.env.CI) {
      dbtArgs.splice(2, 0, ".sqlfluff.ci");
    } else {
      dbtArgs.splice(2, 0, ".sqlfluff.local");
    }
  }
  debug(`DB command: ${command}`);
  debug(`DBT Dir: ${dbtDir}`);
  debug(`DBT Args: ${dbtArgs.join(" ")}`);

  // Define the Docker command
  const userHome = os.homedir();
  //console.log(`DbtDIR: ${dbtDir}, ${userHome}, argv: ${argv}`)

  // use platform linux/arm64 if on Apple Silicon
  const dockerArgsPlatform = isAppleSiliconMac() ? ["--platform", "linux/amd64"] : [];
  //    'ghcr.io/dbt-labs/dbt-bigquery:1.8.2',
  // console.log(`DEBUG: ${dbtDir}, ${userHome}`)

  const dockerArgs = ["run", "--rm", "--network=host", `--mount`, `type=bind,source=${dbtDir},target=/usr/app/dbt`];
  if (process.env.CI) {
    //dockerArgs.push(...[`--mount`, `type=bind,readonly,source=${join(userHome, '.dbt')},target=/root/.dbt`])
  } else {
    dockerArgs.push(
      ...[
        `--mount`,
        `type=bind,readonly,source=${join(userHome, ".dbt")},target=/root/.dbt`,
        `--mount`,
        `type=bind,readonly,source=${join(userHome, ".config", "gcloud")},target=/root/.config/gcloud`,
      ]
    );
  }
  if (process.env.BQ_KEY_FILE) {
    // We assume the key file is in the repo folder and thus available in the mount
    dockerArgs.push(...[`-e`, `BQ_KEY_FILE=${process.env.BQ_KEY_FILE}`]);
  }

  dockerArgs.push(...[...dockerArgsPlatform, dbtImage, command, ...dbtArgs]);
  debug(`full command: \`docker ${dockerArgs.join(" ")}\``);

  const runner = new Promise((resolve, reject) => {
    const dockerProcess = spawn("docker", dockerArgs, { stdio: "inherit", env: process.env });

    dockerProcess.on("close", (code) => {
      if (code !== 0) {
        reject(new Error(`Docker process exited with code ${code}`));
      } else {
        resolve(true);
      }
    });

    dockerProcess.on("error", (err) => {
      reject(new Error(`Failed to start Docker process: ${err.message}`));
    });
  });
  return await runner;
}

export async function testDocker() {
  const runner = new Promise((resolve, reject) => {
    const dockerProcess = spawn("docker", ["info"], { stdio: ["ignore", "pipe", "pipe"] });
    let stdErr = "";
    let stdOut = "";

    dockerProcess.stdout.on("data", (data) => {
      stdOut += data.toString();
    });

    dockerProcess.stderr.on("data", (data) => {
      stdErr += data.toString();
    });

    dockerProcess.on("close", (code) => {
      if (code !== 0) {
        const err = new Error(`Docker process exited with code ${code}}`);
        (err as any).logs = {
          stdOut,
          stdErr,
        };

        reject(err);
      } else {
        resolve({ stdOut, stdErr });
      }
    });

    dockerProcess.on("error", (err) => {
      const logs = {
        stdOut,
        stdErr,
      };
      const error = new Error(`Failed to start Docker process: ${err.message}`);
      (error as any).logs = logs;
      reject(error);
    });
  });
  return await runner;
}

export async function pullDBTImage() {
  const runner = new Promise((resolve, reject) => {
    let stdErr = "";
    let stdOut = "";

    const dockerProcess = spawn("docker", ["pull", dbtImage], { stdio: ["ignore", "pipe", "pipe"] });

    dockerProcess.stdout.on("data", (data) => {
      stdOut += data.toString();
    });

    dockerProcess.stderr.on("data", (data) => {
      stdErr += data.toString();
    });

    dockerProcess.on("close", (code) => {
      if (code !== 0) {
        const err = new Error(`Docker process exited with code ${code}}`);
        (err as any).logs = {
          stdOut,
          stdErr,
        };

        reject(err);
      } else {
        resolve({ stdOut, stdErr });
      }
    });

    dockerProcess.on("error", (err) => {
      const logs = {
        stdOut,
        stdErr,
      };
      const error = new Error(`Failed to start Docker process: ${err.message}`);
      (error as any).logs = logs;
      reject(error);
    });
  });

  return runner;
}

export function ensureGcloud() {
  const runner = new Promise((resolve, reject) => {
    const gcloudProcess = spawn("gcloud", ["version"], { stdio: "ignore" });

    gcloudProcess.on("close", (code) => {
      if (code !== 0) {
        reject(new Error(`Gcloud process exited with code ${code}`));
      } else {
        resolve(true);
      }
    });

    gcloudProcess.on("error", (err) => {
      reject(new Error(`Failed to start Gcloud process: ${err.message}`));
    });
  });

  return runner;
}

export async function loginDocker() {
  const runner = new Promise((resolve, reject) => {
    const dockerProcess = spawn("docker", ["login", "ghcr.io"], {
      stdio: "inherit",
    });

    dockerProcess.on("close", (code) => {
      if (code !== 0) {
        reject(new Error(`Docker process exited with code ${code}`));
      } else {
        resolve(true);
      }
    });

    dockerProcess.on("error", (err) => {
      reject(new Error(`Failed to start Docker process: ${err.message}`));
    });
  });

  return runner;
}

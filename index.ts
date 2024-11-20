import { commands as dbtCommands } from "./src/dbt/dbt";
import { parseCommand } from "./src/cmd-parser";

const dbtSubCommands = Object.keys(dbtCommands);

async function main() {
  const cliCommands = parseCommand();

  if (cliCommands.length === 0) {
    await dbtCommands["help"]();
    return;
  }

  if (dbtSubCommands.includes(cliCommands[0])) {
    const commandImpl = dbtCommands[cliCommands[0]];
    await commandImpl();
    return;
  }

  await dbtCommands["dbt"]();
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});

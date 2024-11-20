export const parseCommand = () => {
  let commands: string[] = [];
  for (const arg of process.argv.slice(2)) {
    if (arg.startsWith("--")) {
      continue;
    }

    if (arg.startsWith("-")) {
      continue;
    }

    if (arg.includes(":")) {
      commands.push(...arg.split(":"));
    } else {
      commands.push(arg);
    }
  }

  return commands;
};

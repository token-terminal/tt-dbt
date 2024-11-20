// First one is node runtime path, second one is the file path, third is
// command
export const parseArgs = () => {
  const argv = process.argv.slice(3);

  const flags: Record<string, string> = {};
  const args: string[] = [];

  for (const arg of argv) {
    // Long format
    if (arg.startsWith("--")) {
      const [key, value] = arg.split("=");
      flags[key.slice(2)] = value;
    } else if (arg.startsWith("-")) {
      const [key, value] = arg.split("=");
      flags[key.slice(1)] = value;
    } else {
      args.push(arg);
    }
  }

  return { flags, args };
};

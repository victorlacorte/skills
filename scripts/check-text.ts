#!/usr/bin/env node
// Fails on characters and paths that tracked text must not contain: em dashes
// and curly single quotes (see AGENTS.md), and personal absolute paths, since
// this repository is public.
import { execFileSync } from "node:child_process";
import { lstatSync, readFileSync } from "node:fs";

export interface Problem {
  path: string;
  line: number;
  rule: string;
}

// Built from code points so this file never contains the characters it rejects.
const emDash = String.fromCodePoint(0x2014);
const curlyQuotes = String.fromCodePoint(0x2018, 0x2019);

const rules: ReadonlyArray<{ rule: string; pattern: RegExp }> = [
  { rule: 'em dash (U+2014): use "-" or rewrite the sentence', pattern: new RegExp(emDash) },
  {
    rule: "curly single quote (U+2018 or U+2019): use the plain apostrophe",
    pattern: new RegExp(`[${curlyQuotes}]`),
  },
  {
    rule: 'personal absolute path: use "~" or a placeholder',
    pattern: /\/(?:Users|home)\/[^/\s]+\//,
  },
];

export function findProblems(path: string, text: string): Problem[] {
  const problems: Problem[] = [];
  text.split("\n").forEach((content, index) => {
    for (const { rule, pattern } of rules) {
      if (pattern.test(content)) problems.push({ path, line: index + 1, rule });
    }
  });
  return problems;
}

// Symlinks are skipped: their targets are checked where they live, and a link to
// a directory, such as a skill's references/core, cannot be read as text.
export function withoutSymlinks(paths: string[]): string[] {
  return paths.filter((path) => !lstatSync(path).isSymbolicLink());
}

function trackedFiles(): string[] {
  const output = execFileSync(
    "git",
    ["ls-files", "--cached", "--others", "--exclude-standard", "-z"],
    {
      encoding: "utf8",
    },
  );
  return output.split("\0").filter((path) => path !== "");
}

if (import.meta.main) {
  const problems = withoutSymlinks(trackedFiles()).flatMap((path) =>
    findProblems(path, readFileSync(path, "utf8")),
  );
  for (const { path, line, rule } of problems) console.error(`${path}:${line}: ${rule}`);
  if (problems.length > 0) process.exit(1);
}

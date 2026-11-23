import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { findProblems, withoutSymlinks } from "./check-text.ts";

test("accepts plain punctuation and home-relative paths", () => {
  assert.deepEqual(findProblems("a.md", "It's fine - see ~/.agents/skills.\n"), []);
});

test("reports each rule with its line", () => {
  const [emDash, open, close] = [0x2014, 0x2018, 0x2019].map((code) => String.fromCodePoint(code));
  const text = [
    "ok",
    `a ${emDash} b`,
    `${open}quoted${close}`,
    "cd /" + "Users/someone/coding",
  ].join("\n");
  assert.deepEqual(
    findProblems("a.md", text).map(({ line }) => line),
    [2, 3, 4],
  );
});

test("skips symlinks, including links to directories", (t) => {
  const dir = mkdtempSync(join(tmpdir(), "check-text-"));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  mkdirSync(join(dir, "core"));
  writeFileSync(join(dir, "core", "a.md"), "text\n");
  symlinkSync("core", join(dir, "core-link"));
  symlinkSync("core/a.md", join(dir, "file-link.md"));
  const paths = ["core/a.md", "core-link", "file-link.md"].map((path) => join(dir, path));
  assert.deepEqual(withoutSymlinks(paths), [join(dir, "core", "a.md")]);
});

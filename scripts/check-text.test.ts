import assert from "node:assert/strict";
import { test } from "node:test";
import { findProblems } from "./check-text.ts";

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

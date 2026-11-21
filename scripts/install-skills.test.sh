#!/bin/sh

set -eu

test_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd) || exit 1
repo_root=$(CDPATH='' cd -- "$test_dir/.." && pwd) || exit 1
install=$repo_root/scripts/install-skills

tmpdir=$(mktemp -d) || exit 1
trap 'rm -rf "$tmpdir"' EXIT
err=$tmpdir/stderr.txt

fail_test() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

# expect_link <link> <target>: <link> is a symlink whose target is exactly <target>.
expect_link() {
  [ -L "$1" ] || fail_test "$1 is not a symlink"
  [ "$(readlink "$1")" = "$2" ] || fail_test "$1 points to $(readlink "$1"), want $2"
}

skills=$(find "$repo_root/packages" -name node_modules -prune -o -type f -name SKILL.md -print)
[ -n "$skills" ] || fail_test 'no skills found'

printf 'a. the repository skills pass validation\n'
"$install" --check 2> "$err" || fail_test "a: $(cat "$err")"

printf 'b. links every skill into both roots as a directory link\n'
home=$tmpdir/b
env HOME="$home" "$install" > /dev/null || fail_test 'b: install failed'
for root in "$home/.agents/skills" "$home/.claude/skills"; do
  for skill_md in $skills; do
    skill=$(dirname "$skill_md")
    expect_link "$root/$(basename "$skill")" "$skill"
    [ ! -L "$root/$(basename "$skill")/SKILL.md" ] || fail_test "b: $skill/SKILL.md is a file link"
  done
  [ "$(find "$root" -mindepth 1 | wc -l)" -eq "$(printf '%s\n' "$skills" | wc -l)" ] \
    || fail_test "b: $root has entries other than the skills"
done

printf 'c. is idempotent\n'
out=$(env HOME="$home" "$install") || fail_test 'c: second install failed'
[ -z "$out" ] || fail_test "c: second install changed something: $out"

printf 'd. replaces links from another checkout and keeps unrelated entries\n'
home=$tmpdir/d
mkdir -p "$home/.agents/skills/unrelated" "$home/.claude/skills"
ln -s "$tmpdir/old-checkout/babysit" "$home/.agents/skills/babysit"
ln -s "$tmpdir/old-checkout/babysit" "$home/.claude/skills/babysit"
env HOME="$home" "$install" > /dev/null || fail_test 'd: install failed'
expect_link "$home/.agents/skills/babysit" "$repo_root/packages/babysit"
expect_link "$home/.claude/skills/babysit" "$repo_root/packages/babysit"
[ -d "$home/.agents/skills/unrelated" ] || fail_test 'd: unrelated skill removed'

printf 'e. refuses to replace a real directory but links the rest\n'
home=$tmpdir/e
mkdir -p "$home/.agents/skills/babysit"
if env HOME="$home" "$install" > /dev/null 2>&1; then fail_test 'e: install succeeded'; fi
[ ! -L "$home/.agents/skills/babysit" ] || fail_test 'e: real directory replaced'
expect_link "$home/.claude/skills/babysit" "$repo_root/packages/babysit"
expect_link "$home/.agents/skills/reviewable-prs" "$repo_root/packages/reviewable-prs"

printf 'f. removes stale links into this checkout only\n'
home=$tmpdir/f
mkdir -p "$home/.agents/skills"
ln -s "$repo_root/skills/retired" "$home/.agents/skills/retired"
ln -s "$tmpdir/elsewhere/missing" "$home/.agents/skills/foreign"
env HOME="$home" "$install" > /dev/null || fail_test 'f: install failed'
[ ! -L "$home/.agents/skills/retired" ] || fail_test 'f: stale link kept'
[ -L "$home/.agents/skills/foreign" ] || fail_test 'f: foreign link removed'

printf 'g. invalid layouts fail validation and link nothing\n'
# fixture <case>: a checkout with this script and one valid skill, in $fixture.
fixture() {
  fixture=$tmpdir/fixture-$1
  mkdir -p "$fixture/scripts" "$fixture/packages/good"
  cp "$install" "$fixture/scripts/install-skills"
  printf -- '---\nname: good\n---\n' > "$fixture/packages/good/SKILL.md"
}
# skill <dir> <name>: writes a SKILL.md declaring <name> into <dir> under the fixture.
skill() {
  mkdir -p "$fixture/packages/$1"
  printf -- '---\nname: %s\ndescription: d\n---\n' "$2" > "$fixture/packages/$1/SKILL.md"
}
# expect_invalid <case> <message>: validation and install fail with <message>.
expect_invalid() {
  if "$fixture/scripts/install-skills" --check 2> "$err"; then fail_test "g/$1: --check succeeded"; fi
  grep -q "$2" "$err" || fail_test "g/$1: missing '$2' in: $(cat "$err")"
  home=$tmpdir/home-$1
  if env HOME="$home" "$fixture/scripts/install-skills" > /dev/null 2>&1; then
    fail_test "g/$1: install succeeded"
  fi
  [ ! -e "$home/.agents/skills/good" ] || fail_test "g/$1: linked despite problems"
}

fixture mismatch && skill mismatch other
expect_invalid mismatch "frontmatter name 'other' must match the directory name 'mismatch'"
fixture bad-name && skill Bad--Name Bad--Name
expect_invalid bad-name "name 'Bad--Name' must be 1-64 characters"
fixture duplicate && skill family/good good
expect_invalid duplicate "another skill is also named 'good'"
fixture package-json && printf '{}\n' > "$fixture/packages/good/package.json"
expect_invalid package-json 'contains package.json'
fixture node-modules && mkdir -p "$fixture/packages/good/node_modules"
expect_invalid node-modules 'contains node_modules'
fixture nested && skill good/inner inner
expect_invalid nested 'contains inner/SKILL.md'

printf 'h. skills nested in a package directory are found\n'
fixture family && skill family/member member && printf '{}\n' > "$fixture/packages/family/package.json"
"$fixture/scripts/install-skills" --check 2> "$err" || fail_test "h: $(cat "$err")"
home=$tmpdir/h
env HOME="$home" "$fixture/scripts/install-skills" > /dev/null || fail_test 'h: install failed'
expect_link "$home/.agents/skills/member" "$fixture/packages/family/member"

printf 'ok\n'

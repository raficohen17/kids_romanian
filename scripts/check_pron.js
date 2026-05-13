#!/usr/bin/env node
// scripts/check_pron.js
//
// Lint the English transliterations (`pron:"..."`) in index.html.
//
// Fails (exit 1) on any pron value that contains Hebrew letters but NO niqqud
// diacritic codepoints. Scans both VOCAB_EN and BUILTIN_SENTENCES_EN blocks.
//
// Zero dependencies — just `node scripts/check_pron.js`.

const fs = require('fs');
const path = require('path');

const FILE = path.resolve(__dirname, '..', 'index.html');

// Hebrew letter block U+05D0-U+05EA (alef–tav, final forms inclusive: U+05DA, U+05DD, etc.)
const HEBREW_LETTER = /[א-ת]/;
// Niqqud (vowel points + dagesh + sin/shin dots) — U+05B0..U+05C2 covers the standard set.
const NIQQUD = /[ְ-ׇׂ]/;

// pron values that legitimately have no niqqud (names, abbreviations, etc.).
// Add to this whitelist if you find a false positive.
const EXEMPT = new Set([
  // (none yet)
]);

function readBlock(src, constName) {
  const declRe = new RegExp(`const\\s+${constName}\\s*=\\s*\\[`);
  const m = declRe.exec(src);
  if (!m) return null;
  const start = m.index;
  // Find the closing `\n];` after the declaration. Naive but matches how the
  // file is hand-formatted.
  const tail = src.slice(m.index + m[0].length);
  const endRel = tail.search(/\n\];/);
  if (endRel < 0) return null;
  return {
    start,
    end: m.index + m[0].length + endRel + 3, // include `\n];`
    body: src.slice(m.index + m[0].length, m.index + m[0].length + endRel),
  };
}

function findPronValues(blockBody, blockName) {
  // Match `pron:"<value>"` allowing escaped quotes inside.
  const re = /pron\s*:\s*"((?:\\.|[^"\\])*)"/g;
  const out = [];
  let m;
  while ((m = re.exec(blockBody)) !== null) {
    out.push({
      value: m[1],
      block: blockName,
      offset: m.index,
    });
  }
  return out;
}

function isOffender(value) {
  if (EXEMPT.has(value)) return false;
  if (!HEBREW_LETTER.test(value)) return false; // no Hebrew at all → not in scope
  return !NIQQUD.test(value);
}

function snippetAround(body, offset) {
  const start = Math.max(0, offset - 60);
  const end = Math.min(body.length, offset + 80);
  return body.slice(start, end).replace(/\s+/g, ' ').trim();
}

function main() {
  const src = fs.readFileSync(FILE, 'utf8');
  const targets = ['VOCAB_EN', 'BUILTIN_SENTENCES_EN'];
  let total = 0;
  const offenders = [];

  for (const name of targets) {
    const block = readBlock(src, name);
    if (!block) {
      console.error(`could not locate ${name} block in index.html`);
      process.exit(2);
    }
    const prons = findPronValues(block.body, name);
    total += prons.length;
    for (const p of prons) {
      if (isOffender(p.value)) {
        offenders.push({
          ...p,
          context: snippetAround(block.body, p.offset),
        });
      }
    }
  }

  if (offenders.length === 0) {
    console.log(`All ${total} pron values look niqqud-bearing.`);
    process.exit(0);
  }

  console.error(`${offenders.length} of ${total} pron values are missing niqqud:`);
  const showAll = process.argv.includes('--all');
  const sample = showAll ? offenders : offenders.slice(0, 10);
  for (const o of sample) {
    console.error(`  [${o.block}] "${o.value}"  ←  ${o.context}`);
  }
  if (!showAll && offenders.length > sample.length) {
    console.error(`  ... and ${offenders.length - sample.length} more (run with --all to see them).`);
  }
  process.exit(1);
}

main();

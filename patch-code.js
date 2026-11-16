'use strict';
const fs = require('node:fs'),
  path = require('node:path'),
  crypto = require('node:crypto');
function patch(app) {
  const productPath = path.join(app, 'product.json'),
    product = JSON.parse(fs.readFileSync(productPath));
  if (
    product.version !== '1.145.2' ||
    product.commit !== 'c4453f8ea430795f941c1b2ff6c9321135a74a02'
  )
    throw new Error('Unsupported Code version/commit');
  const file = path.join(app, 'out/vs/workbench/workbench.desktop.main.js');
  let source = fs.readFileSync(file, 'utf8');
  if (source.includes('/* shell-ime verified patch */')) return;
  const digest = crypto
    .createHash('sha256')
    .update(source)
    .digest('base64')
    .replace(/=+$/, '');
  if (digest !== product.checksums['vs/workbench/workbench.desktop.main.js'])
    throw new Error('Unexpected workbench checksum');
  const pattern =
    /this\._register\(([\w$]+)\.parser\.registerOscHandler\(633,([\w$]+)=>this\._handleVSCodeSequence\(\2\)\)\)/g;
  const matches = [...source.matchAll(pattern)];
  if (matches.length !== 1)
    throw new Error('Expected exactly one verified xterm integration point');
  source = source.replace(
    pattern,
    (all, terminal) => all + ',globalThis.__shellIme?.attach(' + terminal + ')'
  );
  source +=
    '\n/* shell-ime verified patch */\n' +
    fs.readFileSync(path.join(__dirname, 'renderer.js'), 'utf8') +
    '\n';
  product.checksums['vs/workbench/workbench.desktop.main.js'] = crypto
    .createHash('sha256')
    .update(source)
    .digest('base64')
    .replace(/=+$/, '');
  fs.writeFileSync(file, source);
  fs.writeFileSync(productPath, JSON.stringify(product, null, 2));
}
if (require.main === module) patch(process.argv[2]);
module.exports = { patch };

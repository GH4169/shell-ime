'use strict';
const vscode = require('vscode');
function activate(context) {
  context.environmentVariableCollection.replace('SHELL_IME_BACKEND', 'vscode');
}
module.exports = { activate };

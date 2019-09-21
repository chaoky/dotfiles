'use strict';
var vscode = require('vscode');
var spawn = require('child_process').spawn;
function run_cmd(cmd, args) {
    var child = spawn(cmd, args);
    var output = "";
    return new Promise(function (resolve, reject) {
        child.on('error', function (code) {
            console.error('error', output);
            reject({ code: code, output: output });
        });
        child.stdout.on('data', function (buffer) { return output += buffer.toString(); });
        child.stderr.on('data', function (buffer) { return output += buffer.toString(); }); // since gtm -v outputs to stderr on ubuntu....
        child.on('close', function (code) { return resolve({ code: code, output: output }); });
    });
}
function activate(context) {
    // check if gtm is installed + available
    run_cmd('gtm', ['verify', '>= 1.2.1'])
        .then(function (res) {
        if (res.output != 'true') {
            vscode.window.showWarningMessage('Installed gtm version is below v1.2.1. Please update your gtm installation.');
        }
    }, function (res) {
        if (res.code < 0) {
            vscode.window.showErrorMessage('gtm is not available on your $PATH. please install it first');
        }
    });
    var subscriptions = [];
    var lastUpdated = new Date();
    var lastSavedFileName;
    var MIN_UPDATE_FREQUENCE_MS = 30000; // 30 seconds
    var gtmStatusBar = new GTMStatusBar();
    function handleUpdateEvent(fileName) {
        var now = new Date();
        // if a new file is being saved OR it have been at least MIN_UPDATE_FREQUENCE_MS, record it
        if (fileName !== lastSavedFileName || (now.getTime() - lastUpdated.getTime()) >= MIN_UPDATE_FREQUENCE_MS) {
            run_cmd('gtm', ['record', '--status', lastSavedFileName])
                .then(function (res) { return gtmStatusBar.updateStatus(res.output); });
            lastSavedFileName = fileName;
            lastUpdated = now;
        }
    }
    // report to gtm everytime a file is saved
    vscode.workspace.onDidSaveTextDocument(function (e) { return handleUpdateEvent(e.fileName); }, this, subscriptions);
    // report to gtm everytime the user's selection of text changes
    vscode.window.onDidChangeTextEditorSelection(function (e) {
        if (e && e.textEditor && e.textEditor.document) {
            handleUpdateEvent(e.textEditor.document.fileName);
        }
    }, this, subscriptions);
    // report  to gtm everytime the user switches textEditors
    vscode.window.onDidChangeActiveTextEditor(function (e) {
        // Note that the event also fires when the active editor changes to undefined.
        if (e && e.document) {
            handleUpdateEvent(e.document.fileName);
        }
    }, this, subscriptions);
}
exports.activate = activate;
var GTMStatusBar = (function () {
    function GTMStatusBar() {
    }
    GTMStatusBar.prototype.updateStatus = function (statusText) {
        // Create as needed
        if (!this.statusBarItem) {
            this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left);
        }
        // Get the current text editor
        var editor = vscode.window.activeTextEditor;
        if (!editor) {
            this.statusBarItem.hide();
            return;
        }
        // Update the status bar
        this.statusBarItem.text = statusText;
        this.statusBarItem.show();
    };
    return GTMStatusBar;
}());
// always active, so no need to deactivate
//# sourceMappingURL=extension.js.map
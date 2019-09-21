"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const cheerio = require("cheerio");
const yaml = require("js-yaml");
const _ = require("lodash");
const LRU = require("lru-cache");
const request = require("request-promise-native");
const vscode = require("vscode");
const constants_1 = require("./constants");
const askHoogle = (variable) => __awaiter(this, void 0, void 0, function* () {
    return yield request({
        url: `https://hoogle.haskell.org/?hoogle=${variable}&scope=set%3Astackage&mode=json`,
        json: true
    }).promise();
});
const withCache = (theCache, f) => (a) => {
    const maybeB = theCache.get(a);
    if (maybeB) {
        return maybeB;
    }
    else {
        const b = f(a);
        theCache.set(a, b);
        return b;
    }
};
const cache = LRU({
    // 1 MB
    max: 1000 * 1000,
    length: (r) => JSON.stringify(r).length
});
const askHoogleCached = withCache(cache, askHoogle);
const doImport = (arg) => __awaiter(this, void 0, void 0, function* () {
    const editor = vscode.window.activeTextEditor;
    if (!editor) {
        return;
    }
    const document = editor.document;
    const edit = new vscode.WorkspaceEdit();
    const lines = document.getText().split('\n');
    const moduleLine = lines.findIndex(line => {
        const lineTrimmed = line.trim();
        return lineTrimmed === 'where' || lineTrimmed.endsWith(' where') || lineTrimmed.endsWith(')where');
    });
    const revInputLine = lines.reverse().findIndex(l => l.startsWith('import'));
    const nextInputLine = revInputLine !== -1 ? lines.length - 1 - revInputLine : moduleLine === -1 ? 0 : moduleLine + 1;
    if (!lines.some(line => new RegExp('^import.*' + _.escapeRegExp(arg.mod)).test(line))) {
        edit.insert(document.uri, new vscode.Position(nextInputLine, 0), 'import ' + arg.mod + '\n');
    }
    try {
        const hpackDoc = yield vscode.workspace.openTextDocument(vscode.workspace.rootPath + '/package.yaml');
        const hpack = yaml.safeLoad(hpackDoc.getText());
        hpack.dependencies = hpack.dependencies || [];
        if (!hpack.dependencies.some((dep) => new RegExp(_.escapeRegExp(arg.package)).test(dep))) {
            hpack.dependencies.push(arg.package);
            edit.replace(hpackDoc.uri, new vscode.Range(new vscode.Position(0, 0), hpackDoc.lineAt(hpackDoc.lineCount - 1).range.end), yaml.safeDump(hpack));
        }
    }
    catch (e) {
        // There is no package.yaml
    }
    yield vscode.workspace.applyEdit(edit);
    yield Promise.all(edit.entries().map(([uri, textEdit]) => __awaiter(this, void 0, void 0, function* () { return yield (yield vscode.workspace.openTextDocument(uri)).save(); })));
});
var ImportIdentifier;
(function (ImportIdentifier) {
    'use strict';
    function registerCommand() {
        return vscode.commands.registerTextEditorCommand(constants_1.CommandNames.ImportIdentifierCommandName, (editor, edit) => __awaiter(this, void 0, void 0, function* () {
            // \u0027 is ' (satisfies the linter)
            const identifierRegExp = new RegExp('[' + _.escapeRegExp('!#$%&*+./<=>?@^|-~:') + ']+' + '|' + '[\\w\u0027]+');
            const identifierRange = editor.selection.isEmpty
                ? editor.document.getWordRangeAtPosition(editor.selections[0].active, identifierRegExp)
                : new vscode.Range(editor.selection.start, editor.selection.end);
            if (!identifierRange) {
                vscode.window.showErrorMessage('No Haskell identifier found at the cursor (here is the regex used: ' + identifierRegExp + ' )');
                return;
            }
            const response = yield askHoogleCached(editor.document.getText(identifierRange));
            const choice = yield vscode.window.showQuickPick(response.filter(result => result.module.name).map(result => ({
                result,
                label: result.package.name,
                description: result.module.name + ' -- ' + cheerio.load(result.item, { xml: {} }).text()
            })));
            if (!choice) {
                return;
            }
            yield doImport({ mod: choice.result.module.name, package: choice.result.package.name });
        }));
    }
    ImportIdentifier.registerCommand = registerCommand;
})(ImportIdentifier = exports.ImportIdentifier || (exports.ImportIdentifier = {}));
//# sourceMappingURL=importIdentifier.js.map
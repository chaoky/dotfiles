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
const vscode_1 = require("vscode");
const constants_1 = require("./constants");
const formatExpressionType = (document, r, typ) => `${document.getText(r)} :: ${typ}`;
const HASKELL_MODE = {
    language: 'haskell',
    scheme: 'file'
};
// Cache same selections...
const blankRange = new vscode_1.Range(0, 0, 0, 0);
let lastRange = blankRange;
let lastType = '';
function getTypes({ client, editor }) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const hints = yield client.sendRequest('workspace/executeCommand', getCmd(editor));
            const arr = hints;
            if (arr.length === 0) {
                throw new Error('No hints');
            }
            const ranges = arr.map(x => [client.protocol2CodeConverter.asRange(x[0]), x[1]]);
            const [rng, typ] = chooseRange(editor.selection, ranges);
            lastRange = rng;
            lastType = typ;
            return [rng, typ];
        }
        catch (e) {
            console.error(e);
            throw new Error(e);
        }
    });
}
/**
 * Choose The range in the editor and coresponding type that best matches the selection
 * @param  {Selection} sel - selected text in editor
 * @param  {Array<[Range, string]>} rngs - the type analysis from the server
 * @returns {[Range, string]}
 */
const chooseRange = (sel, rngs) => {
    const curr = rngs.findIndex(([rng, typ]) => rng.contains(sel));
    // If we dont find selection start/end in ranges then
    // return the type matching the smallest selection range
    if (curr === -1) {
        // NOTE: not sure this should happen...
        return rngs[0];
    }
    else {
        return rngs[curr];
    }
};
const getCmd = (editor) => ({
    command: 'ghcmod:type',
    arguments: [
        {
            file: editor.document.uri.toString(),
            pos: editor.selections[0].start,
            include_constraints: true
        }
    ]
});
var ShowTypeCommand;
(function (ShowTypeCommand) {
    'use strict';
    const displayType = (chan, typ) => {
        chan.clear();
        chan.appendLine(typ);
        chan.show(true);
    };
    function registerCommand(clients) {
        const showTypeChannel = vscode_1.window.createOutputChannel('Haskell Show Type');
        const activeEditor = vscode_1.window.activeTextEditor;
        if (activeEditor === undefined) {
            return null;
        }
        const document = activeEditor.document;
        const cmd = vscode_1.commands.registerCommand(constants_1.CommandNames.ShowTypeCommandName, x => {
            const editor = activeEditor;
            // Get the current file and workspace folder.
            const uri = editor.document.uri;
            const folder = vscode_1.workspace.getWorkspaceFolder(uri);
            // If there is a client registered for this workspace, use that client.
            if (folder !== undefined && clients.has(folder.uri.toString())) {
                const client = clients.get(folder.uri.toString());
                if (client !== undefined) {
                    getTypes({ client, editor })
                        .then(([r, typ]) => {
                        switch (vscode_1.workspace.getConfiguration('languageServerHaskell').showTypeForSelection.command.location) {
                            case 'dropdown':
                                vscode_1.window.showInformationMessage(formatExpressionType(document, r, typ));
                                break;
                            case 'channel':
                                displayType(showTypeChannel, formatExpressionType(document, r, typ));
                                break;
                            default:
                                break;
                        }
                    })
                        .catch(e => console.error(e));
                }
            }
        });
        return [cmd, showTypeChannel];
    }
    ShowTypeCommand.registerCommand = registerCommand;
})(ShowTypeCommand = exports.ShowTypeCommand || (exports.ShowTypeCommand = {}));
var ShowTypeHover;
(function (ShowTypeHover) {
    /**
     * Determine if type information should be included in Hover Popup
     * @param  {TextEditor} editor
     * @param  {Position} position
     * @returns boolean
     */
    const showTypeNow = (editor, position) => {
        // NOTE: This seems to happen sometimes ¯\_(ツ)_/¯
        if (!editor) {
            return false;
        }
        // NOTE: This means cursor is not over selected text
        if (!editor.selection.contains(position)) {
            return false;
        }
        if (editor.selection.isEmpty) {
            return false;
        }
        // document.
        // NOTE: If cursor is not over highlight then dont show type
        if (editor.selection.active < editor.selection.start || editor.selection.active > editor.selection.end) {
            return false;
        }
        // NOTE: Not sure if we want this - maybe we can get multiline to work?
        if (!editor.selection.isSingleLine) {
            return false;
        }
        return true;
    };
    class TypeHover {
        constructor(clients) {
            this.clients = clients;
        }
        provideHover(document, position, token) {
            const editor = vscode_1.window.activeTextEditor;
            if (editor === undefined) {
                return null;
            }
            if (!showTypeNow(editor, position)) {
                return null;
            }
            // NOTE: No need for server call
            if (lastType && editor.selection.isEqual(lastRange)) {
                return Promise.resolve(this.makeHover(document, lastRange, lastType));
            }
            const uri = editor.document.uri;
            const folder = vscode_1.workspace.getWorkspaceFolder(uri);
            // If there is a client registered for this workspace, use that client.
            if (folder !== undefined && this.clients.has(folder.uri.toString())) {
                const client = this.clients.get(folder.uri.toString());
                if (client === undefined) {
                    return null;
                }
                return getTypes({ client, editor }).then(([r, typ]) => {
                    if (typ) {
                        return this.makeHover(document, r, lastType);
                    }
                    else {
                        return null;
                    }
                });
            }
            else {
                return null;
            }
        }
        makeHover(document, r, typ) {
            return new vscode_1.Hover({
                language: 'haskell',
                value: formatExpressionType(document, r, typ)
            });
        }
    }
    ShowTypeHover.registerTypeHover = (clients) => vscode_1.languages.registerHoverProvider(HASKELL_MODE, new TypeHover(clients));
})(ShowTypeHover = exports.ShowTypeHover || (exports.ShowTypeHover = {}));
//# sourceMappingURL=showType.js.map
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const constants_1 = require("./constants");
var InsertType;
(function (InsertType) {
    'use strict';
    function registerCommand(clients) {
        const cmd = vscode_1.commands.registerTextEditorCommand(constants_1.CommandNames.InsertTypeCommandName, (editor, edit) => {
            const ghcCmd = {
                command: 'ghcmod:type',
                arguments: [
                    {
                        file: editor.document.uri.toString(),
                        pos: editor.selections[0].active,
                        include_constraints: true
                    }
                ]
            };
            // Get the current file and workspace folder.
            const uri = editor.document.uri;
            const folder = vscode_1.workspace.getWorkspaceFolder(uri);
            // If there is a client registered for this workspace, use that client.
            if (folder !== undefined && clients.has(folder.uri.toString())) {
                const client = clients.get(folder.uri.toString());
                if (client !== undefined) {
                    client.sendRequest('workspace/executeCommand', ghcCmd).then(hints => {
                        const arr = hints;
                        if (arr.length === 0) {
                            return;
                        }
                        const [rng, typ] = arr[0];
                        const vsRng = client.protocol2CodeConverter.asRange(rng);
                        const symbolRange = editor.document.getWordRangeAtPosition(vsRng.start);
                        const symbolName = editor.document.getText(symbolRange);
                        const indent = ' '.repeat(vsRng.start.character);
                        editor.edit(b => {
                            if (editor.document.getText(vsRng).includes('=')) {
                                b.insert(vsRng.start, `${symbolName} :: ${typ}\n${indent}`);
                            }
                            else {
                                b.insert(vsRng.start, '(');
                                b.insert(vsRng.end, ` :: ${typ})`);
                            }
                        });
                    }, e => {
                        console.error(e);
                    });
                }
            }
        });
        return cmd;
    }
    InsertType.registerCommand = registerCommand;
})(InsertType = exports.InsertType || (exports.InsertType = {}));
//# sourceMappingURL=insertType.js.map
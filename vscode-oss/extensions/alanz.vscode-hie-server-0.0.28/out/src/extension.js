'use strict';
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const child_process = require("child_process");
const os = require("os");
const path = require("path");
const vscode_1 = require("vscode");
const vscode_languageclient_1 = require("vscode-languageclient");
const importIdentifier_1 = require("./commands/importIdentifier");
const insertType_1 = require("./commands/insertType");
const showType_1 = require("./commands/showType");
const docsBrowser_1 = require("./docsBrowser");
let docsBrowserRegistered = false;
let hieCommandsRegistered = false;
const clients = new Map();
function activate(context) {
    return __awaiter(this, void 0, void 0, function* () {
        // Register HIE to check every time a text document gets opened, to
        // support multi-root workspaces.
        vscode_1.workspace.onDidOpenTextDocument((document) => __awaiter(this, void 0, void 0, function* () { return yield activateHie(context, document); }));
        vscode_1.workspace.textDocuments.forEach((document) => __awaiter(this, void 0, void 0, function* () { return yield activateHie(context, document); }));
        // Stop HIE from any workspace folders that are removed.
        vscode_1.workspace.onDidChangeWorkspaceFolders(event => {
            for (const folder of event.removed) {
                const client = clients.get(folder.uri.toString());
                if (client) {
                    clients.delete(folder.uri.toString());
                    client.stop();
                }
            }
        });
    });
}
exports.activate = activate;
function activateHie(context, document) {
    return __awaiter(this, void 0, void 0, function* () {
        // We are only interested in Haskell files.
        if ((document.languageId !== 'haskell' &&
            document.languageId !== 'cabal' &&
            document.languageId !== 'literate Haskell') ||
            (document.uri.scheme !== 'file' && document.uri.scheme !== 'untitled')) {
            return;
        }
        const uri = document.uri;
        const folder = vscode_1.workspace.getWorkspaceFolder(uri);
        // Don't handle files outside of a folder.
        if (!folder) {
            return;
        }
        // If the client already has an LSP server, then don't start a new one.
        if (clients.has(folder.uri.toString())) {
            return;
        }
        try {
            const useCustomWrapper = vscode_1.workspace.getConfiguration('languageServerHaskell', uri).useCustomHieWrapper;
            const hieExecutablePath = vscode_1.workspace.getConfiguration('languageServerHaskell', uri).hieExecutablePath;
            // Check if hie is installed.
            if (!(yield isHieInstalled()) && !useCustomWrapper && hieExecutablePath === '') {
                // TODO: Once haskell-ide-engine is on hackage/stackage, enable an option to install it via cabal/stack.
                const notInstalledMsg = 'hie executable missing, please make sure it is installed, see github.com/haskell/haskell-ide-engine.';
                const forceStart = 'Force Start';
                vscode_1.window.showErrorMessage(notInstalledMsg, forceStart).then(option => {
                    if (option === forceStart) {
                        activateHieNoCheck(context, folder, uri);
                    }
                });
            }
            else {
                activateHieNoCheck(context, folder, uri);
            }
        }
        catch (e) {
            console.error(e);
        }
    });
}
function activateHieNoCheck(context, folder, uri) {
    // Stop right here, if HIE is disabled in the resource/workspace folder.
    const enableHIE = vscode_1.workspace.getConfiguration('languageServerHaskell', uri).enableHIE;
    if (!enableHIE) {
        return;
    }
    // Set up the documentation browser.
    if (!docsBrowserRegistered) {
        const docsDisposable = docsBrowser_1.DocsBrowser.registerDocsBrowser();
        context.subscriptions.push(docsDisposable);
        docsBrowserRegistered = true;
    }
    const useCustomWrapper = vscode_1.workspace.getConfiguration('languageServerHaskell', uri).useCustomHieWrapper;
    let hieExecutablePath = vscode_1.workspace.getConfiguration('languageServerHaskell', uri).hieExecutablePath;
    let customWrapperPath = vscode_1.workspace.getConfiguration('languageServerHaskell', uri).useCustomHieWrapperPath;
    const logLevel = vscode_1.workspace.getConfiguration('languageServerHaskell', uri).trace.server;
    // Substitute path variables with their corresponding locations.
    if (useCustomWrapper) {
        customWrapperPath = customWrapperPath
            .replace('${workspaceFolder}', folder.uri.path)
            .replace('${workspaceRoot}', folder.uri.path)
            .replace('${HOME}', os.homedir)
            .replace('${home}', os.homedir)
            .replace(/^~/, os.homedir);
    }
    else if (hieExecutablePath !== '') {
        hieExecutablePath = hieExecutablePath
            .replace('${workspaceFolder}', folder.uri.path)
            .replace('${workspaceRoot}', folder.uri.path)
            .replace('${HOME}', os.homedir)
            .replace('${home}', os.homedir)
            .replace(/^~/, os.homedir);
    }
    // Set the executable, based on the settings. The order goes: First
    // check useCustomWrapper, then check hieExecutablePath, else retain
    // original path.
    let hieLaunchScript = process.platform === 'win32' ? 'hie-vscode.bat' : 'hie-vscode.sh';
    if (useCustomWrapper) {
        hieLaunchScript = customWrapperPath;
    }
    else if (hieExecutablePath !== '') {
        hieLaunchScript = hieExecutablePath;
    }
    // If using a custom wrapper or specificed an executable path, the path is assumed to already
    // be absolute.
    const serverPath = useCustomWrapper || hieExecutablePath ? hieLaunchScript : context.asAbsolutePath(path.join('.', hieLaunchScript));
    const tempDir = os.tmpdir();
    const runArgs = [];
    let debugArgs = [];
    if (logLevel === 'verbose') {
        debugArgs = ['-d', '-l', path.join(tempDir, 'hie.log'), '--vomit'];
    }
    else if (logLevel === 'messages') {
        debugArgs = ['-d', '-l', path.join(tempDir, 'hie.log')];
    }
    if (!useCustomWrapper && hieExecutablePath !== '') {
        runArgs.unshift('--lsp');
        debugArgs.unshift('--lsp');
    }
    // If the extension is launched in debug mode then the debug server options are used,
    // otherwise the run options are used.
    const serverOptions = {
        run: { command: serverPath, transport: vscode_languageclient_1.TransportKind.stdio, args: runArgs },
        debug: { command: serverPath, transport: vscode_languageclient_1.TransportKind.stdio, args: debugArgs }
    };
    // Set a unique name per workspace folder (useful for multi-root workspaces).
    const langName = 'Haskell HIE (' + folder.name + ')';
    const outputChannel = vscode_1.window.createOutputChannel(langName);
    const clientOptions = {
        // Use the document selector to only notify the LSP on files inside the folder
        // path for the specific workspace.
        documentSelector: [
            { scheme: 'file', language: 'haskell', pattern: `${folder.uri.fsPath}/**/*` },
            { scheme: 'file', language: 'literate haskell', pattern: `${folder.uri.fsPath}/**/*` }
        ],
        synchronize: {
            // Synchronize the setting section 'languageServerHaskell' to the server.
            configurationSection: 'languageServerHaskell',
            // Notify the server about file changes to '.clientrc files contain in the workspace.
            fileEvents: vscode_1.workspace.createFileSystemWatcher('**/.clientrc')
        },
        diagnosticCollectionName: langName,
        revealOutputChannelOn: vscode_languageclient_1.RevealOutputChannelOn.Never,
        outputChannel,
        outputChannelName: langName,
        middleware: {
            provideHover: docsBrowser_1.DocsBrowser.hoverLinksMiddlewareHook
        },
        // Set the current working directory, for HIE, to be the workspace folder.
        workspaceFolder: folder
    };
    // Create the LSP client.
    const langClient = new vscode_languageclient_1.LanguageClient(langName, langName, serverOptions, clientOptions, true);
    // Register ClientCapabilities for stuff like window/progress
    langClient.registerProposedFeatures();
    if (vscode_1.workspace.getConfiguration('languageServerHaskell', uri).showTypeForSelection.onHover) {
        context.subscriptions.push(showType_1.ShowTypeHover.registerTypeHover(clients));
    }
    // Register editor commands for HIE, but only register the commands once.
    if (!hieCommandsRegistered) {
        context.subscriptions.push(insertType_1.InsertType.registerCommand(clients));
        const showTypeCmd = showType_1.ShowTypeCommand.registerCommand(clients);
        if (showTypeCmd !== null) {
            showTypeCmd.forEach(x => context.subscriptions.push(x));
        }
        context.subscriptions.push(importIdentifier_1.ImportIdentifier.registerCommand());
        registerHiePointCommand('hie.commands.demoteDef', 'hare:demote', context);
        registerHiePointCommand('hie.commands.liftOneLevel', 'hare:liftonelevel', context);
        registerHiePointCommand('hie.commands.liftTopLevel', 'hare:lifttotoplevel', context);
        registerHiePointCommand('hie.commands.deleteDef', 'hare:deletedef', context);
        registerHiePointCommand('hie.commands.genApplicative', 'hare:genapplicative', context);
        registerHiePointCommand('hie.commands.caseSplit', 'ghcmod:casesplit', context);
        hieCommandsRegistered = true;
    }
    // If the client already has an LSP server, then don't start a new one.
    // We check this again, as there may be multiple parallel requests.
    if (clients.has(folder.uri.toString())) {
        return;
    }
    // Finally start the client and add it to the list of clients.
    langClient.start();
    clients.set(folder.uri.toString(), langClient);
}
/*
 * Deactivate each of the LSP servers.
 */
function deactivate() {
    const promises = [];
    for (const client of clients.values()) {
        promises.push(client.stop());
    }
    return Promise.all(promises).then(() => undefined);
}
exports.deactivate = deactivate;
/*
 * Check if HIE is installed.
 */
function isHieInstalled() {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => {
            const cmd = process.platform === 'win32' ? 'where hie' : 'which hie';
            child_process.exec(cmd, (error, stdout, stderr) => resolve(!error));
        });
    });
}
/*
 * Create an editor command that calls an action on the active LSP server.
 */
function registerHiePointCommand(name, command, context) {
    return __awaiter(this, void 0, void 0, function* () {
        const editorCmd = vscode_1.commands.registerTextEditorCommand(name, (editor, edit) => {
            const cmd = {
                command,
                arguments: [
                    {
                        file: editor.document.uri.toString(),
                        pos: editor.selections[0].active
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
                    client.sendRequest('workspace/executeCommand', cmd).then(hints => {
                        return true;
                    }, e => {
                        console.error(e);
                    });
                }
            }
        });
        context.subscriptions.push(editorCmd);
    });
}
//# sourceMappingURL=extension.js.map
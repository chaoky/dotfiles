"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path_1 = require("path");
const vscode_1 = require("vscode");
var DocsBrowser;
(function (DocsBrowser) {
    'use strict';
    // registers the browser in VSCode infrastructure
    function registerDocsBrowser() {
        return vscode_1.commands.registerCommand('haskell.showDocumentation', ({ title, path }) => {
            const uri = vscode_1.Uri.parse(path).with({ scheme: 'vscode-resource' });
            const arr = uri.path.match(/([^\/]+)\.[^.]+$/);
            const ttl = arr !== null && arr.length === 2 ? arr[1].replace(/-/gi, '.') : title;
            const documentationDirectory = path_1.dirname(uri.path);
            let panel;
            try {
                panel = vscode_1.window.createWebviewPanel('haskell.showDocumentationPanel', ttl, vscode_1.ViewColumn.Two, {
                    localResourceRoots: [vscode_1.Uri.file(documentationDirectory)],
                    enableFindWidget: true
                });
                // tslint:disable-next-line:max-line-length
                panel.webview.html = `<iframe src="${uri}" frameBorder="0" style="background: white; width: 100%; height: 100%; position:absolute; left: 0; right: 0; bottom: 0; top: 0px;" />`;
            }
            catch (e) {
                vscode_1.window.showErrorMessage(e);
            }
            return panel;
        });
    }
    DocsBrowser.registerDocsBrowser = registerDocsBrowser;
    function hoverLinksMiddlewareHook(document, position, token, next) {
        const res = next(document, position, token);
        return Promise.resolve(res).then(r => {
            if (r !== null && r !== undefined) {
                r.contents = r.contents.map(processLink);
            }
            return r;
        });
    }
    DocsBrowser.hoverLinksMiddlewareHook = hoverLinksMiddlewareHook;
    function processLink(ms) {
        function transform(s) {
            return s.replace(/\[(.+)\]\((file:.+\/doc\/.+\.html#?.+)\)/gi, (all, title, path) => {
                const encoded = encodeURIComponent(JSON.stringify({ title, path }));
                const cmd = 'command:haskell.showDocumentation?' + encoded;
                return `[${title}](${cmd})`;
            });
        }
        if (typeof ms === 'string') {
            const mstr = new vscode_1.MarkdownString(transform(ms));
            mstr.isTrusted = true;
            return mstr;
        }
        else if (typeof ms === 'object') {
            const mstr = new vscode_1.MarkdownString(transform(ms.value));
            mstr.isTrusted = true;
            return mstr;
        }
        else {
            return ms;
        }
    }
})(DocsBrowser = exports.DocsBrowser || (exports.DocsBrowser = {}));
//# sourceMappingURL=docsBrowser.js.map
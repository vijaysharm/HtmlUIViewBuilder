//
//  WebViewCoordinator.swift
//  HtmlUIViewBuilder
//

import WebKit
import SwiftUI

class WebViewCoordinator: NSObject {
    private let view: WebView
    
    init(view: WebView) {
        self.view = view
        super.init()
    }
    
    func make() -> WKWebView {
        let script = """
function notify(object) {
    if (
        webkit &&
        webkit.messageHandlers &&
        webkit.messageHandlers.bridge &&
        webkit.messageHandlers.bridge.postMessage
    ) {
        webkit.messageHandlers.bridge.postMessage(JSON.stringify(object));
    }
}
(function() {
 notify("hello world");
})();
"""
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "bridge")
        configuration.userContentController.addUserScript(
            WKUserScript(
                source: script,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        #if os(macOS)
        webView.setValue(false, forKey: "drawsBackground")
        #elseif os(iOS)
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        #endif
        
        webView.navigationDelegate = self
        
        return webView
    }
    
    func update(view: WKWebView, html: String) {
        view.loadHTMLString(html, baseURL: nil)
    }
}

extension WebViewCoordinator: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }
}

extension WebViewCoordinator: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {}
}

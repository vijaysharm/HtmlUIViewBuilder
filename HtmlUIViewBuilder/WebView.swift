//
//  WebView.swift
//  HtmlUIViewBuilder
//

import SwiftUI
import WebKit

#if os(iOS)
private typealias ViewRepresentable = UIViewRepresentable
#elseif os(macOS)
private typealias ViewRepresentable = NSViewRepresentable
#endif

struct WebView: ViewRepresentable {
    public let html: String
#if os(iOS)
    func makeUIView(context: Context) -> WKWebView {
        return makeView(context: context)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        updateView(view: uiView, context: context)
    }
#elseif os(macOS)
    func makeNSView(context: Context) -> WKWebView {
        return makeView(context: context)
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        updateView(view: nsView, context: context)
    }
#endif

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(view: self)
    }

    private func makeView(context: Context) -> WKWebView {
        context.coordinator.make()
    }
    
    private func updateView(view: WKWebView, context: Context) {
        context.coordinator.update(view: view, html: html)
    }
}

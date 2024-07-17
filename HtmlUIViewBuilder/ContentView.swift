//
//  ContentView.swift
//  HtmlUIViewBuilder
//

import SwiftUI
import CodeEditSourceEditor
import SwiftSoup

enum Tab: String, CaseIterable {
    case webview = "globe"
    case swift = "swift"
}

struct ContentView: View {
    @State var curosrPosition: [CursorPosition] = []
    @State var tab: Tab = .webview
    @State var swift: String = ""
    @State var html = """
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body>
        <div>Hello <span>World</span></div>
    </body>
</html>
"""

    var body: some View {
        ZStack {
            HSplitView {
                CodeEditSourceEditor(
                    $html,
                    language: .html,
                    theme: .dusk,
                    font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular),
                    tabWidth: 4,
                    lineHeight: 1,
                    wrapLines: false,
                    cursorPositions: $curosrPosition
                )
                
                TabView(selection: $tab) {
                    WebView(
                        html: html
                    )
                    .tabItem {
                        Label("Web View", systemImage: Tab.webview.rawValue)
                    }
                    .tag(Tab.webview)
                    WebView(
                        html: """
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="background: white">
        <pre>
\(swift)
        </pre>
    </body>
</html>
"""
                    )
                    .tabItem {
                        Label("HtmlUI", systemImage: Tab.swift.rawValue)
                    }
                    .tag(Tab.swift)
                }
            }
        }
        .onAppear {
            convert(html: html)
        }
        .onChange(of: html) {
            convert(html: html)
        }
    }
    
    public func convert(html: String) {
        guard let document = try? SwiftSoup.parse(html) else { return }
        swift = process(node: document)
    }
    
    @discardableResult
    private func process(node: Element, indent: Int = 0) -> String {
        let tab = "    "
        let spacing = String(repeating: tab, count: indent)
        if "#root" == node.tagName() {
            let children = node.children().map { process(node: $0, indent: indent) }.joined(separator: "\n")
            return "\(children)"
        }

        let tag = decorate(node: node, spacing: spacing)
        if "meta" == node.tagName() {
            return tag
        } else if "title" == node.tagName() {
            return tag
        } else if "script" == node.tagName() {
            return tag
        }
        
        let text = node.ownText().trimmingCharacters(in: .whitespacesAndNewlines)
        let children = node.children().map { process(node: $0, indent: indent + 1) }.joined(separator: "\n")
        var result = "\(tag) {"
        if !text.isEmpty {
            result = "\(result)\n\(spacing)\(tab)\"\(text)\""
        }
        if children.isEmpty {
            if text.isEmpty {
                result = "\(result)}"
            } else {
                result = "\(result)\n\(spacing)}"
            }
        } else {
            result = "\(result)\n\(children)\n\(spacing)}"
        }
        
        return result
    }
    
    private func decorate(node: Element, spacing: String) -> String {
        let tag = node.tagName()
        if "meta" == tag {
            var args = ""
            if
                node.hasAttr("name"),
                let name = try? node.attr("name"),
                node.hasAttr("content"),
                let content = try? node.attr("content") {
                args = "name: \"\(name)\", content: \"\(content)\""
            } else if node.hasAttr("charset"), let charset = try? node.attr("charset") {
                args = "charset: \"\(charset)\""
            }
            return "\(spacing)\(tag)(\(args))"
        } else if "title" == tag {
            return "\(spacing)\(tag)(\"\(node.ownText().trimmingCharacters(in: .whitespacesAndNewlines))\")"
        } else if "script" == tag {
            var args = ""
            if node.hasAttr("src"), let script = try? node.attr("src") {
                args = "src: \"\(script)\""
            }
            return "\(spacing)\(tag)(\(args))"
        }
        
        let classes = try? node.classNames().joined(separator: " ")
        var result = "\(spacing)\(tag)"
        if let classes = classes, !classes.isEmpty {
            result = "\(result)(class: \"\(classes)\")"
        }
        
        return "\(result)"
    }
}

extension EditorTheme {
    public static let solarizeDark = EditorTheme(
        text: .init(hex: "839496"),
        insertionPoint: .init(hex: "839496"),
        invisibles: .init(hex: "073642"),
        background: .init(hex: "002B36"),
        lineHighlight: .init(hex: "073642"),
        selection: .init(hex: "586E75"),
        keywords: .init(hex: "859900"),
        commands: .init(hex: "CB4B16"),
        types: .init(hex: "268BD2"),
        attributes: .init(hex: "6C71C4"),
        variables: .init(hex: "B58900"),
        values: .init(hex: "D33682"),
        numbers: .init(hex: "DC322F"),
        strings: .init(hex: "2AA198"),
        characters: .init(hex: "DC322F"),
        comments: .init(hex: "586E75")
    )
    
    public static let defaultDark = EditorTheme(
        text: .init(hex: "FFFFFF"),
        insertionPoint: .init(hex: "007AFF"),
        invisibles: .init(hex: "53606E"),
        background: .init(hex: "292A30"),
        lineHighlight: .init(hex: "2F3239"),
        selection: .init(hex: "646F83"),
        keywords: .init(hex: "FF7AB2"),
        commands: .init(hex: "78C2B3"),
        types: .init(hex: "6BDFFF"),
        attributes: .init(hex: "CC9768"),
        variables: .init(hex: "4EB0CC"),
        values: .init(hex: "B281EB"),
        numbers: .init(hex: "D9C97C"),
        strings: .init(hex: "FF8170"),
        characters: .init(hex: "D9C97C"),
        comments: .init(hex: "7F8C98")
    )
    
    public static let midnight = EditorTheme(
        text: .init(hex: "FFFFFF"),
        insertionPoint: .init(hex: "FFFFFF"),
        invisibles: .init(hex: "424242"),
        background: .init(hex: "000000"),
        lineHighlight: .init(hex: "232121"),
        selection: .init(hex: "5D5952"),
        keywords: .init(hex: "DE38A6"),
        commands: .init(hex: "09FA95"),
        types: .init(hex: "6BDFFF"),
        attributes: .init(hex: "3B5AAB"),
        variables: .init(hex: "4EB0CC"),
        values: .init(hex: "00B1FF"),
        numbers: .init(hex: "8B87FF"),
        strings: .init(hex: "FF4647"),
        characters: .init(hex: "8B87FF"),
        comments: .init(hex: "4BD157")
    )
    
    public static let classicDark = EditorTheme(
        text: .init(hex: "FFFFFF"),
        insertionPoint: .init(hex: "FFFFFF"),
        invisibles: .init(hex: "53606E"),
        background: .init(hex: "292A30"),
        lineHighlight: .init(hex: "2F3239"),
        selection: .init(hex: "646F83"),
        keywords: .init(hex: "FF7AB2"),
        commands: .init(hex: "78C2B3"),
        types: .init(hex: "6BDFFF"),
        attributes: .init(hex: "CC9768"),
        variables: .init(hex: "4EB0CC"),
        values: .init(hex: "B281EB"),
        numbers: .init(hex: "D9C97C"),
        strings: .init(hex: "FF8170"),
        characters: .init(hex: "D9C97C"),
        comments: .init(hex: "84B360")
    )
    
    public static let presentationDark = EditorTheme(
        text: .init(hex: "FFFFFF"),
        insertionPoint: .init(hex: "007AFF"),
        invisibles: .init(hex: "5F5F5F"),
        background: .init(hex: "202025"),
        lineHighlight: .init(hex: "444551"),
        selection: .init(hex: "646F83"),
        keywords: .init(hex: "F7439D"),
        commands: .init(hex: "64D7C0"),
        types: .init(hex: "75E1FF"),
        attributes: .init(hex: "E7AD78"),
        variables: .init(hex: "3EBDE0"),
        values: .init(hex: "BB81FF"),
        numbers: .init(hex: "FFEA80"),
        strings: .init(hex: "FF5F63"),
        characters: .init(hex: "FFEA80"),
        comments: .init(hex: "7F8C99")
    )
    
    public static let dusk = EditorTheme(
        text: .init(hex: "FFFFFF"),
        insertionPoint: .init(hex: "FFFFFF"),
        invisibles: .init(hex: "5F5F5F"),
        background: .init(hex: "282B35"),
        lineHighlight: .init(hex: "3B3B3C"),
        selection: .init(hex: "67675C"),
        keywords: .init(hex: "C2349B"),
        commands: .init(hex: "93C86A"),
        types: .init(hex: "6BDFFF"),
        attributes: .init(hex: "67878F"),
        variables: .init(hex: "4EB0CC"),
        values: .init(hex: "00AFCA"),
        numbers: .init(hex: "8B84CF"),
        strings: .init(hex: "E44448"),
        characters: .init(hex: "8B84CF"),
        comments: .init(hex: "4DBF56")
    )
}

#Preview {
    ContentView()
        .frame(
            minWidth: 700,
            maxWidth: .infinity,
            minHeight: 300,
            maxHeight: .infinity
        )
}

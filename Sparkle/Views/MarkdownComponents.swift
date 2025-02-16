import SwiftUI
import Markdown

struct MarkdownText: View {
    let content: String
    
    var body: some View {
        markdownContent
            .textSelection(.enabled)
    }
    
    private var markdownContent: some View {
        let document = Document(parsing: content)
        return MarkdownRenderer(markup: document)
    }
}

struct MarkdownRenderer: View {
    let markup: Markup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(markup.children.enumerated()), id: \.offset) { _, child in
                ElementView(element: child)
            }
        }
    }
}

struct ElementView: View {
    let element: Markup
    
    var body: some View {
        switch element {
        case let paragraph as Paragraph:
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(paragraph.children.enumerated()), id: \.offset) { _, child in
                    SwiftUI.Text(extractText(from: child))
                }
            }
            
        case let codeBlock as CodeBlock:
            VStack(alignment: .leading, spacing: 4) {
                if let language = codeBlock.language {
                    SwiftUI.Text(language)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ScrollView(.horizontal, showsIndicators: true) {
                    SwiftUI.Text(extractText(from: codeBlock))
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(8)
                        .background(Color(white: 0.1))
                        .cornerRadius(8)
                }
            }
            
        case let heading as Heading:
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(heading.children.enumerated()), id: \.offset) { _, child in
                    SwiftUI.Text(extractText(from: child))
                        .font(.system(size: headingSize(level: heading.level)))
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical, 4)
            
        case let list as ListItem:
            HStack(alignment: .top, spacing: 8) {
                SwiftUI.Text("•")
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(list.children.enumerated()), id: \.offset) { _, child in
                        SwiftUI.Text(extractText(from: child))
                    }
                }
            }
            .padding(.leading)
            
        default:
            SwiftUI.Text(extractText(from: element))
        }
    }
    
    private func extractText(from markup: Markup) -> String {
        switch markup {
        case let text as Markdown.Text:
            return text.string
        case let code as CodeBlock:
            return code.code
        default:
            var result = ""
            for child in markup.children {
                result += extractText(from: child)
            }
            return result
        }
    }
    
    private func headingSize(level: Int) -> CGFloat {
        switch level {
        case 1: return 24
        case 2: return 20
        case 3: return 18
        default: return 16
        }
    }
}

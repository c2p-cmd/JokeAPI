//
//  GifImage.swift
//  Ex
//
//  Created by Sharan Thakur on 01/08/23.
//

import SwiftUI
import WebKit

struct GifImage: UIViewRepresentable {
    private let name: String
    private let frame: CGSize?
    private var scrollable: Bool
    
    init(name: String, scrollable: Bool = false, in frame: CGSize? = nil) {
        self.name = name
        self.frame = frame
        self.scrollable = scrollable
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let url = Bundle.main.url(forResource: self.name, withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        
        if let frame {
            webView.frame = CGRect(origin: .zero, size: frame)
        }
        webView.scrollView.isScrollEnabled = self.scrollable
        
        webView.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: url.deletingLastPathComponent()
        )
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
        uiView.scrollView.isScrollEnabled = self.scrollable
    }
}

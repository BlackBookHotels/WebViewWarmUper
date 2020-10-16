//
//  Created by Timur Bernikovich on 07/03/2019.
//  Copyright © 2019 Timur Bernikovich. All rights reserved.
//

import UIKit
import WebKit
import WebViewWarmUper

class WebViewController: UIViewController {
    
    private enum Resource: String {
        case rich = "apple"
        case articleWithWidgetAndCss = "sample1"
        case articleWithCss = "sample2"
    }

    let warmUp: Bool
    private var loadHTMLStart: TimeInterval = 0
    
    init(warmUp: Bool) {
        self.warmUp = warmUp
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

		let wkWebView: WKWebView
		if warmUp {
			wkWebView = WKWebViewWarmUper.shared.dequeue()
		} else {
			wkWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
		}
		wkWebView.navigationDelegate = self
		wkWebView.scrollView.isScrollEnabled = false
		wkWebView.loadHTMLString("", baseURL: nil)
        
		wkWebView.frame = view.bounds
		wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(wkWebView)
        
        let resource: Resource = .articleWithCss
        guard let path = Bundle.main.path(forResource: resource.rawValue, ofType: "html"),
            let contents = try? String(contentsOfFile: path) else {
            return
        }

        loadHTMLStart = CACurrentMediaTime()
		wkWebView.loadHTMLString(contents)
    }
    
}

protocol WebView {
    func loadHTMLString(_ string: String)
}
extension WKWebView: WebView {
    func loadHTMLString(_ string: String) {
        loadHTMLString(string, baseURL: nil)
    }
}
extension UIWebView: WebView {
    func loadHTMLString(_ string: String) {
        loadHTMLString(string, baseURL: nil)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateResult()
    }

	private func updateResult() {
        let delta = CACurrentMediaTime() - loadHTMLStart
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(format: "%.2f", delta), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}

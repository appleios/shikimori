//
// Created by Aziz L on 25.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import UIKit
import WebKit


protocol AuthViewControllerDelegate: class {

    func authViewController(_ viewController: AuthViewController, didCompleteWithAuthCode authCode: String)

}


class AuthViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var goBackItem: UIBarButtonItem!
    @IBOutlet weak var goForwardItem: UIBarButtonItem!

    static func viewController(delegate: AuthViewControllerDelegate?) -> UIViewController {
        let navigationController: UINavigationController = UIStoryboard(name: "Auth", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let viewController: AuthViewController = navigationController.viewControllers.first as! AuthViewController
        viewController.delegate = delegate
        return navigationController
    }

    let service = ServiceAccessLayer()

    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)
        webView.autoPinToSuperviewEdges()

        webView.navigationDelegate = self
        self.webView = webView

        let request = service.authRequest()
        webView.load(request)

        progressView.progress = 0
        updateNavigationItems()
    }

    @IBAction func goBack(_ sender: Any) {
        self.webView.goBack()
    }

    @IBAction func goForward(_ sender: Any) {
        self.webView.goForward()
    }

    func updateNavigationItems() {
        self.goBackItem.isEnabled = self.webView.canGoBack
        self.goForwardItem.isEnabled = self.webView.canGoForward
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let pathComponents: [String] = url.pathComponents
            if pathComponents.count > 3
                       && pathComponents[0] == "/"
                       && pathComponents[1] == "oauth"
                       && pathComponents[2] == "authorize" {

                let authCode: String = pathComponents[3]
                self.delegate?.authViewController(self, didCompleteWithAuthCode: authCode)
            }
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {

    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.progress = 0
        updateNavigationItems()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        progressView.progress = Float(webView.estimatedProgress)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.progress = 1
        updateNavigationItems()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.progress = 0
        updateNavigationItems()
    }

    // TODO implement in order to get credential for Proxy, etc
    // func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    // }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        updateNavigationItems()
    }
}

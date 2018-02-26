//
//  GameVC.swift
//  WkWebviewDemo
//
//  Created by Morshed Alam on 8/11/17.
//  Copyright © 2017 Morshed Alam. All rights reserved.
//

import UIKit
import WebKit

class GameVC: UIViewController {

    @IBOutlet weak var leftGameImageItem: UIBarButtonItem!
    
    @IBOutlet weak var leftGameTitleItem: UIBarButtonItem!
    
    @IBOutlet weak var rightCrossImageItem: UIBarButtonItem!
    
    
    var webView:WKWebView!
    var progressView: UIProgressView!
    lazy fileprivate var activityIndicator: UIActivityIndicatorView! = {
        var activityIndicator = UIActivityIndicatorView()
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.2)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicator)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[activityIndicator]-0-|", options: [], metrics: nil, views: ["activityIndicator": activityIndicator]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide]-0-[activityIndicator]-0-[bottomGuide]|", options: [], metrics: nil, views: ["activityIndicator": activityIndicator, "bottomGuide": self.bottomLayoutGuide, "topGuide": self.topLayoutGuide]))
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Game"
        addWkWebView()
        
//        self.navigationItem.hidesBackButton = true
//        let newBackButton = UIBarButtonItem(title: "🔙", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.back))
//        self.navigationItem.leftBarButtonItem = newBackButton;
        
      
       
        
        
    }
    
//    @objc func back(sender: UIBarButtonItem) {
//        if(webView.canGoBack) {
//            webView.goBack()
//            webView.reloadFromOrigin()
//
//        } else {
//            self.navigationController?.popViewController(animated:true)
//        }
//    }
    //
    //   override  var edgesForExtendedLayout: UIRectEdge {
    //        get {
    //            return UIRectEdge(rawValue: super.edgesForExtendedLayout.rawValue ^ UIRectEdge.bottom.rawValue)
    //        }
    //        set {
    //            super.edgesForExtendedLayout = newValue
    //        }
    //    }
    
    
    @IBAction func crossBtnClicked(_ sender: UIBarButtonItem) {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func addWkWebView(){
        let contentController = WKUserContentController();
        contentController.add(
            self as WKScriptMessageHandler,
            name: "iosListener"
        )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        
        webView = WKWebView(frame: .zero, configuration: config)
        self.view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        //
        //        webView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        //        webView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        //        webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        //        webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[webView]-0-|",
                                                           options: [.alignAllLeft,.alignAllRight],
                                                           metrics: nil,
                                                           views: ["webView": webView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[webView]-|",
                                                           options: [.alignAllTop,.alignAllBottom],
                                                           metrics: nil,
                                                           views: ["webView": webView]))
        
        
        
        webView.navigationDelegate = self
        let myRequest = URLRequest(url: URL(string: "http://game.gagagugu.com")!)
        webView.load(myRequest)
    }
    
    override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {return}
        switch keyPath {
        case "estimatedProgress":
            
            if let newValue = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                progressChanged(newValue)
            }
            
        case "URL": break
        //delegate?.webViewController?(self, didChangeURL: webView.url)
        case "title": break
        //delegate?.webViewController?(self, didChangeTitle: webView.title as NSString?)
        case "loading":
            if (webView.url?.absoluteString.hasPrefix("ios"))!{
                self.getJSValue()
            }
            
            if let val = change?[NSKeyValueChangeKey.newKey] as? Bool {
                if !val {
                    showLoading(false)
                    
                    //                    backForwardListChanged()
                    //                    delegate?.webViewController?(self, didFinishLoading: webView.url)
                }
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func getJSValue() {
        webView.evaluateJavaScript("getGameObject()") { (result, error) in
            if error != nil{
                print(error?.localizedDescription as Any)
            }else{
                print(result as Any)
            }
        }
        
    }
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
    }
    
    override  func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "URL")
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "loading")
    }
    
    fileprivate func progressChanged(_ newValue: NSNumber) {
        if progressView == nil {
            progressView = UIProgressView()
            progressView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(progressView)
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[progressView]-0-|", options: [], metrics: nil, views: ["progressView": progressView]))
            
            if #available(iOS 11, *) {
                progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
                progressView.heightAnchor.constraint(equalToConstant: 2).isActive = true
            } else {
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide]-0-[progressView(2)]", options: [], metrics: nil, views: ["progressView": progressView, "topGuide": self.topLayoutGuide]))
            }
            
            
        }
        
        progressView.progress = newValue.floatValue
        if progressView.progress == 1 {
            progressView.progress = 0
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.progressView.alpha = 0
            })
        } else if progressView.alpha == 0 {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.progressView.alpha = 1
            })
        }
    }
    
    
    fileprivate func showLoading(_ animate: Bool) {
        
        if animate {
            activityIndicator.startAnimating()
        } else{
            activityIndicator.stopAnimating()
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        webView.stopLoading()
    }
    
    
    fileprivate func showError(_ errorString: String?) {
        let alertView = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    
}

extension GameVC:WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showLoading(false)
        if error._code == NSURLErrorCancelled {
            return
        }
        
        showError(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showLoading(false)
        if error._code == NSURLErrorCancelled {
            return
        }
        showError(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoading(true)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(#function)
        completionHandler(.performDefaultHandling,nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(#function)
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(#function)
        decisionHandler(.allow)
    }
    
    
}
extension GameVC:WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
           print(message.body)
        
        
    }
}


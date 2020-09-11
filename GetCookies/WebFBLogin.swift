//
//  WebFBLogin.swift
//  GetCookies
//
//  Created by Dat Vu on 9/11/20.
//  Copyright © 2020 Chinh le. All rights reserved.
//
import UIKit
import WebKit


class WebFBLogin: UIViewController, WKNavigationDelegate, WKUIDelegate{
    
    @IBOutlet weak var webKit: WKWebView!
    var user: UserFB?
    
    override func viewDidLoad() {
        webKit.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webKit.configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        webKit.navigationDelegate = self
        webKit.uiDelegate = self
        
        user = UserFB()
        
        let urlString = NSString(format: NSString.init(string : "https://www.facebook.com/")) as String
        let facebookUrl = URL(string: urlString)
        var facebookLoginRequest = URLRequest.init(url: facebookUrl!)
        facebookLoginRequest.httpShouldHandleCookies = true
        
        webKit.load(facebookLoginRequest)
        
        webKit.evaluateJavaScript("navigator.userAgent") { (userAgent, error) in
            if let agent: String = userAgent as? String {
                print("user_Agent >> \(agent)")
                self.user?.userAgent = agent
            } else {
                self.user?.userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 9_0 like Mac OS X) AppleWebKit/601.1.32 (KHTML, like Gecko) Mobile/13A4254v"
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let userFB = user, !userFB.userId.isEmpty {
            if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewInformation") as? ViewController {
                vc.user = user
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let urlStr = navigationAction.request.url?.absoluteString{
            
            print("TEST >> \(urlStr)")
            
            self.user?.userId = ""
            
            if #available(iOS 11, *) {
                let dataStore = WKWebsiteDataStore.default()
                dataStore.httpCookieStore.getAllCookies({ (cookies) in
                    var cookieFB = ""
                    for cookie in cookies {
                        cookieFB += cookie.name + "=" + cookie.value + ";"
                        if cookie.name == "c_user" {
                            self.user?.userId = cookie.value
                        }
                        if cookie.name == "locale" {
                            self.user?.locale = cookie.value
                        }
                    }
                    print("cookieFB >> \(cookieFB)")
                    
                    self.user?.cookie = cookieFB
                })
            } else {
                guard let cookies = HTTPCookieStorage.shared.cookies else {
                    return
                }
                var cookieFB = ""
                for cookie in cookies {
                    cookieFB += cookie.name + "=" + cookie.value + ";"
                    if cookie.name == "c_user" {
                        self.user?.userId = cookie.value
                    }
                    if cookie.name == "locale" {
                        self.user?.locale = cookie.value
                    }
                }
                print("cookieFB >> \(cookieFB)")
                
                user?.cookie = cookieFB
            }
        }
        decisionHandler(.allow)
    }
}

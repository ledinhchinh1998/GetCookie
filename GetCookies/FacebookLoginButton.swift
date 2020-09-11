//
//  FacebookLoginButton.swift
//  DemoGetCookies
//
//  Created by Chinh le on 9/9/20.
//  Copyright © 2020 Chinh le. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import WebKit

class FacebookLoginButton: UIButton {
    private weak var responsibleViewController: UIViewController!
    var loginCompletionHandler: ((FacebookLoginButton, Result<LoginManagerLoginResult, Error>) -> Void)?
    var logoutCompletionHandler: ((FacebookLoginButton) -> Void)?
    
    private func commonSetup() {
        updateButton(isLoggedIn: (AccessToken.current != nil))
        responsibleViewController = findResponsibleViewController()
        addTarget(self, action: #selector(touchUpInside(sender:)), for: .touchUpInside)
    }
    
    func updateButton(isLoggedIn: Bool) {
        let title = isLoggedIn ? "Log out" : "Log in"
        setTitle(title, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }
    
    @objc private func touchUpInside(sender: FacebookLoginButton) {
        let loginManager = LoginManager()
        
        if let _ = AccessToken.current {
            loginManager.logOut()
            let storage = HTTPCookieStorage.shared
            for cookie in storage.cookies! {
                print(cookie)
            }
            updateButton(isLoggedIn: false)
            logoutCompletionHandler?(self)
        } else {
            loginManager.logIn(permissions: [], from: responsibleViewController) { [weak self] (result , error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    if let self = self {
                        self.loginCompletionHandler?(self, .failure(error!))
                    }
                    
                    return
                }
                
                
                
                guard let result = result, !result.isCancelled else {
                    print("User Cancelled login")
                    return
                }
                
                self?.showCookies()
                
                self?.updateButton(isLoggedIn: true)
                if let self = self {
                    self.loginCompletionHandler?(self, .success(result))
                }
            }
        }
    }
    
    func showCookies() {

        let cookieStorage = HTTPCookieStorage.shared
        //println("policy: \(cookieStorage.cookieAcceptPolicy.rawValue)")

        let cookies = cookieStorage.cookies!
        print("Cookies.count: \(cookies.count)")
        for cookie in cookies {
            var cookieProperties = [HTTPCookiePropertyKey: Any]()

            cookieProperties[.name] = cookie.name
            cookieProperties[.value] = cookie.value
            cookieProperties[.domain] = cookie.domain
            cookieProperties[.path] = cookie.path
            cookieProperties[.version] = cookie.version
            cookieProperties[.expires] = cookie.expiresDate
            cookieProperties[.secure] = cookie.isSecure

            // Setting a Cookie
            if let newCookie = HTTPCookie(properties: cookieProperties) {
                // Made a copy of cookie (cookie can't be set)
                print("Newcookie: \(newCookie)")
                HTTPCookieStorage.shared.setCookie(newCookie)
            }
            print("ORGcookie: \(cookie)")
        }
    }
}

extension UIView {
    func findResponsibleViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findResponsibleViewController()
        } else {
            return nil
        }
    }
}


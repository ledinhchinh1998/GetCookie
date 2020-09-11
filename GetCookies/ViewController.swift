//
//  ViewController.swift
//  GetCookies
//
//  Created by Chinh le on 9/11/20.
//  Copyright © 2020 Chinh le. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var idFbLbl: UILabel!
    @IBOutlet weak var urlImageLbl: UILabel!
    @IBOutlet weak var ipAdressLbl: UILabel!
    @IBOutlet weak var locationAdressLbl: UILabel!
    @IBOutlet weak var userAgentLbl: UILabel!
    @IBOutlet weak var cookieLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var fbLogin: FacebookLoginButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        ipAdressLbl.text = getIpAdress() ?? ""
        fbLogin.loginCompletionHandler = { [weak self] (button, result) in
            switch result {
            case .success(let result):
                print("Access token: \(String(describing: result.token?.tokenString))")
                Profile.loadCurrentProfile { [weak self] (profile, error) in
                    self?.updateMessage(with: Profile.current?.name)
                    self?.idFbLbl.text = profile?.userID
                    if let url = profile?.imageURL(forMode: .normal, size: .zero) {
                        self?.urlImageLbl.text = url.absoluteString
                    }
                }
            case .failure(let error):
                print("Error occurred: \(error.localizedDescription)")
            }
        }
        
        fbLogin.logoutCompletionHandler = { [weak self] button in
            self?.updateMessage(with: nil)
        }
        
        getIpLocation { (dic, err) in
            if let country = dic?["country"] as? String {
                self.locationAdressLbl.text = country
            }
        }
    }
    
    @IBAction func getLocationActionn(_ sender: Any) {
        
    }
    
    func updateMessage(with name: String?) {
        guard let name = name else {
            userNameLbl.text = "Please log in with Facebook"
            return
        }
        
        userNameLbl.text = "Hello, \(name)"
    }
    
    func getIpAdress() -> String? {
        var address : String?

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
    
    func getIpLocation(completion: @escaping(NSDictionary?, Error?) -> Void) {
        if let url = URL(string: "http://ip-api.com/json") {
            let urlRequest = try! URLRequest(url: url, method: .get)
            AF.request(urlRequest).responseJSON { (response) in
                if let data = response.data {
                    do {
                        if let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                            completion(object, nil)
                        }
                    } catch {
                        completion(nil, error)
                    }
                }
            }
        }
    }
//    {
//        let url     = URL(string: "http://ip-api.com/json")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        URLSession.shared.dataTask(with: request as URLRequest, completionHandler:
//        { (data, response, error) in
//            DispatchQueue.main.async
//            {
//                if let content = data
//                {
//                    do
//                    {
//                        if let object = try JSONSerialization.jsonObject(with: content, options: .allowFragments) as? NSDictionary
//                        {
//                            completion(object, error)
//                        }
//                        else
//                        {
//                            // TODO: Create custom error.
//                            completion(nil, nil)
//                        }
//                    }
//                    catch
//                    {
//                        // TODO: Create custom error.
//                        completion(nil, nil)
//                    }
//                }
//                else
//                {
//                    completion(nil, error)
//                }
//            }
//        }).resume()
//    }
    
}


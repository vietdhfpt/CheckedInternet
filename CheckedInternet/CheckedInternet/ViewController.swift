//
//  ViewController.swift
//  CheckedInternet
//
//  Created by Do Hoang Viet on 8/14/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var reachability: Reachability?
    let hostNames = [nil, "google.com", "invalidhost"]
    var hostIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startHost(at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChangedInternet(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
    }
    
    func startHost(at index: Int) {
        stopNotifier()
        setupReachability(hostNames[index])
        startNotifier()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.startHost(at: (index + 1) % 3)
        }
    }

    func setupReachability(_ hostName: String?) {
        let reachability: Reachability?
        if let hostName = hostName {
            reachability = Reachability(hostname: hostName)
        } else {
            reachability = Reachability()
        }
        self.reachability = reachability
        
        reachability?.whenReachable = { reachability in
            self.updateLabelColourWhenReachable(reachability)
        }
        
        reachability?.whenUnreachable = { reachability in
            self.updateLabelColourWhenNotReachable(reachability)
        }
    }
    
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            DispatchQueue.main.async {
                self.view.backgroundColor = #colorLiteral(red: 1, green: 0.2987624294, blue: 0.225595141, alpha: 1)
            }
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
    
    
    func updateLabelColourWhenReachable(_ reachability: Reachability) {
        print("\(reachability.description) - \(reachability.connection)")
        if reachability.connection == .wifi {
            DispatchQueue.main.async {
                self.view.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            }
        } else {
            DispatchQueue.main.async {
                self.view.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            }
        }
        
    }
    
    func updateLabelColourWhenNotReachable(_ reachability: Reachability) {
        print("\(reachability.description) - \(reachability.connection)")
        
        DispatchQueue.main.async {
            self.view.backgroundColor = #colorLiteral(red: 1, green: 0.2987624294, blue: 0.225595141, alpha: 1)
        }
    }

    deinit {
        stopNotifier()
    }
    
    @objc func handleChangedInternet(_ notification: Notification) {
        let reachability = notification.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            print("Network not reachable")
        }
    }

}


//
//  ViewController.swift
//  NetworkManager
//
//  Created by Utsav Hitendrabhai Pandya on 14/01/26.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - IB Outlet
    @IBOutlet weak var button: UIButton!
    
    // MARK: - Global Variable
    var network : Network = Network()
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - IB Action
    
    @IBAction func onTapButton(_ sender: Any) {
        Task { @MainActor in
            
            let url = URL(string: basePath + "cities")!
            
            let request = Request(url: url, httpMethod: .GET, body: nil)
            
            await network.perform(request)
            
        }
    }
    

}


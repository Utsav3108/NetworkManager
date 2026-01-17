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
    
    var task1: Task<[Weather]?, Error>?
    var task2: Task<Weather?, Error>?
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //task1?.cancel()
    }
    
    // MARK: - IB Action
    
    @IBAction func onTapButton(_ sender: Any) {
        
        let sec = self.storyboard?.instantiateViewController(withIdentifier: "SecondVC") as! SecondVC
        
        self.navigationController?.pushViewController(sec, animated: true)
        
        task1 = Task {
            
            let url = URL(string: basePath + "secure-cities")!
            
            let request = Request(url: url, httpMethod: .GET, body: nil)
            
            let result : [Weather]? = await network.perform(request)
            print("Result: ", result ?? [])
            return result
            
        }
        
        task2 = Task {
            let url = URL(string: basePath + "cities/" + "Mumbai")!
            
            let request = Request(url: url, httpMethod: .GET, body: nil)
            
            let result : Weather? = await network.perform(request)
            
            print("Result : ", result as Any)
            
            return result
        }
    }
    

}


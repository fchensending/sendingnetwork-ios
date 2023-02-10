//
//  BaseViewController.swift
//  sendingnetwork-ios-demo
//
//  Created by ch on 2023/2/9.
//  Copyright © 2023 sending.network. All rights reserved.
//

import UIKit
import SendingnetworkSDK

class BaseViewController: UIViewController {
    
    let base_url = BaseSetting.base_url
    
    var client: MXRestClient?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let credentials = MXCredentials()
        credentials.homeServer = base_url
        credentials.userId = BaseSetting.shared.userId
        credentials.accessToken = BaseSetting.shared.access_token
        self.client = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
        setupUI()
        loadData()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        
    }
    
    func loadData() {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

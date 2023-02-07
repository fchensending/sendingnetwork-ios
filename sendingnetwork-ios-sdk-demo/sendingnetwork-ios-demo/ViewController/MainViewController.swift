//
//  MainViewController.swift
//  sendingnetwork-ios-demo
//
//  Created by chenghao on 2023/1/17.
//

import UIKit
import SendingnetworkSDK

class MainViewController: UIViewController {

    @IBOutlet weak var serverLabel: UILabel!
    
    private var serverConnect: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sendingnetwork"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startServer(_ sender: Any) {
        RadixService.shared.start()
        serverConnect = true
        self.serverLabel.text = "server start"
    }
    
    @IBAction func stopServer(_ sender: Any) {
        RadixService.shared.stop()
        serverConnect = false
        self.serverLabel.text = "server stop"
    }
    
    
    @IBAction func didLogin(_ sender: Any) {
        if serverConnect {
            self.navigationController?.pushViewController(DIDLoginViewController(), animated: true)
        } else {
            print("please open server")
        }
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

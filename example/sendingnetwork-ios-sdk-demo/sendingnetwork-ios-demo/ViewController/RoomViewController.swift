//
//  RoomViewController.swift
//  sendingnetwork-ios-demo
//
//  Created by ch on 2023/2/8.
//  Copyright © 2023 sending.network. All rights reserved.
//

import UIKit
import SendingnetworkSDK

class RoomViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupUI() {
        
    }
    
    override func loadData() {
        client?.publicRooms(onServer: nil, limit: 30) { response in
            switch response {
            case .success(let rooms):
                print("The public rooms are: \(rooms)")
            case .failure(let error):
                print("get public rooms \(error)")
            }
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

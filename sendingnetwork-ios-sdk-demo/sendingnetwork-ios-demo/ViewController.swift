//
//  ViewController.swift
//  sendingnetwork-ios-demo
//
//  Created by xyz on 2022/10/10.
//

import UIKit

import SendingnetworkSDK
import web3
//import DendriteSDK

class ViewController: UIViewController {
    var client:MXRestClient?
    var session:MXSession?
    // The dendrite server will listen on port 65432 in your app.
    var base_url = BaseSetting.base_url
    var access_token:  String = ""
    var user_id :String = ""
    var direct_room:[String:String] = [:]
    
    let wallet = "0x6F47cAf3270b14AB7242317a176ed8B69d393eBb"
    
    let credentials = MXCredentials()
    
    @IBOutlet weak var room_id: UITextField!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var token: UITextField!
    @IBOutlet weak var room_name: UITextField!
    
    @IBOutlet weak var Create_room: UIButton!
    
    @IBOutlet weak var frient_user: UITextField!
    @IBOutlet weak var say_hello: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let credentials = MXCredentials()
        credentials.homeServer = base_url
        self.client = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
    }
    
    
//    func login(privateKey: String){
//        let timestamp = Int64((NSDate().timeIntervalSince1970 * 1000.0).rounded())
//        let salt = "hiseas_account"
//        let idType = "m.id.thirdparty"
//
//        let count = 32
//        var bytes = [Int8](repeating: 0, count: count)
//
//        // Fill bytes with secure random data
//        _ =  SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
//        let nonce = bytes.map{ String(format: "%02hhx", $0) }.joined()
//
//        let keyStorage = EthereumKeyLocalStorage()
//
////        let account = try? EthereumAccount.importAccount(keyStorage: keyStorage, privateKey: privateKey, keystorePassword: "")
//        let account = try? EthereumAccount.importAccount(replacing: keyStorage, privateKey: privateKey, keystorePassword: "")
//        let address = account!.address.value
//        let message = [salt,
//                       address,
//                       nonce,
//                       String(timestamp)].joined(separator: "#")
//
//        // You can let a wallet such as MetaMask sign the message for you.
//        let sign = try? account?.signMessage(message:  Data(message.utf8))
//        let sub = String( sign![String.Index(encodedOffset: 2)...])
//        let token = hexStringToData(string:sub).base64EncodedString()
//
//        // user identifier
//        let identifier:[String:String] =  [
//            "salt": salt,
//            "publicKey": address,
//            "address":   "did:eth:mainnet:\(address)_did",
//            "nonce": nonce,
//            "token": token,
//            "type": idType,
//            "medium": "did",
//            "timestamp": String(timestamp),
//        ]
//
//        client?.login(parameters: ["identifier": identifier, "type": "m.login.did.identity"]){response in
//            switch response{
//            case .success(let data):
//                print("login successfully", data)
//
//                self.access_token =  data["access_token"] as! String
//                self.user_id = data["user_id"] as! String
////
////                let credentials = MXCredentials(homeServer: self.base_url,
////                                                userId: self.user_id,
////                                                accessToken: self.access_token)
//                self.credentials.userId = self.user_id
//                self.credentials.accessToken = self.access_token
//                // Create a client
//                self.client = MXRestClient(credentials: self.credentials, unrecognizedCertificateHandler: nil)
//
//
//                // Create a session to interact with the server and keep it throughout the app's lifetime
//                // or until the user logs out:
//                let session = MXSession(sendingnetworkRestClient: self.client)
//                self.session = session
//                self.event_dispatcher()
//                print("login successfully, user id: \(self.user_id ), access_toke: \(self.access_token)")
//                self.textfield.text = self.user_id
//                self.token.text =  self.access_token
//                return
//            case .failure(let error):
//                print(error);
//                return
//            }
//        }
//    }
    
    func event_dispatcher(){
        self.session?.start{ response in
            guard response.isSuccess else {
                print("sync envnt failed")
                return
            }
            self.session?.listenToEvents(){ event, direction, customObject in
                switch direction {
                case .forwards:
                    // Live/New events come here
                    if  event.eventId != nil{
                        switch event.wireType{
                            // Got an message from other user.
                        case kMXEventTypeStringRoomMessage:
                            let msg = event.content["body"] as! String
                            print("got message: ", msg, " from: ", event.sender!, "at time: ", event.ageLocalTs)
                            // Send a receipt, then the message won't send again.
                            self.client?.sendReadReceipt(toRoom: event.roomId, forEvent: event.eventId){ response in }
                            if event.sender != self.user_id && msg == "ping" {
                                self.client?.sendTextMessage(toRoom:event.roomId, text: "pong"){ response in
                                    switch response{
                                    case .success(let data):
                                        print("response data: ", data)
                                        break
                                    case .failure(let error):
                                        print(error);
                                    }
                                }
                            }
                            break;
                            
                            // Room event.
                        case kMXEventTypeStringRoomMember:
                            let ms = event.content["membership"] as! String
                            if  ms == "invite"{
                                // Invited by a user.
                                print("invited to room: \(event.roomId!) by user: \(event.sender!)")
                                self.join_room(room_id: event.roomId!)
                                
                            }else if ms == "join"{
                                print("join the room: ", event.roomId)
                            }
                            break;
                        default:
                            print("room event: ", event.roomId, event.eventType, event.type, event.content)
                        }
                    }else{
                        print("room event: ", event)
                    }
                    break
                    
                case .backwards:
                    print("get event backwards: ", event)
                    // Events that occurred in the past will come here when requesting pagination.
                    // roomState contains the state of the room just before this event occurred.
                    break
                }
            }
        }
    }
    
    func join_room(room_id: String){
        self.client?.joinRoom(room_id) {response in
            switch response{
            case .success(let data):
                print("join room \(room_id) succeed")
                self.client?.sendTextMessage(toRoom: room_id, text: "Hello everybody."){ response in
                    switch response{
                    case .success(let data):
                        
                        break
                    case .failure(let error):
                        print(error);
                    }
                }
                return
            case .failure(let error):
                print(error);
                return
            }
        }
    }
    
    // invite user to room.
    func invite(user_id: String,room_id: String) {
        self.client?.invite(MXRoomInvitee.userId(user_id), toRoom: room_id) { response in
            switch response{
            case .success(let data):
                print("invation sent successfully")
            case .failure(let error):
                print(error);
                return
            }
        }
    }
    
    @IBAction func say_hello_to_user(){
        let user = self.frient_user.text
        
        let room_id = self.direct_room[user!]
        
        if room_id == nil || room_id == "" {
            let params = MXRoomCreationParameters()
            params.inviteArray = [user!]
            params.isDirect = true
            params.visibility = "private"
            params.preset = "trusted_private_chat"
            let dic:[String:Any] = [
                "type": "m.room.guest_access","state_key": "",
            ]
            params.roomType = "m.room.guest_access"
            params.name = "aloha"
            params.initialStateEvents =  [ dic ]
            params.creationContent = [ "guest_access": "can_join"]
            
            self.client?.createRoom(parameters: params){ response in
                switch response{
                case .failure(let error):
                    print(error)
                    return
                case .success(let resp):
                    self.direct_room[user!] =  resp.roomId
                    self.client?.sendTextMessage(toRoom:  resp.roomId, text: "aloha"){ response in
                        switch response{
                        case .success(let data):
                            break
                        case .failure(let error):
                            print(error);
                        }
                    }
                    return
                }
            }
        }else{
            self.client?.sendTextMessage(toRoom: room_id!, text: "aloha"){ response in
                switch response{
                case .success(let data):
                    break
                case .failure(let error):
                    print(error);
                }
            }
        }
    }
    
    @IBAction func create_room(_ sender: Any) {
        let params = MXRoomCreationParameters()
        params.name = self.room_name.text
        params.roomAlias = self.room_name.text
        
        client?.createRoom(parameters: params) { response in
            switch response{
            case .failure(let error):
                print(error)
                return
            case .success(let resp):
                let room_id = resp.roomId
                self.room_id.text = room_id
                return
            }
        }
    }
    
    func hexStringToData(string: String) -> Data {
        let stringArray = Array(string)
        var data: Data = Data()
        for i in stride(from: 0, to: string.count, by: 2) {
            let pair: String = String(stringArray[i]) + String(stringArray[i+1])
            if let byteNum = UInt8(pair, radix: 16) {
                let byte = Data([byteNum])
                data.append(byte)
            }
            else{
                fatalError()
            }
        }
        return data
    }
    
    @IBAction func didList(_ sender: Any) {
        client?.getDIDList(wallet, success: { response in
            guard let response = response else {
                return
            }
            guard let list = response.array else {
                print("didListCount: 0")
                return
            }
            print("didListCount: \(list.count)")
        }, failure: { error in
            print("didListCount: \(error.debugDescription)")
        })
    }
    
}

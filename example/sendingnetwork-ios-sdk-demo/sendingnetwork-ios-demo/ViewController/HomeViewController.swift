//
//  HomeViewController.swift
//  sendingnetwork-ios-demo
//
//  Created by ch on 2023/2/9.
//  Copyright © 2023 sending.network. All rights reserved.
//

import UIKit
import SendingnetworkSDK

class HomeViewController: BaseViewController {
    
    var session:MXSession?
    
    var roomId = "!OaPIAaS9Y4LeGLM7-@sdn_6f47caf3270b14ab7242317a176ed8b69d393ebb:6f47caf3270b14ab7242317a176ed8b69d393ebb"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        self.session = MXSession(sendingnetworkRestClient: self.client)
        event_dispatcher()
        // Do any additional setup after loading the view.
    }
    
    override func setupUI() {
        self.view.addSubview(userIdLabel)
        self.view.addSubview(accessTokenLabel)
        userIdLabel.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        
        accessTokenLabel.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(userIdLabel.snp.bottom).offset(15)
        }
        
        self.view.addSubview(roomNameLabel)
        roomNameLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(accessTokenLabel.snp.bottom).offset(15)
            make.height.equalTo(30)
        }
        
        self.view.addSubview(roomNameTextField)
        roomNameTextField.snp.makeConstraints { make in
            make.left.equalTo(roomNameLabel.snp.right).offset(5)
            make.top.equalTo(roomNameLabel.snp.top)
            make.height.equalTo(30)
            make.width.equalTo(150)
        }
        
        self.view.addSubview(createRoomBtn)
        createRoomBtn.snp.makeConstraints { make in
            make.left.equalTo(roomNameTextField.snp.right).offset(5)
            make.top.equalTo(roomNameLabel.snp.top)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        self.view.addSubview(roomIdLabel)
        roomIdLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(roomNameLabel.snp.bottom).offset(15)
        }
        
        self.view.addSubview(messageTextField)
        self.view.addSubview(sendMessageBtn)
        messageTextField.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(roomIdLabel.snp.bottom).offset(15)
            make.right.equalTo(-200)
            make.height.equalTo(30)
        }
        sendMessageBtn.snp.makeConstraints { make in
            make.left.equalTo(messageTextField.snp.right).offset(5)
            make.top.equalTo(messageTextField.snp.top)
            make.right.equalTo(-5)
            make.height.equalTo(30)
        }
        
    }
    
    private lazy var userIdLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .pingFangSCFont(ofSize: 16)
        label.text = "user_id:\(BaseSetting.shared.userId ?? "")"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var accessTokenLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .pingFangSCFont(ofSize: 16)
        label.text = "access_token:\(BaseSetting.shared.access_token ?? "")"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var roomNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "roomName"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var roomNameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    private lazy var createRoomBtn: CHCorButton = {
        let button = CHCorButton()
        button.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        button.setTitle("createRoom", for: .normal)
        return button
    }()
    
    private lazy var roomIdLabel: UILabel = {
        let label = UILabel()
        label.text = "roomID:\(roomId)"
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    private lazy var sendMessageBtn: CHCorButton = {
        let button = CHCorButton()
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        button.setTitle("sendMessage", for: .normal)
        return button
    }()
    
    @objc func createRoom() {
        let params = MXRoomCreationParameters()
        params.inviteArray = ["@sdn_04d3271c15cd3befaa4eeedaea7737aecb48c6c4:04d3271c15cd3befaa4eeedaea7737aecb48c6c4"]
        params.isDirect = true
        params.visibility = kMXRoomDirectoryVisibilityPrivate
        params.preset = kMXRoomPresetTrustedPrivateChat
        let dic:[String:Any] = [
            "type": "m.room.guest_access","state_key": "",
        ]
        params.roomType = "m.room.guest_access"
        params.name = self.roomNameTextField.text
        params.roomAlias = self.roomNameTextField.text
        params.initialStateEvents =  [dic]
        params.creationContent = [ "guest_access": "can_join"]
        
        client?.createRoom(parameters: params) { [weak self] response in
            guard let self = self else { return }
            switch response{
            case .failure(let error):
                print(error)
                HUD.showImage(text: "create fail",delay: 2,status: .error)
                return
            case .success(let resp):
                let room_id = resp.roomId
                self.roomId = room_id!
                self.roomIdLabel.text = "roomID:\(self.roomId)"
                HUD.showImage(text: "create success",delay: 2,status: .success)
                return
            }
        }
    }
    
    @objc func sendMessage() {
        self.client?.sendTextMessage(toRoom:self.roomId, text: self.messageTextField.text!){ response in
            switch response{
            case .success(let data):
                print("response data: ", data)
                break
            case .failure(let error):
                print(error);
            }
        }
    }
    
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
                            if event.sender != BaseSetting.shared.userId && msg == "ping" {
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
    
    override func loadData() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        roomNameTextField.resignFirstResponder()
        messageTextField.resignFirstResponder()
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

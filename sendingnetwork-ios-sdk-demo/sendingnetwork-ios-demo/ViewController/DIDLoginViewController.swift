//
//  DIDLoginViewController.swift
//  sendingnetwork-ios-demo
//
//  Created by chenghao on 2023/1/17.
//

import UIKit
import SendingnetworkSDK
import SnapKit
import web3

class DIDLoginViewController: UIViewController {
    
    
    let base_url = BaseSetting.base_url
    //Your privateKey
    let privateKey = "6f2e978b08db57348dacfdf48ddaee7586b95331e0db070472bbc16a3981887e"
    
    var walletAddress = "0x6F47cAf3270b14AB7242317a176ed8B69d393eBb"
    
    var did: String?
        
    private var client: MXRestClient?
    
    private var listResponse: MXDIDListResponse?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DID"
        self.view.backgroundColor = .white
        let credentials = MXCredentials()
        credentials.homeServer = base_url
        self.client = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        view.addSubview(addressTextField)
        view.addSubview(randAddressButton)
        view.addSubview(didListButton)
        
        addressTextField.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-60)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.height.equalTo(44)
        }
        
        randAddressButton.snp.makeConstraints { make in
            make.left.equalTo(addressTextField.snp.right)
            make.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(addressTextField.snp.centerY)
        }
        
        didListButton.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
            make.top.equalTo(addressTextField.snp.bottom).offset(15)
        }
        
        view.addSubview(actionView)
        actionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(didListButton.snp.bottom).offset(15)
            make.height.equalTo(45)
        }
        
        actionView.addSubview(createDid)
        createDid.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(15)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(actionView.snp.bottom).offset(15)
            make.bottom.equalTo(-CGFloat.safeAreaBottom)
        }
        

    }
    
    private lazy var addressTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "walletAddress"
        return textField
    }()
    
    private lazy var randAddressButton: CHButton = {
        let button = CHButton()
        button.setTitle("address", for: .normal)
        button.addTarget(self, action: #selector(randomAddress), for: .touchUpInside)
        return button
    }()
    
    private lazy var didListButton: CHBigButton = {
        let button = CHBigButton()
        button.setTitle("DID list", for: .normal)
        button.addTarget(self, action: #selector(DIDList), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DIDTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var actionView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var createDid: CHButton = {
        let button = CHButton()
        button.setTitle("create_DID", for: .normal)
        button.addTarget(self, action: #selector(createDID), for: .touchUpInside)
        return button
    }()
    
    private lazy var didTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "did"
        return textField
    }()
    
    private lazy var didLogin: CHButton = {
        let button = CHButton()
        button.setTitle("login_DID", for: .normal)
        button.addTarget(self, action: #selector(pre_login), for: .touchUpInside)
        return button
    }()
    
    @objc func randomAddress() {
        self.addressTextField.text = "0x6F47cAf3270b14AB7242317a176ed8B69d393eBb"
    }
    
    
    @objc func DIDList() {
//        let destUrl:URL = URL(string: "\(BaseSetting.base_url)/_api/client/unstable/address/\(walletAddress)")!
//        let session = URLSession.shared
//        var request = URLRequest(url: destUrl)
//        request.httpMethod = "GET"
//        let task: URLSessionDataTask = session.dataTask(with: request) {[weak self] data, response, error in
//            guard let self = self else { return }
//            guard error == nil, let data:Data = data, let httpResponse :HTTPURLResponse = response as? HTTPURLResponse else {
//                return
//            }
////            let data = try?JSONSerialization.data(withJSONObject: json, options: [])
//            let jsonString = String(data: data, encoding: String.Encoding.utf8)
//            if httpResponse.statusCode != 200 {
//                return
//            }
//            print(response)
//            print(jsonString)
//
//        }
//        task.resume()
        
        
        guard let walletAddress = self.addressTextField.text else { return }
        if walletAddress.isEmpty {
            print("walletAddres could not null")
        }
        client?.getDIDList(walletAddress, success: { [weak self]  response in
            guard let self = self else { return }
            guard let response = response else { return }
            self.listResponse = response
//            if self.listResponse?.array.count > 0 {
//                self.tableView.isHidden = false
//            } else {
//                self.tableView.isHidden = true
//            }
            self.tableView.reloadData()
            print("didListCount: \(self.listResponse?.array.count)")
        }, failure: { error in
            print("didListCount: \(error.debugDescription)")
        })
    }
    
    @objc func createDID() {
        guard let walletAddress = self.addressTextField.text else { return }
        if walletAddress.isEmpty {
            print("walletAddres could not null")
        }
        client?.postCreateDID("did:pkh:eip155:1:\(walletAddress)", success: { [weak self] response in
            guard let self = self else { return }
            guard let response = response else { return }
            guard let message = response.message, let did = response.did, let updateTime = response.updated else { return }
            print("create DID success")
            debugPrint("create did response: message-\(message),did-\(did),updateTime-\(updateTime)")
            self.did = did
            let signin = self.signinMessage(message: message)
            self.saveDID(did: did, params: ["signature":signin,"updated":updateTime,"operation":"create","address":"did:pkh:eip155:1:\(walletAddress)"])
        }, failure: { error in
            print("create DID fail")
        })
    }
    
    func saveDID(did: String,params: [String:String]) {
        debugPrint("save did: did-\(did),params-\(params)")
        client?.postSaveDID(did, withParameter: params, success: {[weak self] response in
            guard let self = self else { return }
            guard let response = response else { return }
            print("save success\(response.message ?? "")")
            self.pre_loginDID(did: did)
        }, failure: { error in
            print("save fail\(error.debugDescription)")
        })
    }
    
    @objc func pre_login() {
        guard let did = self.didTextField.text else {
            return
        }
//        if did.isEmpty {
//            did =
//        }
    }
    
    func pre_loginDID(did: String) {
        client?.postPreLoginDID(did, success: {[weak self] response in
            guard let self = self else { return }
            guard let response = response else { return }
            guard let message = response.message, let did = response.did, let updateTime = response.updated else { return }
            print("pre_log success")
            let token = self.signinMessage(message: message)
            self.loginWithDID(identifier: ["did":did,"token":token], updateTime: updateTime)
        }, failure: { error in
            print("pre_log faile\(error.debugDescription)")
        })
    }
    
    func loginWithDID(identifier: [String: String], updateTime: String) {
        client?.postLoginDID(did, withParameter: ["type":"m.login.did.identity","updated":updateTime,"identifier":identifier], success: { response in
            guard let response = response else { return }
            print("login successfully, user id: \(response.userId), access_toke: \(response.accessToken)")
        }, failure: { error in
            print("login_did_error\(error.debugDescription)")
        })
    }
    
    func signinMessage(message: String) -> String {
        let keyStorage = EthereumKeyLocalStorage()
        let account = try? EthereumAccount.importAccount(replacing: keyStorage, privateKey: privateKey, keystorePassword: "")
        let sign = try? account?.signMessage(message:  Data(message.utf8))
        return sign!
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DIDLoginViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listResponse?.array?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DIDTableViewCell else {
            fatalError("Fail to dequeue a cell with identifier")
        }
        let didString = self.listResponse?.array?[indexPath.row] ?? ""
        cell.didLabel.text = didString
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    
}

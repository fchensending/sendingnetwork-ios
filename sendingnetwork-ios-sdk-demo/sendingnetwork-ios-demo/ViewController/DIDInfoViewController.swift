//
//  DIDInfoViewController.swift
//  sendingnetwork-ios-demo
//
//  Created by chenghao on 2023/2/8.
//

import UIKit
import SendingnetworkSDK

class DIDInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DID Info"
        self.view.backgroundColor = .white
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        self.view.addSubview(didLabel)
        didLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
        }
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(didLabel.snp.bottom)
            make.bottom.equalTo(-CGFloat.safeAreaBottom)
        }
        
    }
    
    private lazy var didLabel: UILabel = {
        let label = UILabel()
        label.text = "DID"
        label.font = .pingFangSCFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DIDTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 60
        return tableView
    }()
    
    var didString: String? {
        didSet {
            self.didLabel.text = "DID:\(didString ?? "")"
        }
    }
    
    
    
    var didInfo: MXDIDListInfoResponse? {
        didSet {
            guard let didInfo = didInfo else { return }
            
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

extension DIDInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (didInfo?.controllers.count ?? 0) + (didInfo?.publicKeys.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DIDTableViewCell else {
            fatalError("Fail to dequeue a cell with identifier")
        }
        if indexPath.section == 0 {
            cell.didLabel.text = "public key : \(didInfo?.publicKey ?? "")"
        } else {
            if indexPath.section <= didInfo?.controllers.count { // controllers
                switch indexPath.row {
                case 0:
                    cell.didLabel.text = "raw: \(didInfo?.controllers![indexPath.section - 1].raw ?? "")"
                case 1:
                    cell.didLabel.text = "keyId: \(didInfo?.controllers![indexPath.section - 1].keyId ?? "")"
                case 2:
                    cell.didLabel.text = "value: \(didInfo?.controllers![indexPath.section - 1].value ?? "")"
                case 3:
                    cell.didLabel.text = "type: \(didInfo?.controllers![indexPath.section - 1].type ?? "")"
                default:
                    break
                }
            } else { // publicKeys
                switch indexPath.row {
                case 0:
                    cell.didLabel.text = "raw: \(didInfo?.publicKeys![indexPath.section - 1 - (didInfo?.controllers.count)!].raw ?? "")"
                case 1:
                    cell.didLabel.text = "keyId: \(didInfo?.publicKeys![indexPath.section - 1 - (didInfo?.controllers.count)!].keyId ?? "")"
                case 2:
                    cell.didLabel.text = "value: \(didInfo?.publicKeys![indexPath.section - 1 - (didInfo?.controllers.count)!].value ?? "")"
                case 3:
                    cell.didLabel.text = "type: \(didInfo?.publicKeys![indexPath.section - 1 - (didInfo?.controllers.count)!].type ?? "")"
                default:
                    break
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = .black
        label.font = .pingFangSCFont(ofSize: 16,weight: .bold)
        if section == 0 {
            label.text = "PublicKey"
        } else {
            if section <= didInfo?.controllers.count { // controllers
                label.text = "Controllers-\(section - 1)"
            } else { // publicKeys
                label.text = "PublicKeys-\(section - 1 - (didInfo?.controllers.count)!)"
            }
        }
        label.backgroundColor = .white
        return label
    }
    
    
}

//
//  MineViewController.swift
//  sendingnetwork-ios-demo
//
//  Created by ch on 2023/2/8.
//  Copyright © 2023 sending.network. All rights reserved.
//

import UIKit
import Kingfisher

class MineViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .pingFangSCFont(ofSize: 16,weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    override func setupUI() {
        self.view.addSubview(userImageView)
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.left.equalTo(30)
            make.width.height.equalTo(60)
        }
        
        view.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.left.equalTo(userImageView.snp.right).offset(15)
            make.top.equalTo(userImageView.snp.top).offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        
    }
    
    override func loadData() {
        guard let user_id = BaseSetting.shared.userId else {
            debugPrint("user_id could not null")
            return
        }
        client?.profile(forUser: user_id, completion: { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success((let displayName,let avatarUrl)):
                debugPrint("didPlayName:\(displayName ?? ""),avatarUrl:\(avatarUrl ?? "")")
                let url = URL(string: avatarUrl!)
                self.userImageView.kf.setImage(with: url,placeholder: UIImage(color: .themeBlue))
                self.userNameLabel.text = displayName
            case .failure(let error):
                debugPrint(error);
            }
        })
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

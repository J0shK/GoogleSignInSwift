//
//  SignedInView.swift
//  GoogleSignInSwift_Example
//
//  Created by Josh Kowarsky on 10/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SnapKit
import UIKit

class SignedInView: UIView {
    private let label = UILabel()
    private let profileView = ProfileView()
    private let tokenView = TokenView()
    
    init() {
        super.init(frame: .zero)
        setupLabel()
        setupProfileView()
        setupTokenView()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        addSubview(label)
        label.text = "Signed in!"
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        label.font = .preferredFont(forTextStyle: .title1)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    private func setupProfileView() {
        addSubview(profileView)
        profileView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(9)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func setupTokenView() {
        addSubview(tokenView)
        tokenView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(9)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func configure() {
        profileView.configure()
        tokenView.configure()
    }
}

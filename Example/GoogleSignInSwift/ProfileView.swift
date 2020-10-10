//
//  ProfileView.swift
//  GoogleSignInSwift_Example
//
//  Created by Josh Kowarsky on 10/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import AlamofireImage
import GoogleSignInSwift
import UIKit

class ProfileView: UIView {
    private let nameLabel = UILabel()
    private let imageView = UIImageView()

    init() {
        super.init(frame: .zero)
        setupNameLabel()
        setupImageView()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.textColor = .black
        nameLabel.font = .preferredFont(forTextStyle: .title2)
        nameLabel.textAlignment = .center
        nameLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }

    private func setupImageView() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(70)
            make.top.equalTo(nameLabel.snp.bottom).offset(9)
            make.centerX.bottom.equalToSuperview()
        }
    }

    func configure() {
        nameLabel.text = GoogleSignIn.shared.user?.name
        guard let url = GoogleSignIn.shared.user?.picture else { return }
        imageView.af.setImage(withURL: url)
    }
}

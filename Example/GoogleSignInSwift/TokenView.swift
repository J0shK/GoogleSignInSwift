//
//  TokenView.swift
//  GoogleSignInSwift_Example
//
//  Created by Josh Kowarsky on 10/5/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import GoogleSignInSwift
import UIKit

class TokenView: UIView {
    private let tokenLabel = UILabel()
    private let refreshButton = UIButton()
    private var refreshing = false

    init() {
        super.init(frame: .zero)
        setupTokenLabel()
        setupRefreshButton()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTokenLabel() {
        addSubview(tokenLabel)
        if #available(iOS 13.0, *) {
            tokenLabel.textColor = .label
        } else {
            tokenLabel.textColor = .black
        }
        tokenLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(snp.centerY).inset(4)
            make.centerX.equalToSuperview()
        }
    }

    private func setupRefreshButton() {
        addSubview(refreshButton)
        refreshButton.addTarget(self, action: #selector(tappedRefreshButton), for: .touchUpInside)
        refreshButton.setTitle("Refresh Token", for: .normal)
        if #available(iOS 13.0, *) {
            refreshButton.setTitleColor(.link, for: .normal)
        } else {
            refreshButton.setTitleColor(.blue, for: .normal)
        }
        refreshButton.snp.makeConstraints { make in
            make.top.equalTo(snp.centerY).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func configure() {
        tokenLabel.text = GoogleSignIn.shared.auth?.accessToken
    }

    @objc private func tappedRefreshButton() {
        guard !refreshing else { return }
        refreshing = true
        GoogleSignIn.shared.refreshingAccessToken { [weak self] token, _ in
            guard token != nil else {
                self?.refreshing = false
                return
            }
            DispatchQueue.main.async {
                self?.configure()
                UIView.animate(withDuration: 0.4) { [weak self] in
                    self?.tokenLabel.alpha = 0
                } completion: { [weak self] completed in
                    guard completed else { return }
                    UIView.animate(withDuration: 0.4) {
                        self?.tokenLabel.alpha = 1
                    } completion: { completed in
                        self?.refreshing = false
                    }
                }
            }
        }
    }
}

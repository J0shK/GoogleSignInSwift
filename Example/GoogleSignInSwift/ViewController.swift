//
//  ViewController.swift
//  GoogleSignInSwift_Example
//
//  Created by Josh Kowarsky on 10/5/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import GoogleSignInSwift
import SnapKit
import UIKit

class ViewController: UIViewController {
    private let signInButton = UIButton()
    private let signedInView = SignedInView()
    private let signOutButton = UIButton()

    init() {
        super.init(nibName: nil, bundle: nil)
        GoogleSignIn.shared.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSignInButton()
        setupSignedInView()
        setupSignOutButton()
        configure()
    }

    private func setupSignInButton() {
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(tappedSignInButton), for: .touchUpInside)
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.setTitleColor(.blue, for: .normal)
        signInButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupSignedInView() {
        view.addSubview(signedInView)
        signedInView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(9)
        }
    }

    private func setupSignOutButton() {
        view.addSubview(signOutButton)
        signOutButton.addTarget(self, action: #selector(tappedSignOutButton), for: .touchUpInside)
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.setTitleColor(.blue, for: .normal)
        signOutButton.snp.makeConstraints { make in
            make.top.equalTo(signedInView.snp.bottom).offset(9)
            make.centerX.equalToSuperview()
        }
    }

    private func configure() {
        signInButton.isHidden = GoogleSignIn.shared.isSignedIn
        signedInView.configure()
        signedInView.isHidden = !GoogleSignIn.shared.isSignedIn
        signOutButton.isHidden = !GoogleSignIn.shared.isSignedIn
    }

    @objc private func tappedSignInButton() {
        GoogleSignIn.shared.presentingWindow = view.window
        GoogleSignIn.shared.signIn()
    }

    @objc private func tappedSignOutButton() {
        GoogleSignIn.shared.signOut()
        configure()
    }
}

extension ViewController: GoogleSignInDelegate {
    func googleSignIn(didSignIn auth: GoogleSignIn.Auth?, user: GoogleSignIn.User?, error: Error?) {
        if let error = error {
            print("Sign in error: \(error)")
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.configure()
        }
    }
}

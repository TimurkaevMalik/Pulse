//
//  BlueWallController.swift
//  Pulse
//
//  Created by Malik Timurkaev on 19.05.2024.
//

import UIKit

class BoardController: UIViewController {
    
    private let boardImageView = UIImageView()
    private let onboardingText = UILabel()
    
    init(boardImage: UIImage, with text: String) {
        self.boardImageView.image = boardImage
        self.onboardingText.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBoardImage()
        configureOnboardingText()
    }
    
    private func configureBoardImage() {
        
        boardImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(boardImageView)
        
        NSLayoutConstraint.activate([
            boardImageView.topAnchor.constraint(equalTo: view.topAnchor),
            boardImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            boardImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            boardImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func configureOnboardingText() {
        onboardingText.font = UIFont.boldSystemFont(ofSize: 32)
        onboardingText.textColor = .black
        onboardingText.numberOfLines = 2
        onboardingText.textAlignment = .center
        
        onboardingText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboardingText)
        
        NSLayoutConstraint.activate([
            onboardingText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 388),
            onboardingText.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            onboardingText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            onboardingText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
}

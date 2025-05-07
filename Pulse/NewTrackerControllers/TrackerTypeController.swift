//
//  CreatingTracker.swift
//  Tracker
//
//  Created by Malik Timurkaev on 12.04.2024.
//

import UIKit

final class TrackerTypeController: UIViewController {
    
    private weak var delegate: TrackerViewControllerDelegate?
    
    let habbit = UIButton()
    let irregularEvent = UIButton()
    let titleLabel = UILabel()
    
    init(delegate: TrackerViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        configureTitleLable()
        configureButtons()
    }
    
    
    @objc func habbitButtonTapped(){
        
        guard let delegate else { return }
        
        let type = ActionType.create(value: TrackerType.habbit)
        let viewController = ChosenTrackerController(actionType: type, tracker: nil, delegate: delegate)
        
        present(viewController, animated: true)
    }
    
    @objc func irregularEventButtonTapped(){
        
        guard let delegate else { return }
        
        let type = ActionType.create(value: TrackerType.irregularEvent)
        let viewController = ChosenTrackerController(actionType: type, tracker: nil, delegate: delegate)
        
        present(viewController, animated: true)
    }
    
    private func configureButtons(){
        let habbitTitle = NSLocalizedString("button.habbit", comment: "Text displayed on habbit button")
        let eventTitle = NSLocalizedString("button.irregularEvent", comment: "Text displayed on irregular event button")
        
        habbit.addTarget(self, action: #selector(habbitButtonTapped), for: .touchUpInside)
        irregularEvent.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        
        habbit.setTitle(habbitTitle, for: .normal)
        habbit.setTitleColor(.ypWhite, for: .normal)
        habbit.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        habbit.layer.cornerRadius = 16
        habbit.layer.masksToBounds = true
        habbit.backgroundColor = .ypBlack
        
        irregularEvent.setTitle(eventTitle, for: .normal)
        irregularEvent.setTitleColor(.ypWhite, for: .normal)
        irregularEvent.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        irregularEvent.layer.cornerRadius = 16
        irregularEvent.layer.masksToBounds = true
        irregularEvent.backgroundColor = .ypBlack
        
        
        view.addSubviews([habbit, irregularEvent])
        habbit.translatesAutoresizingMaskIntoConstraints = false
        irregularEvent.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            habbit.widthAnchor.constraint(equalToConstant: 335),
            habbit.heightAnchor.constraint(equalToConstant: 60),
            habbit.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habbit.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -357),
            
            irregularEvent.widthAnchor.constraint(equalToConstant: 335),
            irregularEvent.heightAnchor.constraint(equalToConstant: 60),
            irregularEvent.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEvent.topAnchor.constraint(equalTo: habbit.bottomAnchor, constant: 16),
        ])
    }
    
    private func configureTitleLable(){
        let titleLabelText = NSLocalizedString("trackerTypeController.title", comment: "Text displayed on the top of screen")
        
        titleLabel.text = titleLabelText
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 149),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27)
        ])
        
    }
}

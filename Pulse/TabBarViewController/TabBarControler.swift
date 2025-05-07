//
//  TabBarControler.swift
//  Pulse
//
//  Created by Malik Timurkaev on 04.04.2024.
//

import UIKit


final class TabBarControler: UITabBarController {
    
    private let pulseViewController = PulseViewController()
    private let statisticViewController = StatisticViewController()
    
    private lazy var filterButton = UIButton()
    private var filterButonBottomConstraint: NSLayoutConstraint?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeTabBarTopBorderLine()
        addTabBarItems()
        configureFilterButton()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item == tabBar.items?[0] {
            showFilterButton()
        } else if item == tabBar.items?[1] {
            hideFilterButton()
        }
    }
    
    @objc func didTapFilterButton() {
        
        AnalyticsService.report(event: "click", params: ["screen": "\(self)", "item": "filter"])
        
        let viewController = FilterViewController(delegate: pulseViewController)
        
        present(viewController, animated: true)
    }
    
    private func makeTabBarTopBorderLine(){
        
        self.tabBar.layer.borderWidth = 1
        self.tabBar.layer.borderColor = UIColor(red:0.0/255.0, green:0.0/255.0, blue:0.0/255.0, alpha:0.2).cgColor
        self.tabBar.layer.masksToBounds = true
    }
    
    private func addTabBarItems(){
        
        tabBar.backgroundColor = .ypWhite
        
        let navigationController = UINavigationController()
        
        let taskItemTitle = NSLocalizedString("trackers", comment: "Text displayed on the trackerController item")
        let statisticItemTitle = NSLocalizedString("statistic", comment: "Text displayed on the statisticController item")
        
        pulseViewController.delegate = self
        pulseViewController.tabBarItem = UITabBarItem(
            title: taskItemTitle,
            image: UIImage(named: "TrackerBarItem"),
            selectedImage: nil)
        
        statisticViewController.tabBarItem = UITabBarItem(
            title: statisticItemTitle,
            image: UIImage(named: "StatisticBarItem"),
            selectedImage: nil)
        
        navigationController.viewControllers = [pulseViewController]
        
        self.viewControllers = [navigationController,
                                statisticViewController]
    }
    
    private func configureFilterButton() {
        let titleText = NSLocalizedString("filters", comment: "")
        
        filterButton.backgroundColor = .ypBlue
        filterButton.setTitle(titleText, for: .normal)
        filterButton.layer.masksToBounds = true
        filterButton.layer.cornerRadius = 16
        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        view.insertSubview(filterButton, belowSubview: tabBar)
        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        filterButonBottomConstraint = filterButton.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -16)
        
        filterButonBottomConstraint?.isActive = true
    }
}

extension TabBarControler: TabBarControllerDelegate {
    
    func hideFilterButton(){
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.5) {
                self.filterButonBottomConstraint?.constant = +50
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func showFilterButton() {
        
        UIView.animate(withDuration: 0.5) {
            self.filterButonBottomConstraint?.constant = -16
            self.view.layoutIfNeeded()
        }
    }
}

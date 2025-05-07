//
//  OnboardingViewController.swift
//  Pulse
//
//  Created by Malik Timurkaev on 19.05.2024.
//

import UIKit

class OnboardingViewController: UIPageViewController {
    
    private let pageControl = UIPageControl()
    private let button = UIButton()
    
    private lazy var pages: [UIViewController] = {
        let blueBoard = BoardController(boardImage: .blueBoardScreen,
                                        with: "Отслеживайте только то, что хотите")
        let redBoard = BoardController(boardImage: .redBoardScreen,
                                       with: "Даже если это\nне литры воды и йога")
        return [blueBoard, redBoard]
    }()
    
    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil) {
            
            super.init(transitionStyle: .scroll,
                       navigationOrientation: .horizontal,
                       options: options)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
            
            configureButton()
            configurePageControl()
        }
    }
    
    @objc func didTapButton() {
        
        let viewController = TabBarControler()
        viewController.modalPresentationStyle = .fullScreen
        
        UserDefaultsManager.wasOnboardinShown = true
        present(viewController, animated: true)
    }
    
    private func configurePageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureButton() {
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.topAnchor.constraint(equalTo: button.bottomAnchor, constant: -60),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        if previousIndex < 0 {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        if nextIndex >= pages.count {
            return pages.first
        }
        
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentController = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: currentController) {
            pageControl.currentPage = index
        }
    }
}

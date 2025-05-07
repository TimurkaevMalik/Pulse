//
//  CattegoryOfTracker.swift
//  Tracker
//
//  Created by Malik Timurkaev on 19.04.2024.
//

import UIKit


final class CategoryView: UIViewController {
    
    
    private let titleLabel = UILabel()
    private let doneButton = UIButton()
    private let buttonContainer = UIView()
    private let tableView = UITableView()
    private lazy var centralPlugLabel = UILabel()
    private lazy var centralPlugImage = UIImageView()
    
    private let viewModel: CategoryViewModel
    private let newCategoryView: NewCategoryView
    
    
    init(viewModel: CategoryViewModel){
        
        self.viewModel = viewModel
        newCategoryView = NewCategoryView(viewModel: viewModel)
        viewModel.newCategoryDelegate = newCategoryView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureControllerViews()
        
        viewModel.categoriesBinding = { [weak self] _ in
            guard let self = self else { return }
            
            self.tableView.backgroundColor = .ypWhite
            self.updateTableViewCells()
        }
        
        viewModel.chosenCategoryBinding = { [weak self] _ in
            guard let self else { return }
            
            self.updateCheckMark()
            self.setButtonTitle()
        }
        
        setButtonTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.categoryViewWillDissapear()
    }
    
    @objc func doneButtonTapped(){
        
        if  let category = viewModel.chosenCategory {
            viewModel.didChoseCategory(category)
            dismiss(animated: true)
        } else {
            
            present(newCategoryView, animated: true)
        }
    }
    
    private func configureControllerViews() {
        view.backgroundColor = .ypWhite
        
        configurePlugImage()
        configurePlugLabel()
        configureTitleLabelView()
        configureDoneButton()
        configureTableView()
    }
    
    private func configureTitleLabelView(){
        let titleLabelText = NSLocalizedString("category", comment: "Text displayed on the top of screen")
        
        titleLabel.text = titleLabelText
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([titleLabel])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureTableView(){
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CategoryCellView.self, forCellReuseIdentifier: "cellIdentifier")
        
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .ypBlack
        tableView.layer.masksToBounds = true
        tableView.allowsMultipleSelection = false
        tableView.showsVerticalScrollIndicator = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([tableView])
        view.insertSubview(tableView, belowSubview: buttonContainer)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func configurePlugImage(){
        centralPlugImage.image = UIImage(named: "TrackerPlug")
        
        centralPlugImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centralPlugImage)
        
        NSLayoutConstraint.activate([
            centralPlugImage.widthAnchor.constraint(equalToConstant: 80),
            centralPlugImage.heightAnchor.constraint(equalToConstant: 80),
            centralPlugImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centralPlugImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -45)
        ])
    }
    
    private func configurePlugLabel(){
        let emptyStateText = NSLocalizedString("categoryView.emptyState.title", comment: "Text displayed on empty state")
        centralPlugLabel.text = emptyStateText
        centralPlugLabel.numberOfLines = 2
        centralPlugLabel.font = UIFont.systemFont(ofSize: 12)
        centralPlugLabel.textAlignment = .center
        
        centralPlugLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([centralPlugLabel])
        
        NSLayoutConstraint.activate([
            centralPlugLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            centralPlugLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            centralPlugLabel.heightAnchor.constraint(equalToConstant: 36),
            centralPlugLabel.topAnchor.constraint(equalTo: centralPlugImage.bottomAnchor, constant: 8),
            centralPlugLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureDoneButton(){
        buttonContainer.backgroundColor = .ypWhite
        doneButton.backgroundColor = .ypBlack
        doneButton.setTitleColor(.ypWhite, for: .normal)
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubviews([buttonContainer, doneButton])
        
        NSLayoutConstraint.activate([
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            buttonContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonContainer.topAnchor.constraint(equalTo: doneButton.topAnchor, constant: -3),
            buttonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func updateTableViewCells() {
        
        let newCount = viewModel.categories.count
        
        tableView.performBatchUpdates {
            
            let lastIndex = IndexPath(row: newCount - 1, section: 0)
            tableView.insertRows(at: [lastIndex], with: .top)
            
            if newCount > 1 {
                let secondLastIndex = IndexPath(row: newCount - 2, section: 0)
                tableView.reloadRows(at: [secondLastIndex], with: .fade)
            }
        }
    }
    
    private func updateCheckMark() {
        
        let visbleCategories: [CategoryCellView?]  = tableView.visibleCells.map({ $0 as? CategoryCellView})
        
        for visbleCategory in visbleCategories {
            
            if visbleCategory?.nameOfCategory == viewModel.chosenCategory {
                
                visbleCategory?.accessoryType = .checkmark
            } else {
                visbleCategory?.accessoryType = .none
            }
        }
    }
    
    private func setButtonTitle() {
        let createCategoryText = NSLocalizedString("button.createCategory", comment: "Text displayed on create button")
        let addCategoryText = NSLocalizedString("button.addCategory", comment: "Text displayed on create button")
        
        if viewModel.chosenCategory == nil {
            doneButton.setTitle(createCategoryText, for: .normal)
        } else {
            doneButton.setTitle(addCategoryText, for: .normal)
        }
    }
}


extension CategoryView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if viewModel.categories.count < 8 {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        
        if viewModel.categories.count == 0 {
            tableView.backgroundColor = .clear
        } else {
            tableView.backgroundColor = .ypWhite
        }
        
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as? CategoryCellView else {
            return UITableViewCell()
        }
        
        cell.layer.masksToBounds = true
        cell.setCornerRadiusForCell(at: indexPath, of: tableView)
        
        cell.backgroundColor = .ypMediumLightGray
        cell.separatorInset = UIEdgeInsets(top: 0.3, left: 16, bottom: 0.3, right: 16)

        cell.hidesBottomSeparator = indexPath.row == viewModel.categories.count - 1
        
        cell.nameOfCategory = viewModel.categories[indexPath.row]

        cell.awakeFromNib()
        cell.accessoryType = cell.nameOfCategory == viewModel.chosenCategory ? .checkmark : .none
        
        return cell
    }
}


extension CategoryView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? CategoryCellView,
           let nameOfCategory = cell.nameOfCategory {
            
            viewModel.updateChosenCategory(nameOfCategory)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

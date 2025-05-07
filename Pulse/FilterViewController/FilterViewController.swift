//
//  FilterViewController.swift
//  Tracker
//
//  Created by Malik Timurkaev on 01.06.2024.
//

import UIKit


class FilterViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    
    private weak var delegate: FilterControllerDelegate?
    private let filters: [String] = ["allTrackers", "trackersForToday", "completedOnes", "notCompletedOnes"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        configureTitleLabelView()
        configureTableView()
    }
    
    init(delegate: FilterControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTitleLabelView(){
        let titleLabelText = NSLocalizedString("filters", comment: "Text displayed on the top of screen")
        
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.allowsMultipleSelection = false
        tableView.separatorColor = .ypBlack
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([tableView])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 299),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func updateCheckMark(on indexPath: IndexPath) {
        
        let cells  = tableView.visibleCells
        
        for cell in cells {
            cell.accessoryType = .none
        }
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)

        cell.backgroundColor = .ypMediumLightGray
        
        cell.accessoryType = UserDefaultsManager.chosenFilter == filters[indexPath.row] ? .checkmark : .none
        
        let filterText = filters[indexPath.row]
        cell.textLabel?.text = NSLocalizedString(filterText, comment: "")
        
        cell.separatorInset = UIEdgeInsets(top: 0.3, left: 16, bottom: 0.3, right: 16)
        
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserDefaultsManager.chosenFilter = filters[indexPath.row]
        updateCheckMark(on: indexPath)
        delegate?.didChooseFilter()
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
}

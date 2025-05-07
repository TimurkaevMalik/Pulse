//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Malik Timurkaev on 04.04.2024.
//

import UIKit


final class StatisticViewController: UIViewController {
    
    private let tableView = UITableView()
    private lazy var titleLabel = UILabel()
    private lazy var centralPlugLabel = UILabel()
    private lazy var centralPlugImage = UIImageView()
    
    private var trackerRecordStore: TrackerRecordStore?
    private var records = 0
    
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.init()
            return
        }
        self.init(appDelegate: appDelegate)
    }
    
    private init(appDelegate: AppDelegate) {
        super.init(nibName: nil, bundle: nil)
        trackerRecordStore = TrackerRecordStore(self, appDelegate: appDelegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        updateStatistic()
        configureTitleLabel()
        configurePlugImage()
        configurePlugLabel()
        configureTableView()
    }
    
    private func updateStatistic() {
        guard let trackerRecords = trackerRecordStore?.fetchAllConvertedRecords() else {
            return
        }
        records = 0
        trackerRecords.forEach({ records += $0.date.count })
        tableView.reloadData()
    }
    
    private func configureTitleLabel(){
        let statisticTopTitle = NSLocalizedString("statistic", comment: "Text displayed on the top of statistic")
        
        titleLabel.text = statisticTopTitle
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 254),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
    }
    
    private func configureTableView(){
        tableView.dataSource = self
        tableView.register(StatisticCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .ypWhite
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func configurePlugImage(){
        centralPlugImage.image = UIImage(named: "StatisticPlug")
        
        centralPlugImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centralPlugImage)
        
        NSLayoutConstraint.activate([
            centralPlugImage.widthAnchor.constraint(equalToConstant: 80),
            centralPlugImage.heightAnchor.constraint(equalToConstant: 80),
            centralPlugImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            centralPlugImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30)
        ])
    }
    
    private func configurePlugLabel() {
        let emptyStateText = NSLocalizedString("statistic.emptyState.title", comment: "Text displayed on empty state")
        
        centralPlugLabel.text = emptyStateText
        centralPlugLabel.font = UIFont.systemFont(ofSize: 12)
        centralPlugLabel.textAlignment = .center
        
        centralPlugLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centralPlugLabel)
        
        NSLayoutConstraint.activate([
            centralPlugLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            centralPlugLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            centralPlugLabel.heightAnchor.constraint(equalToConstant: 18),
            centralPlugLabel.topAnchor.constraint(equalTo: centralPlugImage.bottomAnchor, constant: 8),
            centralPlugLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
}

extension StatisticViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if records == 0 {
            tableView.backgroundColor = .clear
        } else {
            tableView.backgroundColor = .ypWhite
        }
        
        return records == 0 ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as? StatisticCell else {
            return UITableViewCell()
        }
        
        let statisticText = NSLocalizedString("completedTrackers", comment: "")

        cell.statisticNumber.text = "\(records)"
        cell.cellText.text = statisticText
        cell.backgroundColor = .red

        return cell
    }
}

extension StatisticViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
}

extension StatisticViewController: RecordStoreDelegate {
    func didUpdate(record: TrackerRecord) {
        updateStatistic()
    }
    func didDelete(record: TrackerRecord) {
        updateStatistic()
    }
    func didAdd(record: TrackerRecord) {
        updateStatistic()
    }
}

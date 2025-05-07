//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Malik Timurkaev on 04.04.2024.
//

import UIKit


final class TrackerViewController: UIViewController {
    var count = 0
    private let datePicker = UIDatePicker()
    private lazy var plusButton = UIButton()
    private lazy var centralPlugLabel = UILabel()
    private lazy var centralPlugImage = UIImageView()
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var trackerStore: TrackerStoreProtocol?
    private var trackerCategoryStore: TrackerCategoryStore?
    private var trackerRecordStore: RecordStoreProtocol?
    private var categories: [TrackerCategory] = []
    private var visibleTrackers: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var trackers: [Tracker] = []
    private var records: [Date] = []
    private var currentDate: Date
    
    weak var delegate: TabBarControllerDelegate?
    private let cellIdentifier = "collectionCell"
    private let headerIdentifier = "headerIdentifier"
    
    private let params = GeomitricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 7)
    
    private var dateFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.calendar = .current
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        return formatter
    }
    
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.init()
            return
        }
        self.init(appDelegate: appDelegate)
    }
    
    private init(appDelegate: AppDelegate) {
        currentDate = datePicker.date
        super.init(nibName: nil, bundle: nil)
        
        trackerStore = TrackerStore(self, appDelegate: appDelegate)
        trackerCategoryStore = TrackerCategoryStore(appDelegate: appDelegate)
        trackerRecordStore = TrackerRecordStore(self, appDelegate: appDelegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.report(event: "open", params: ["screen": "\(self)"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.report(event: "close", params: ["screen": "\(self)"])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentDate = datePicker.date
        configureTrackerViews()
        
        trackerCategoryStore?.locolizePinedCategory()
        
        categories = trackerStore?.updateCategoriesArray() ?? []
        completedTrackers = trackerRecordStore?.fetchAllConvertedRecords() ?? []
        
        showVisibleTrackers(dateDescription: currentDate.description(with: .current))
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        currentDate = sender.date
        
        showVisibleTrackers(dateDescription: currentDate.description(with: .current))
    
        if UserDefaultsManager.chosenFilter == "trackersForToday" {
            UserDefaultsManager.chosenFilter = "allTrackers"
        }
    }
    
    @objc func didTapPlusButton(){
        
        AnalyticsService.report(event: "click", params: ["screen": "\(self)", "item": "add_track"])
        
        let viewController = TrackerTypeController(delegate: self)
        
        present(viewController, animated: true)
    }
    
    private func configureTrackerViews(){
        view.backgroundColor = .ypWhite
        
        configurePlugImage()
        configurePlugLabel()
        configureSearchController()
        addTitleAndSearchControllerToNavBar()
        configureCollectionView()
        configureDatePicker()
        configurePlusButton()
    }
    
    private func configurePlugImage(){
        
        centralPlugImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centralPlugImage)
        
        NSLayoutConstraint.activate([
            centralPlugImage.widthAnchor.constraint(equalToConstant: 80),
            centralPlugImage.heightAnchor.constraint(equalToConstant: 80),
            centralPlugImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centralPlugImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30)
        ])
    }
    
    private func configurePlugLabel(){
        centralPlugLabel.font = UIFont.systemFont(ofSize: 12)
        centralPlugLabel.textAlignment = .center
        
        centralPlugLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([centralPlugLabel])
        
        NSLayoutConstraint.activate([
            centralPlugLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            centralPlugLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            centralPlugLabel.heightAnchor.constraint(equalToConstant: 18),
            centralPlugLabel.topAnchor.constraint(equalTo: centralPlugImage.bottomAnchor, constant: 8),
            centralPlugLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureSearchController(){
        searchController.searchResultsUpdater = self
        
        let placeHolder = NSLocalizedString("searchBar.placeholder", comment: "Text displayed inside of searchBar as placeholder")
        
        let atributedString = NSMutableAttributedString(string: placeHolder)
        atributedString.setColor(.ypGray, forText: placeHolder)
        
        searchController.searchBar.searchTextField.attributedPlaceholder = atributedString
        searchController.searchBar.searchTextField.leftView?.tintColor = .ypGray
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.layer.cornerRadius = 8
        searchController.searchBar.layer.masksToBounds = true
        searchController.searchBar.isTranslucent = false
    }
    
    private func configureCollectionView(){
        
        registerCollectionViewsSubviews()
        
        collectionView.backgroundColor = .ypWhite
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: params.leftInset, bottom: 10, right: params.rightInset)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
    
    private func configureDatePicker() {
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.backgroundColor = .ypLightGray
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
        datePicker.timeZone = TimeZone.current
        datePicker.calendar = .current
        
        datePicker.tintColor = .black
        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
        datePicker.setValue(false, forKey: "highlightsToday")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func configurePlusButton() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        plusButton = UIButton.systemButton(with: UIImage(named: "PlusImage") ?? UIImage(), target: self, action: #selector(didTapPlusButton))
        plusButton.tintColor = .ypBlack
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
    }
    
    private func registerCollectionViewsSubviews(){
        
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    private func addTitleAndSearchControllerToNavBar(){
        let trackersTopTitle = NSLocalizedString("trackers", comment: "Text displayed on the top of search bar")
        navigationItem.title = trackersTopTitle
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureCell(for cell: CollectionViewCell, with indexPath: IndexPath){
        
        let actualTracker = visibleTrackers[indexPath.section].trackersArray[indexPath.row]
        
        cell.delegate = self
        cell.idOfCell = actualTracker.id
        cell.emoji.text = actualTracker.emoji
        cell.nameLable.text = actualTracker.name
        cell.view.backgroundColor = actualTracker.color
        cell.doneButton.backgroundColor = actualTracker.color
        
        let category = visibleTrackers[indexPath.section]
        
        if  let pinedCategory = updatePinedTrackers().first,
            category.titleOfCategory == pinedCategory.titleOfCategory {
            
            cell.pinedImageView.image = .pined
        } else {
            cell.pinedImageView.image = nil
        }
        
        if wasCellButtonTapped(at: indexPath) == true {
            
            cell.doneButton.backgroundColor = actualTracker.color.withAlphaComponent(0.3)
            cell.doneButton.setImage(UIImage(named: "CheckMark"), for: .normal)
        } else {
            
            cell.doneButton.backgroundColor = actualTracker.color.withAlphaComponent(1)
            cell.doneButton.setImage(UIImage(named: "WhitePlus"), for: .normal)
        }
        
        
        if !completedTrackers.isEmpty {
            
            for record in completedTrackers {
                if record.id == actualTracker.id {
                    
                    cell.count = record.date.count
                    
                    let locolizedText = NSLocalizedString("numberOfDays", comment: "")
                    cell.daysCount.text = String(format: locolizedText, record.date.count)
                } else {
                    
                    if completedTrackers.contains(where: { element in
                        element.id == actualTracker.id
                    }) {
                        
                        continue
                    } else {
                        let locolizedText = NSLocalizedString("days", comment: "")
                        
                        cell.daysCount.text = String(format: locolizedText, 0)
                        cell.count = 0
                    }
                }
            }
        } else {
            let locolizedText = NSLocalizedString("days", comment: "")
            
            cell.daysCount.text = String(format: locolizedText, 0)
            cell.count = 0
        }
    }
    
    private func wasCellButtonTapped(at indexPath: IndexPath) -> Bool {
        
        guard
            
            let actualDate = currentDate.getDefaultDateWith(formatter: dateFormatter)
        else {
            return false
        }
        
        let id = visibleTrackers[indexPath.section].trackersArray[indexPath.row].id
        
        for element in completedTrackers {
            
            if element.id == id {
                for date in element.date {
                    
                    if actualDate == date {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    private func showVisibleTrackers(dateDescription: String?){
        
        checkForVisibleTrackersAt(dateDescription: dateDescription)
        
        collectionView.reloadData()
    }
    
    private func updatePinedTrackers() -> [TrackerCategory] {
        let pinedText = NSLocalizedString("pined", comment: "")
        
        if let pinedCategory = categories.first(where: { $0.titleOfCategory == pinedText }),
           !pinedCategory.trackersArray.isEmpty {
            
            return [pinedCategory]
        } else {
            return []
        }
    }
    
    private func checkForVisibleTrackersAt(dateDescription: String?) {
        guard let dateDescription else { return }
        shouldUpdatePlugs()
        visibleTrackers = updatePinedTrackers()
        
        var selectedDate = ""
        
        for char in dateDescription.lowercased() {
            if char != "," {
                selectedDate.append(char)
            } else {
                break
            }
        }
        
        for category in categories {
            
            trackers.removeAll()
            
            for tracker in category.trackersArray {
                
                if !visibleTrackers.contains(where: { $0.trackersArray.contains(where: { $0.id == tracker.id })}) {
                    
                    if !tracker.schedule.isEmpty {
                        for dayOfWeek in tracker.schedule {
                            
                            if let dayOfWeek {
                                
                                let locolizedDay = NSLocalizedString(dayOfWeek, comment: "")
                                
                                if locolizedDay.lowercased() == selectedDate,
                                   !visibleTrackers.contains(where: { $0.trackersArray.contains(where: { $0.id == tracker.id }) }) {
                                    
                                    if UserDefaultsManager.chosenFilter == "completedOnes" {
                                        appendIfCompleted(tracker: tracker)
                                    } else if UserDefaultsManager.chosenFilter == "notCompletedOnes" {
                                        appendIfNotCompleted(tracker: tracker)
                                    } else {
                                        trackers.append(tracker)
                                    }
                                }
                            }
                        }
                    } else if UserDefaultsManager.chosenFilter == "completedOnes" {
                        
                        appendIfCompleted(event: tracker)
                    } else {
                        appendIdNotCompleted(event: tracker)
                    }
                }
            }
            if !trackers.isEmpty {
                
                visibleTrackers.append(TrackerCategory(titleOfCategory: category.titleOfCategory, trackersArray: trackers))
            }
        }
    }
    
    private func appendIdNotCompleted(event: Tracker) {
        if !completedTrackers.contains(where: { $0.id == event.id }) {
            trackers.append(event)
        }
    }
    
    private func appendIfCompleted(event: Tracker) {
        if completedTrackers.contains(where: { $0.id == event.id && 
            $0.date.contains(where: {
                
              return  $0 == currentDate.getDefaultDateWith(formatter: dateFormatter)})}
        ) {
            
            trackers.append(event)
        }
    }
    
    private func appendIfCompleted(tracker: Tracker) {
        
        let pinedCategory = updatePinedTrackers()
        
        if !pinedCategory.contains(where: { $0.trackersArray.contains(where: { $0.id == tracker.id})}) {
            
            if completedTrackers.contains(where: { $0.id == tracker.id &&
                $0.date.contains(where: {
                    $0 == currentDate.getDefaultDateWith(formatter: dateFormatter)
                })}) {
                trackers.append(tracker)
            }
        }
    }
    
    private func appendIfNotCompleted(tracker: Tracker) {
        let pinedCategory = updatePinedTrackers()
        
        if !pinedCategory.contains(where: { $0.trackersArray.contains(where: { $0.id == tracker.id})}) {
            
            if !completedTrackers.contains(where: { $0.id == tracker.id }) {
                trackers.append(tracker)
            } else if let record = completedTrackers.first(where: { $0.id == tracker.id }),
                      !record.date.contains(where: { $0 == currentDate.getDefaultDateWith(formatter: dateFormatter)}) {
                trackers.append(tracker)
            }
        }
    }
    
    private func shouldUpdatePlugs() {
        if UserDefaultsManager.chosenFilter != "allTrackers" {
            let plugText = NSLocalizedString("nothingWasFound", comment: "")
            centralPlugLabel.text = plugText
            centralPlugImage.image = UIImage(named: "SearchEmojiPlug")
        } else {
            let emptyStateText = NSLocalizedString("whatShouldWeTrack", comment: "")
            centralPlugLabel.text = emptyStateText
            centralPlugImage.image = UIImage(named: "TrackerPlug")
        }
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if visibleTrackers.isEmpty {
            collectionView.backgroundColor? = .clear
        } else {
            collectionView.backgroundColor = .ypWhite
        }
        
        if visibleTrackers.isEmpty && UserDefaultsManager.chosenFilter == "allTrackers" && !completedTrackers.contains(where: {$0.date.contains(where: { $0 == currentDate.getDefaultDateWith(formatter: dateFormatter)})}) {
            delegate?.hideFilterButton()
        } else {
            delegate?.showFilterButton()
        }
        
        return visibleTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return visibleTrackers.isEmpty ? 0 :
        visibleTrackers[section].trackersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        configureCell(for: cell, with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var id: String
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = headerIdentifier
            
        default:
            id = ""
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        
        if id == headerIdentifier,
           !visibleTrackers.isEmpty {
            
            headerView.titleLabel.text = visibleTrackers[indexPath.section].titleOfCategory
        }
        
        return headerView
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availibleSpacing = collectionView.frame.width - params.paddingWidth
        let cellWidth = availibleSpacing / params.cellCount
        
        return CGSize(width: cellWidth, height: cellWidth - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: 18),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    }
}

extension TrackerViewController: UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView.contentOffset.y > 20 {
            delegate?.hideFilterButton()
        } else if scrollView.contentOffset.y < 20 {
            delegate?.showFilterButton()
        }
    }
}

extension TrackerViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController){
        
        if let searchText = searchController.searchBar.text , !searchText.isEmpty {
            
            visibleTrackers.removeAll()
            
            if let category = updatePinedTrackers().first {
                trackers = category.trackersArray.filter({ $0.name.lowercased().contains(searchText.lowercased())})

                if !trackers.isEmpty {
                    visibleTrackers.append( TrackerCategory(titleOfCategory: category.titleOfCategory, trackersArray: trackers))
                }
            }
            
            for category in categories {
                
                trackers = category.trackersArray.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                
                if let pinedCategory = visibleTrackers.first {
                    trackers = trackers.filter({ tracker in
                        pinedCategory.trackersArray.contains(where: { $0.id != tracker.id })
                    })
                }
                
                if !trackers.isEmpty {
                    visibleTrackers.append(TrackerCategory(titleOfCategory: category.titleOfCategory, trackersArray: trackers))
                }
            }
        } else {
            checkForVisibleTrackersAt(dateDescription: currentDate.description(with: .current))
        }
        
        collectionView.reloadData()
    }
}

extension TrackerViewController: CollectionViewCellDelegate {
    
    func contextMenuForCell(_ cell: CollectionViewCell) -> UIContextMenuConfiguration? {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return nil }
        
        let pinedText = NSLocalizedString("pined", comment: "")
        let editText = NSLocalizedString("edit", comment: "")
        let deleteText = NSLocalizedString("delete", comment: "")
        
        var pinAction: UIAction
        
        if visibleTrackers[indexPath.section].titleOfCategory == pinedText {
            
            let unpinText = NSLocalizedString("button.unpin", comment: "")
            
            pinAction = UIAction(title: unpinText,
                                 handler: { [weak self] _ in
                
                guard let self else { return }
                self.unpinMenuButtonTappedOn(indexPath)
            })
        } else {
            
            let pinText = NSLocalizedString("button.pin", comment: "")
            
            pinAction = UIAction(title: pinText,
                                 handler: { [weak self] _ in
                
                guard let self else { return }
                self.pinMenuButtonTappedOn(indexPath)
            })
        }
        
        let editAction = UIAction(title: editText,
                                  handler: { [weak self] _ in
            
            guard let self else { return }
            self.editMenuButtonTappedOn(indexPath)
        })
        
        let deleleteAction = UIAction(title: deleteText,
                                      attributes: .destructive,
                                      handler: { [weak self] _ in
            
            guard let self else { return }
            self.deleteAtertForTracker(indexPath)
        })
        
        return UIContextMenuConfiguration(actionProvider:  { _ in
            return UIMenu(children: [pinAction, editAction, deleleteAction])
        })
    }
    
    func pinMenuButtonTappedOn(_ indexPath: IndexPath) {
        
        let category = visibleTrackers[indexPath.section]
        let tracker = category.trackersArray[indexPath.row]
        let pinedText = NSLocalizedString("pined", comment: "")
        
        trackerStore?.storeNewTracker(tracker, for: pinedText)
    }
    
    func unpinMenuButtonTappedOn(_ indexPath: IndexPath) {
        
        let category = visibleTrackers[indexPath.section]
        let tracker = category.trackersArray[indexPath.row]
        
        trackerCategoryStore?.deleteTrackerWith(tracker.id, from: category.titleOfCategory)
    }
    
    func editMenuButtonTappedOn(_ indexPath: IndexPath) {
        
        AnalyticsService.report(event: "click", params: ["screen": "\(self)", "item": "edit"])
        
        let tracker = visibleTrackers[indexPath.section].trackersArray[indexPath.row]
        let daysCount = completedTrackers.first(where: { $0.id == tracker.id })?.date.count
        
        let pinedText = NSLocalizedString("pined", comment: "")
        let daysText = NSLocalizedString("numberOfDays", comment: "")
        
        guard let category = (categories.filter {
            $0.trackersArray.contains(where: {$0.id == tracker.id})
        }.first(where: { $0.titleOfCategory != pinedText })) else {
            return
        }
        
        let type = tracker.schedule.isEmpty ? ActionType.edit(value: TrackerType.irregularEvent) : ActionType.edit(value: TrackerType.habbit)
        
        let trackerToEdit = TrackerToEdit(
            titleOfCategory: category.titleOfCategory, id: tracker.id,
            name: tracker.name, color: tracker.color,
            emoji: tracker.emoji, schedule: tracker.schedule,
            daysCount: String(format: daysText, daysCount ?? 0))
        
        let viewController = ChosenTrackerController(
            actionType: type, tracker: trackerToEdit,
            delegate: self)
        
        present(viewController, animated: true)
    }
    
    func deleteMenuButtonTappedOn(_ indexPath: IndexPath) {
        
        AnalyticsService.report(event: "click", params: ["screen": "\(self)", "item": "delete"])
        
        let tracker = visibleTrackers[indexPath.section].trackersArray[indexPath.row]
        
        trackerStore?.deleteTrackerWith(id: tracker.id)
        trackerRecordStore?.deleteAllRecordsOfTracker(tracker.id)
    }
    
    func cellPlusButtonTapped(_ cell: CollectionViewCell) {
        
        AnalyticsService.report(event: "click", params: ["screen": "\(self)", "item": "track"])
        
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let actualDate = currentDate.getDefaultDateWith(formatter: dateFormatter)
        else { return }
        
        let category = visibleTrackers[indexPath.section]
        let tracker = category.trackersArray[indexPath.row]
        let idOfCell = tracker.id
        
        if tracker.schedule.isEmpty {
            
            guard cell.shouldTapButton(cell, date: actualDate) != nil else { return }
            
            trackerStore?.deleteTrackerWith(id: idOfCell)
            
            if completedTrackers.contains(where: { $0.id == tracker.id }){
                
                trackerRecordStore?.deleteAllRecordsOfTracker(idOfCell)
            } else {
                trackerRecordStore?.storeRecord(TrackerRecord(id: idOfCell, date: [actualDate]))
            }
            trackerStore?.storeNewTracker(tracker, for: category.titleOfCategory)
        } else {
            
            guard let bool = cell.shouldTapButton(cell, date: actualDate) else { return }
            
            shouldRecordDate(bool, id: idOfCell)
        }
    }
    
    private func shouldRecordDate(_ bool: Bool, id: UUID){
        
        guard let actualDate = currentDate.getDefaultDateWith(formatter: dateFormatter)
        else { return }
        
        records.removeAll()
        
        if bool == true {
            
            addRecordDate(id: id, actualDate: actualDate)
        } else {
            
            removeRecordDate(id: id, actualDate: actualDate)
        }
    }
    
    private func addRecordDate(id: UUID, actualDate: Date){
        
        if var dates = completedTrackers.first(where: { $0.id == id })?.date {
            
            dates.append(actualDate)
            trackerRecordStore?.updateRecord(TrackerRecord(id: id, date: dates))
            
        } else {
            
            trackerRecordStore?.storeRecord(TrackerRecord(id: id, date: [actualDate]))
        }
    }
    
    private func removeRecordDate(id: UUID, actualDate: Date){
        
        records.removeAll()
        
        if let record = completedTrackers.first(where: { $0.id == id }) {
            
            for index in 0..<record.date.count {
                
                if actualDate != record.date[index] {
                    
                    records.append(record.date[index])
                }
            }
            
            trackerRecordStore?.deleteRecord(TrackerRecord(id: id, date: records))
        }
    }
    
    private func deleteAtertForTracker(_ indexPath: IndexPath) {
        
        let alertTitle = NSLocalizedString("delete.confirmation", comment: "")
        let cancelText = NSLocalizedString("cancel", comment: "")
        let deleteText = NSLocalizedString("delete", comment: "")
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: cancelText, style: .cancel)
        
        let delete = UIAlertAction(title: deleteText, style: .destructive) { [weak self] _ in
            
            guard let self else { return }
            self.deleteMenuButtonTappedOn(indexPath)
        }
        
        delete.titleTextColor = .ypColorBlud
        cancel.titleTextColor = .ypColorSky
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

extension TrackerViewController: TrackerStoreDelegate {
    
    func didAdd(tracker: Tracker, with categoryTitle: String) {
        
        if categories.contains(where: {
            $0.titleOfCategory == categoryTitle}) {
            
            for index in 0..<categories.count {
                
                let category = categories[index]
                
                if category.titleOfCategory == categoryTitle {
                    
                    trackers = category.trackersArray
                    trackers.append(tracker)
                    
                    categories[index] = TrackerCategory(titleOfCategory: category.titleOfCategory, trackersArray: trackers)
                }
            }
        } else {
            
            categories.append(TrackerCategory(titleOfCategory: categoryTitle, trackersArray: [tracker]))
            categories.sort(by: { $0.titleOfCategory < $1.titleOfCategory })
        }
        
        reloadSectionOrData()
    }
    
    func didUpdate(tracker: Tracker, categoryTitle: String) {
        categories = trackerStore?.updateCategoriesArray() ?? []
        showVisibleTrackers(dateDescription: currentDate.description(with: .current))
    }
    
    
    func didDelete(tracker: Tracker) {
        closeCollectionCellAt(idOfCell: tracker.id)
    }
    
    private func reloadSectionOrData() {
        
        let oldCount = visibleTrackers.count
        let oldVisibleTrackers = visibleTrackers
        
        checkForVisibleTrackersAt(dateDescription: currentDate.description(with: .current))
        
        let newCount = visibleTrackers.count
        
        if oldCount < newCount {
            
            let newCategory = visibleTrackers.first(where: { category in
                
                !oldVisibleTrackers.contains(where: { $0.titleOfCategory == category.titleOfCategory})})
            
            if let sectionInsert = visibleTrackers.firstIndex(where: { $0.titleOfCategory == newCategory?.titleOfCategory}) {
                
                let trackersArray = visibleTrackers[sectionInsert].trackersArray
                
                guard
                    let sectionDelete = oldVisibleTrackers.firstIndex(where: {$0.trackersArray.contains(where: { tracker in trackersArray.contains(where: { $0.id == tracker.id })})}),
                    
                        let rowDelete = oldVisibleTrackers[sectionDelete].trackersArray.firstIndex(where: { tracker in
                            trackersArray.contains(where: { $0.id == tracker.id})
                        })
                else {
                    collectionView.performBatchUpdates {
                        collectionView.insertSections([sectionInsert])
                    }
                    return
                }
                
                collectionView.performBatchUpdates {
                    
                    collectionView.deleteItems(at: [IndexPath(
                        row: rowDelete, section: sectionDelete)])
                    
                    collectionView.insertSections([sectionInsert])
                }
            }
        } else if oldCount > newCount {
            
            collectionView.reloadData()
        } else if oldCount == newCount {
            
            collectionView.reloadData()
        }
    }
    
    private func closeCollectionCellAt(idOfCell: UUID){
        
        let cells = collectionView.visibleCells as? [CollectionViewCell]
        
        guard
            let cell = cells?.first(where: { $0.idOfCell == idOfCell }),
            let indexPath = collectionView.indexPath(for: cell)
        else {
            return
        }
        
        let category = visibleTrackers[indexPath.section]
        
        guard let categoryIndex = categories.firstIndex(where: { $0.titleOfCategory == category.titleOfCategory}) else { return }
        
        if category.trackersArray.count != 1 {
            
            trackers = category.trackersArray.filter({ $0.id != idOfCell })
            visibleTrackers[indexPath.section] = TrackerCategory(titleOfCategory: category.titleOfCategory, trackersArray: trackers)
            
            trackers = categories[categoryIndex].trackersArray.filter({ $0.id != idOfCell })
            categories[categoryIndex] = TrackerCategory(titleOfCategory: category.titleOfCategory, trackersArray: trackers)
            
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [indexPath])
            }
        } else {
            
            trackers = categories[categoryIndex].trackersArray.filter({ $0.id != idOfCell })
            
            if !trackers.isEmpty {
                categories[categoryIndex] = TrackerCategory(titleOfCategory: category.titleOfCategory, trackersArray: trackers)
            } else {
                categories.remove(at: categoryIndex)
            }
            
            visibleTrackers.remove(at: indexPath.section)
            
            collectionView.performBatchUpdates {
                collectionView.deleteSections([indexPath.section])
            }
        }
        
        let pinedText = NSLocalizedString("pined", comment: "")
        
        if category.titleOfCategory == pinedText {
            shouldRemoveOrInsertSameTracker(id: idOfCell)
        }
    }
    
    private func shouldRemoveOrInsertSameTracker(id: UUID) {
        
        guard let index = categories.firstIndex(where: { $0.trackersArray.contains(where: { $0.id == id })}) else {
            return
        }
        
        if trackerStore?.fetchTracker(with: id) != nil {
            
            insertItemOf(categoryIndex: index)
        } else {
            deleteSameTrackerWith(id: id, categoryIndex: index)
        }
    }
    
    private func insertItemOf(categoryIndex index: Int) {
        
        if let section = visibleTrackers.firstIndex(where: { $0.titleOfCategory == categories[index].titleOfCategory }) {
            
            checkForVisibleTrackersAt(dateDescription: currentDate.description(with: .current))
            
            collectionView.performBatchUpdates {
                collectionView.reloadSections([section])
            }
            
        } else {
            
            checkForVisibleTrackersAt(dateDescription: currentDate.description(with: .current))
            
            guard let section = visibleTrackers.firstIndex(where: { $0.titleOfCategory == categories[index].titleOfCategory}) else { return }
            
            collectionView.performBatchUpdates {
                collectionView.insertSections([section])
            }
        }
    }
    
    private func deleteSameTrackerWith(id: UUID, categoryIndex index: Int) {
        
        trackers = categories[index].trackersArray.filter({ $0.id != id })
        
        categories[index] = TrackerCategory(
            titleOfCategory: categories[index].titleOfCategory,
            trackersArray: trackers)
    }
    
}

extension TrackerViewController: RecordStoreDelegate {
    func didAdd(record: TrackerRecord) {
        
        completedTrackers.append(record)
        
        if UserDefaultsManager.chosenFilter == "notCompletedOnes" ||
           UserDefaultsManager.chosenFilter == "completedOnes"
        {
            showVisibleTrackers(dateDescription: currentDate.description(with: .current))
        }
    }
    
    func didDelete(record: TrackerRecord) {
        
        completedTrackers = trackerRecordStore?.fetchAllConvertedRecords() ?? []
        
        if UserDefaultsManager.chosenFilter == "completedOnes" {
            showVisibleTrackers(dateDescription: currentDate.description(with: .current))
        }
    }
    
    func didUpdate(record: TrackerRecord) {
        
        completedTrackers = trackerRecordStore?.fetchAllConvertedRecords() ?? []
        
        if UserDefaultsManager.chosenFilter == "notCompletedOnes" ||
           UserDefaultsManager.chosenFilter == "completedOnes" {
            showVisibleTrackers(dateDescription: currentDate.description(with: .current))
        }
    }
}

extension TrackerViewController: TrackerViewControllerDelegate {
    
    func addNewTracker(trackerCategory: TrackerCategory) {
        self.dismiss(animated: true)
        
        trackerStore?.storeNewTracker(trackerCategory.trackersArray[0], for: trackerCategory.titleOfCategory)
    }
    
    func didEditTracker(tracker: TrackerToEdit) {
        
        self.dismiss(animated: true) { [weak self] in
            
            let pinedText = NSLocalizedString("pined", comment: "")
            
            guard
                let self,
                let oldCategory = (categories.filter {
                    $0.trackersArray.contains(where: {$0.id == tracker.id})
                }.first(where: { $0.titleOfCategory != pinedText }))
            else { return }
            
            let editedTracker = Tracker(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule)
            
            if !updatePinedTrackers().contains(where: { $0.trackersArray.contains(where: { $0.id == tracker.id })}) {
                
                self.trackerStore?.deleteTrackerOf(
                    categoryTitle: oldCategory.titleOfCategory, id: tracker.id)
                
                self.trackerStore?.storeNewTracker(
                    editedTracker, for: tracker.titleOfCategory)
            } else {
                
                trackerStore?.updateTracker(editedTracker, for: tracker.titleOfCategory)
            }
        }
        
    }
    
    func dismisTrackerTypeController() {
        self.dismiss(animated: true)
    }
}

extension TrackerViewController: FilterControllerDelegate {
    
    func didChooseFilter() {
        
        if UserDefaultsManager.chosenFilter == "trackersForToday" {
            datePicker.setDate(Date(), animated: true)
            currentDate = Date()
        }
        showVisibleTrackers(dateDescription: currentDate.description(with: .current))
    }
}

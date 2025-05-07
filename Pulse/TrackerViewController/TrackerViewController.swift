//
//  PulseViewController.swift
//  Pulse
//
//  Created by Malik Timurkaev on 04.04.2024.
//

import UIKit


final class PulseViewController: UIViewController {
    var count = 0
    private let datePicker = UIDatePicker()
    private lazy var plusButton = UIButton()
    private lazy var centralPlugLabel = UILabel()
    private lazy var centralPlugImage = UIImageView()
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var taskStore: TaskStoreProtocol?
    private var taskCategoryStore: TaskCategoryStore?
    private var taskRecordStore: RecordStoreProtocol?
    private var categories: [TaskCategory] = []
    private var visibleTasks: [TaskCategory] = []
    private var completedTasks: [TaskRecord] = []
    private var tasks: [TaskData] = []
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
        
        taskStore = TaskStore(self, appDelegate: appDelegate)
        taskCategoryStore = TaskCategoryStore(appDelegate: appDelegate)
        taskRecordStore = TaskRecordStore(self, appDelegate: appDelegate)
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
        configureTaskViews()
        
        taskCategoryStore?.locolizePinedCategory()
        
        categories = taskStore?.updateCategoriesArray() ?? []
        completedTasks = taskRecordStore?.fetchAllConvertedRecords() ?? []
        
        showVisibleTasks(dateDescription: currentDate.description(with: .current))
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        currentDate = sender.date
        
        showVisibleTasks(dateDescription: currentDate.description(with: .current))
    
        if UserDefaultsManager.chosenFilter == "tasksForToday" {
            UserDefaultsManager.chosenFilter = "allTasks"
        }
    }
    
    @objc func didTapPlusButton(){
        
        AnalyticsService.report(event: "click", params: ["screen": "\(self)", "item": "add_track"])
        
        let viewController = TaskTypeController(delegate: self)
        
        present(viewController, animated: true)
    }
    
    private func configureTaskViews(){
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
        let tasksTopTitle = NSLocalizedString("trackers", comment: "Text displayed on the top of search bar")
        navigationItem.title = tasksTopTitle
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureCell(for cell: CollectionViewCell, with indexPath: IndexPath){
        
        let actualTask = visibleTasks[indexPath.section].tasksArray[indexPath.row]
        
        cell.delegate = self
        cell.idOfCell = actualTask.id
        cell.emoji.text = actualTask.emoji
        cell.nameLable.text = actualTask.name
        cell.view.backgroundColor = actualTask.color
        cell.doneButton.backgroundColor = actualTask.color
        
        let category = visibleTasks[indexPath.section]
        
        if  let pinedCategory = updatePinedTasks().first,
            category.titleOfCategory == pinedCategory.titleOfCategory {
            
            cell.pinedImageView.image = .pined
        } else {
            cell.pinedImageView.image = nil
        }
        
        if wasCellButtonTapped(at: indexPath) == true {
            
            cell.doneButton.backgroundColor = actualTask.color.withAlphaComponent(0.3)
            cell.doneButton.setImage(UIImage(named: "CheckMark"), for: .normal)
        } else {
            
            cell.doneButton.backgroundColor = actualTask.color.withAlphaComponent(1)
            cell.doneButton.setImage(UIImage(named: "WhitePlus"), for: .normal)
        }
        
        
        if !completedTasks.isEmpty {
            
            for record in completedTasks {
                if record.id == actualTask.id {
                    
                    cell.count = record.date.count
                    
                    let locolizedText = NSLocalizedString("numberOfDays", comment: "")
                    cell.daysCount.text = String(format: locolizedText, record.date.count)
                } else {
                    
                    if completedTasks.contains(where: { element in
                        element.id == actualTask.id
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
        
        let id = visibleTasks[indexPath.section].tasksArray[indexPath.row].id
        
        for element in completedTasks {
            
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
    
    private func showVisibleTasks(dateDescription: String?){
        
        checkForVisibleTasksAt(dateDescription: dateDescription)
        
        collectionView.reloadData()
    }
    
    private func updatePinedTasks() -> [TaskCategory] {
        let pinedText = NSLocalizedString("pined", comment: "")
        
        if let pinedCategory = categories.first(where: { $0.titleOfCategory == pinedText }),
           !pinedCategory.tasksArray.isEmpty {
            
            return [pinedCategory]
        } else {
            return []
        }
    }
    
    private func checkForVisibleTasksAt(dateDescription: String?) {
        guard let dateDescription else { return }
        shouldUpdatePlugs()
        visibleTasks = updatePinedTasks()
        
        var selectedDate = ""
        
        for char in dateDescription.lowercased() {
            if char != "," {
                selectedDate.append(char)
            } else {
                break
            }
        }
        
        for category in categories {
            
            tasks.removeAll()
            
            for task in category.tasksArray {
                
                if !visibleTasks.contains(where: { $0.tasksArray.contains(where: { $0.id == task.id })}) {
                    
                    if !task.schedule.isEmpty {
                        for dayOfWeek in task.schedule {
                            
                            if let dayOfWeek {
                                
                                let locolizedDay = NSLocalizedString(dayOfWeek, comment: "")
                                
                                if locolizedDay.lowercased() == selectedDate,
                                   !visibleTasks.contains(where: { $0.tasksArray.contains(where: { $0.id == task.id }) }) {
                                    
                                    if UserDefaultsManager.chosenFilter == "completedOnes" {
                                        appendIfCompleted(task: task)
                                    } else if UserDefaultsManager.chosenFilter == "notCompletedOnes" {
                                        appendIfNotCompleted(task: task)
                                    } else {
                                        tasks.append(task)
                                    }
                                }
                            }
                        }
                    } else if UserDefaultsManager.chosenFilter == "completedOnes" {
                        
                        appendIfCompleted(event: task)
                    } else {
                        appendIdNotCompleted(event: task)
                    }
                }
            }
            if !tasks.isEmpty {
                
                visibleTasks.append(TaskCategory(titleOfCategory: category.titleOfCategory, tasksArray: tasks))
            }
        }
    }
    
    private func appendIdNotCompleted(event: TaskData) {
        if !completedTasks.contains(where: { $0.id == event.id }) {
            tasks.append(event)
        }
    }
    
    private func appendIfCompleted(event: TaskData) {
        if completedTasks.contains(where: { $0.id == event.id && 
            $0.date.contains(where: {
                
              return  $0 == currentDate.getDefaultDateWith(formatter: dateFormatter)})}
        ) {
            
            tasks.append(event)
        }
    }
    
    private func appendIfCompleted(task: TaskData) {
        
        let pinedCategory = updatePinedTasks()
        
        if !pinedCategory.contains(where: { $0.tasksArray.contains(where: { $0.id == task.id})}) {
            
            if completedTasks.contains(where: { $0.id == task.id &&
                $0.date.contains(where: {
                    $0 == currentDate.getDefaultDateWith(formatter: dateFormatter)
                })}) {
                tasks.append(task)
            }
        }
    }
    
    private func appendIfNotCompleted(task: TaskData) {
        let pinedCategory = updatePinedTasks()
        
        if !pinedCategory.contains(where: { $0.tasksArray.contains(where: { $0.id == task.id})}) {
            
            if !completedTasks.contains(where: { $0.id == task.id }) {
                tasks.append(task)
            } else if let record = completedTasks.first(where: { $0.id == task.id }),
                      !record.date.contains(where: { $0 == currentDate.getDefaultDateWith(formatter: dateFormatter)}) {
                tasks.append(task)
            }
        }
    }
    
    private func shouldUpdatePlugs() {
        if UserDefaultsManager.chosenFilter != "allTasks" {
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

extension PulseViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if visibleTasks.isEmpty {
            collectionView.backgroundColor? = .clear
        } else {
            collectionView.backgroundColor = .ypWhite
        }
        
        if visibleTasks.isEmpty && UserDefaultsManager.chosenFilter == "allTasks" && !completedTasks.contains(where: {$0.date.contains(where: { $0 == currentDate.getDefaultDateWith(formatter: dateFormatter)})}) {
            delegate?.hideFilterButton()
        } else {
            delegate?.showFilterButton()
        }
        
        return visibleTasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return visibleTasks.isEmpty ? 0 :
        visibleTasks[section].tasksArray.count
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
           !visibleTasks.isEmpty {
            
            headerView.titleLabel.text = visibleTasks[indexPath.section].titleOfCategory
        }
        
        return headerView
    }
}

extension PulseViewController: UICollectionViewDelegateFlowLayout {
    
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

extension PulseViewController: UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView.contentOffset.y > 20 {
            delegate?.hideFilterButton()
        } else if scrollView.contentOffset.y < 20 {
            delegate?.showFilterButton()
        }
    }
}

extension PulseViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController){
        
        if let searchText = searchController.searchBar.text , !searchText.isEmpty {
            
            visibleTasks.removeAll()
            
            if let category = updatePinedTasks().first {
                tasks = category.tasksArray.filter({ $0.name.lowercased().contains(searchText.lowercased())})

                if !tasks.isEmpty {
                    visibleTasks.append( TaskCategory(titleOfCategory: category.titleOfCategory, tasksArray: tasks))
                }
            }
            
            for category in categories {
                
                tasks = category.tasksArray.filter { task in
                    task.name.lowercased().contains(searchText.lowercased())
                }
                
                if let pinedCategory = visibleTasks.first {
                    tasks = tasks.filter({ task in
                        pinedCategory.tasksArray.contains(where: { $0.id != task.id })
                    })
                }
                
                if !tasks.isEmpty {
                    visibleTasks.append(TaskCategory(titleOfCategory: category.titleOfCategory, tasksArray: tasks))
                }
            }
        } else {
            checkForVisibleTasksAt(dateDescription: currentDate.description(with: .current))
        }
        
        collectionView.reloadData()
    }
}

extension PulseViewController: CollectionViewCellDelegate {
    
    func contextMenuForCell(_ cell: CollectionViewCell) -> UIContextMenuConfiguration? {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return nil }
        
        let pinedText = NSLocalizedString("pined", comment: "")
        let editText = NSLocalizedString("edit", comment: "")
        let deleteText = NSLocalizedString("delete", comment: "")
        
        var pinAction: UIAction
        
        if visibleTasks[indexPath.section].titleOfCategory == pinedText {
            
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
            self.deleteAtertForTask(indexPath)
        })
        
        return UIContextMenuConfiguration(actionProvider:  { _ in
            return UIMenu(children: [pinAction, editAction, deleleteAction])
        })
    }
    
    func pinMenuButtonTappedOn(_ indexPath: IndexPath) {
        
        let category = visibleTasks[indexPath.section]
        let task = category.tasksArray[indexPath.row]
        let pinedText = NSLocalizedString("pined", comment: "")
        
        taskStore?.storeNewTask(task, for: pinedText)
    }
    
    func unpinMenuButtonTappedOn(_ indexPath: IndexPath) {
        
        let category = visibleTasks[indexPath.section]
        let task = category.tasksArray[indexPath.row]
        
        taskCategoryStore?.deleteTaskWith(task.id, from: category.titleOfCategory)
    }
    
    func editMenuButtonTappedOn(_ indexPath: IndexPath) {
        
        AnalyticsService.report(event: "click", params: ["screen": "\(self)", "item": "edit"])
        
        let task = visibleTasks[indexPath.section].tasksArray[indexPath.row]
        let daysCount = completedTasks.first(where: { $0.id == task.id })?.date.count
        
        let pinedText = NSLocalizedString("pined", comment: "")
        let daysText = NSLocalizedString("numberOfDays", comment: "")
        
        guard let category = (categories.filter {
            $0.tasksArray.contains(where: {$0.id == task.id})
        }.first(where: { $0.titleOfCategory != pinedText })) else {
            return
        }
        
        let type = task.schedule.isEmpty ? ActionType.edit(value: TaskType.irregularEvent) : ActionType.edit(value: TaskType.habbit)
        
        let trackerToEdit = TrackerToEdit(
            titleOfCategory: category.titleOfCategory, id: task.id,
            name: task.name, color: task.color,
            emoji: task.emoji, schedule: task.schedule,
            daysCount: String(format: daysText, daysCount ?? 0))
        
        let viewController = ChosenTrackerController(
            actionType: type, tracker: trackerToEdit,
            delegate: self)
        
        present(viewController, animated: true)
    }
    
    func deleteMenuButtonTappedOn(_ indexPath: IndexPath) {
        
        AnalyticsService.report(event: "click", params: ["screen": "\(self)", "item": "delete"])
        
        let tracker = visibleTasks[indexPath.section].tasksArray[indexPath.row]
        
        taskStore?.deleteTaskWith(id: tracker.id)
        taskRecordStore?.deleteAllRecordsOfTask(tracker.id)
    }
    
    func cellPlusButtonTapped(_ cell: CollectionViewCell) {
        
        AnalyticsService.report(event: "click", params: ["screen": "\(self)", "item": "track"])
        
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let actualDate = currentDate.getDefaultDateWith(formatter: dateFormatter)
        else { return }
        
        let category = visibleTasks[indexPath.section]
        let tracker = category.tasksArray[indexPath.row]
        let idOfCell = tracker.id
        
        if tracker.schedule.isEmpty {
            
            guard cell.shouldTapButton(cell, date: actualDate) != nil else { return }
            
            taskStore?.deleteTaskWith(id: idOfCell)
            
            if completedTasks.contains(where: { $0.id == tracker.id }){
                
                taskRecordStore?.deleteAllRecordsOfTask(idOfCell)
            } else {
                taskRecordStore?.storeRecord(TaskRecord(id: idOfCell, date: [actualDate]))
            }
            taskStore?.storeNewTask(tracker, for: category.titleOfCategory)
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
        
        if var dates = completedTasks.first(where: { $0.id == id })?.date {
            
            dates.append(actualDate)
            taskRecordStore?.updateRecord(TaskRecord(id: id, date: dates))
            
        } else {
            
            taskRecordStore?.storeRecord(TaskRecord(id: id, date: [actualDate]))
        }
    }
    
    private func removeRecordDate(id: UUID, actualDate: Date){
        
        records.removeAll()
        
        if let record = completedTasks.first(where: { $0.id == id }) {
            
            for index in 0..<record.date.count {
                
                if actualDate != record.date[index] {
                    
                    records.append(record.date[index])
                }
            }
            
            taskRecordStore?.deleteRecord(TaskRecord(id: id, date: records))
        }
    }
    
    private func deleteAtertForTask(_ indexPath: IndexPath) {
        
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

extension PulseViewController: TaskStoreDelegate {
    
    func didAdd(task: TaskData, with categoryTitle: String) {
        
        if categories.contains(where: {
            $0.titleOfCategory == categoryTitle}) {
            
            for index in 0..<categories.count {
                
                let category = categories[index]
                
                if category.titleOfCategory == categoryTitle {
                    
                    tasks = category.tasksArray
                    tasks.append(task)
                    
                    categories[index] = TaskCategory(titleOfCategory: category.titleOfCategory, tasksArray: tasks)
                }
            }
        } else {
            
            categories.append(TaskCategory(titleOfCategory: categoryTitle, tasksArray: [task]))
            categories.sort(by: { $0.titleOfCategory < $1.titleOfCategory })
        }
        
        reloadSectionOrData()
    }
    
    func didUpdate(task: TaskData, categoryTitle: String) {
        categories = taskStore?.updateCategoriesArray() ?? []
        showVisibleTasks(dateDescription: currentDate.description(with: .current))
    }
    
    
    func didDelete(task: TaskData) {
        closeCollectionCellAt(idOfCell: task.id)
    }
    
    private func reloadSectionOrData() {
        
        let oldCount = visibleTasks.count
        let oldVisibleTrackers = visibleTasks
        
        checkForVisibleTasksAt(dateDescription: currentDate.description(with: .current))
        
        let newCount = visibleTasks.count
        
        if oldCount < newCount {
            
            let newCategory = visibleTasks.first(where: { category in
                
                !oldVisibleTrackers.contains(where: { $0.titleOfCategory == category.titleOfCategory})})
            
            if let sectionInsert = visibleTasks.firstIndex(where: { $0.titleOfCategory == newCategory?.titleOfCategory}) {
                
                let trackersArray = visibleTasks[sectionInsert].tasksArray
                
                guard
                    let sectionDelete = oldVisibleTrackers.firstIndex(where: {$0.tasksArray.contains(where: { tracker in trackersArray.contains(where: { $0.id == tracker.id })})}),
                    
                        let rowDelete = oldVisibleTrackers[sectionDelete].tasksArray.firstIndex(where: { tracker in
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
        
        let category = visibleTasks[indexPath.section]
        
        guard let categoryIndex = categories.firstIndex(where: { $0.titleOfCategory == category.titleOfCategory}) else { return }
        
        if category.tasksArray.count != 1 {
            
            tasks = category.tasksArray.filter({ $0.id != idOfCell })
            visibleTasks[indexPath.section] = TaskCategory(titleOfCategory: category.titleOfCategory, tasksArray: tasks)
            
            tasks = categories[categoryIndex].tasksArray.filter({ $0.id != idOfCell })
            categories[categoryIndex] = TaskCategory(titleOfCategory: category.titleOfCategory, tasksArray: tasks)
            
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [indexPath])
            }
        } else {
            
            tasks = categories[categoryIndex].tasksArray.filter({ $0.id != idOfCell })
            
            if !tasks.isEmpty {
                categories[categoryIndex] = TaskCategory(titleOfCategory: category.titleOfCategory, tasksArray: tasks)
            } else {
                categories.remove(at: categoryIndex)
            }
            
            visibleTasks.remove(at: indexPath.section)
            
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
        
        guard let index = categories.firstIndex(where: { $0.tasksArray.contains(where: { $0.id == id })}) else {
            return
        }
        
        if taskStore?.fetchTask(with: id) != nil {
            
            insertItemOf(categoryIndex: index)
        } else {
            deleteSameTrackerWith(id: id, categoryIndex: index)
        }
    }
    
    private func insertItemOf(categoryIndex index: Int) {
        
        if let section = visibleTasks.firstIndex(where: { $0.titleOfCategory == categories[index].titleOfCategory }) {
            
            checkForVisibleTasksAt(dateDescription: currentDate.description(with: .current))
            
            collectionView.performBatchUpdates {
                collectionView.reloadSections([section])
            }
            
        } else {
            
            checkForVisibleTasksAt(dateDescription: currentDate.description(with: .current))
            
            guard let section = visibleTasks.firstIndex(where: { $0.titleOfCategory == categories[index].titleOfCategory}) else { return }
            
            collectionView.performBatchUpdates {
                collectionView.insertSections([section])
            }
        }
    }
    
    private func deleteSameTrackerWith(id: UUID, categoryIndex index: Int) {
        
        tasks = categories[index].tasksArray.filter({ $0.id != id })
        
        categories[index] = TaskCategory(
            titleOfCategory: categories[index].titleOfCategory,
            tasksArray: tasks)
    }
    
}

extension PulseViewController: RecordStoreDelegate {
    func didAdd(record: TaskRecord) {
        
        completedTasks.append(record)
        
        if UserDefaultsManager.chosenFilter == "notCompletedOnes" ||
           UserDefaultsManager.chosenFilter == "completedOnes"
        {
            showVisibleTasks(dateDescription: currentDate.description(with: .current))
        }
    }
    
    func didDelete(record: TaskRecord) {
        
        completedTasks = taskRecordStore?.fetchAllConvertedRecords() ?? []
        
        if UserDefaultsManager.chosenFilter == "completedOnes" {
            showVisibleTasks(dateDescription: currentDate.description(with: .current))
        }
    }
    
    func didUpdate(record: TaskRecord) {
        
        completedTasks = taskRecordStore?.fetchAllConvertedRecords() ?? []
        
        if UserDefaultsManager.chosenFilter == "notCompletedOnes" ||
           UserDefaultsManager.chosenFilter == "completedOnes" {
            showVisibleTasks(dateDescription: currentDate.description(with: .current))
        }
    }
}

extension PulseViewController: PulseViewControllerDelegate {
    
    func addNewTracker(trackerCategory: TaskCategory) {
        self.dismiss(animated: true)
        
        taskStore?.storeNewTask(trackerCategory.tasksArray[0], for: trackerCategory.titleOfCategory)
    }
    
    func didEditTracker(tracker: TrackerToEdit) {
        
        self.dismiss(animated: true) { [weak self] in
            
            let pinedText = NSLocalizedString("pined", comment: "")
            
            guard
                let self,
                let oldCategory = (categories.filter {
                    $0.tasksArray.contains(where: {$0.id == tracker.id})
                }.first(where: { $0.titleOfCategory != pinedText }))
            else { return }
            
            let editedTracker = TaskData(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule)
            
            if !updatePinedTasks().contains(where: { $0.tasksArray.contains(where: { $0.id == tracker.id })}) {
                
                self.taskStore?.deleteTaskOf(
                    categoryTitle: oldCategory.titleOfCategory, id: tracker.id)
                
                self.taskStore?.storeNewTask(
                    editedTracker, for: tracker.titleOfCategory)
            } else {
                
                taskStore?.updateTask(editedTracker, for: tracker.titleOfCategory)
            }
        }
        
    }
    
    func dismisTaskTypeController() {
        self.dismiss(animated: true)
    }
}

extension PulseViewController: FilterControllerDelegate {
    
    func didChooseFilter() {
        
        if UserDefaultsManager.chosenFilter == "tasksForToday" {
            datePicker.setDate(Date(), animated: true)
            currentDate = Date()
        }
        showVisibleTasks(dateDescription: currentDate.description(with: .current))
    }
}

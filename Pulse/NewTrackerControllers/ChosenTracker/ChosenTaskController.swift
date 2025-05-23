//
//  ChosenTaskController.swift
//  Pulse
//
//  Created by Malik Timurkaev on 14.04.2024.
//

import UIKit

class ChosenTaskController: UIViewController {
    
    private weak var delegate: PulseViewControllerDelegate?
    
    private let textField = UITextField()
    private let clearTextFieldButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
    
    private let titleLabel = UILabel()
    private let daysCountLabel = UILabel()
    private let limitWarningLabel = UILabel()
    private let titleLabelContainer = UIView()
    
    private let saveButton = UIButton()
    private let cancelButton = UIButton()
    private let buttonsContainer = UIView()
    
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    
    private let tableView = UITableView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let actionType: ActionType
    private let colorMarshalling = UIColorMarshalling()
    private let params = GeomitricParams(cellCount: 6, leftInset: 18, rightInset: 18, cellSpacing: 5)
    
    private var tableViewCells: [String] = []
    private var warningLabelBottomConstraint: [NSLayoutConstraint] = []
    
    private var chosenColorCell: UICollectionViewCell?
    private var chosenEmojiCell: UICollectionViewCell?
    
    private var scheduleOfTask: [String] = []
    private var nameOfCategory: String?
    private var nameOfTask: String?
    private var colorOfTask: UIColor?
    private var emojiOfTask: String?
    private var daysCountText: String?
    private var editingTaskId: UUID?
    private let warningLabelTitle = NSLocalizedString("cancel", comment: "Text displayed on cancel button")
    
    private let tableCellIdentifier = "tableCellIdentifier"
    private let emojiCellIdentifier = "emojiCollectionCell"
    private let colorCellIdentifier = "colorCollectionCell"
    private let collectionHeaderIdentifier = "collectionHeaderIdentifier"
    
    private let emojisArray: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colorsArray: [UIColor] = [.ypRed, .ypOrange, .ypMediumBlue, .ypElectricViolet, .ypGreen, .ypViolet, .ypLightPink, .ypCyan, .ypLightGreen, .ypBlueMagneta, .ypTomato, .ypPink, .ypWarmYellow, .ypMediumLightBlue, .ypFrenchViolet, .ypGrape, .ypSlateBlue, .ypMediumLightGreen]
    
    
    init(actionType: ActionType, task: TaskToEdit?,
         delegate: PulseViewControllerDelegate){
        
        self.actionType = actionType
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        
        nameOfCategory = task?.titleOfCategory
        nameOfTask = task?.name
        colorOfTask = task?.color
        emojiOfTask = task?.emoji
        scheduleOfTask = task?.schedule as? [String] ?? []
        daysCountText = task?.daysCount
        editingTaskId = task?.id
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewsBasedOn(actionType: actionType)
        configureRestOfControllerUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func didEnterTextInTextField(_ sender: UITextField){
        
        guard
            let text = sender.text,
            !text.isEmpty,
            !text.filter({ $0 != Character(" ") }).isEmpty
        else {
            nameOfTask = nil
            clearTextFieldButtonTapped()
            shouldActivateSaveButton()
            return
        }
        
        textField.text = text.trimmingCharacters(in: .whitespaces)
        shouldActivateSaveButton()
    }
    
    @objc func clearTextFieldButtonTapped(){
        textField.text?.removeAll()
    }
    
    @objc func saveButtonTapped(){
        let fieldsfullnessText = NSLocalizedString("warning.fieldsfullness", comment: "Text shows up as warning")
        
        checkIsTextFieldEmpty()
        
        guard
            let nameOfCategory = nameOfCategory,
            let name = nameOfTask,
            let color = colorOfTask,
            let emoji = emojiOfTask
        else {
            showWarningLabel(with: fieldsfullnessText)
            highLightButton()
            return
        }
        
        switch actionType {
            
        case .create(let value):
            
            if value == TaskType.habbit {
                guard !scheduleOfTask.isEmpty else {
                    showWarningLabel(with: fieldsfullnessText)
                    highLightButton()
                    return
                }
            }
            
            let newTask = TaskData(id: UUID(), name: name, color: color, emoji: emoji, schedule: scheduleOfTask)
            
            let newCategory = TaskCategory(titleOfCategory: nameOfCategory, tasksArray: [newTask])
            
            delegate?.addNewTask(taskCategory: newCategory)
            
        case .edit(let value):
            if value == TaskType.habbit {
                guard !scheduleOfTask.isEmpty else {
                    showWarningLabel(with: fieldsfullnessText)
                    highLightButton()
                    return
                }
            }
            
            guard 
                let id = editingTaskId,
                let daysCountText
            else { return }
            
            delegate?.didEditTask(task: TaskToEdit(
                titleOfCategory: nameOfCategory, id: id,
                name: name, color: color, emoji: emoji,
                schedule: scheduleOfTask, daysCount: daysCountText))
            
        }
    }
    
    @objc func cancelButtonTapped(){
        delegate?.dismisTaskTypeController()
    }
    
    private func configureRestOfControllerUI() {
        view.backgroundColor = .ypWhite
        
        configureLimitWarningLabel()
        configureTableView()
        configureCollection()
        configureSaveAndCancelButtons()
        configureTitleLabelView()
    }
    
    private func configureViewsBasedOn(actionType: ActionType) {
        
        let categoryCellTitle = NSLocalizedString("category", comment: "Text displayed on tableView cell")
        let scheduleCellTitle = NSLocalizedString("schedule", comment: "Text displayed on tableView cell")
        
        switch actionType {
            
        case .create(value: let value):
            if value == TaskType.irregularEvent {
                tableViewCells.append(categoryCellTitle)
                
                configureScrollView(contentHeight: 1.13)
            } else {
                tableViewCells.append(categoryCellTitle)
                tableViewCells.append(scheduleCellTitle)
                
                configureScrollView(contentHeight: 1.24)
            }
            configureTextField(under: scrollContentView.topAnchor, constant: 0)
            
        case .edit(value: let value):
            
            if value == TaskType.irregularEvent {
                
                tableViewCells.append(categoryCellTitle)
                configureScrollView(contentHeight: 1.13)
                configureTextField(under: scrollContentView.topAnchor, constant: 0)
                
            } else {
                tableViewCells.append(categoryCellTitle)
                tableViewCells.append(scheduleCellTitle)
                
                configureScrollView(contentHeight: 1.36)
                configureDaysCountLabel()
                configureTextField(under: daysCountLabel.bottomAnchor, constant: 40)
            }
        }
    }
    
    private func configureDaysCountLabel() {
        daysCountLabel.text = daysCountText
        daysCountLabel.textAlignment = .center
        daysCountLabel.font = UIFont.boldSystemFont(ofSize: 32)
        daysCountLabel.textColor = .ypBlack
        
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(daysCountLabel)
        
        NSLayoutConstraint.activate([
            daysCountLabel.heightAnchor.constraint(equalToConstant: 38),
            daysCountLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor),
            daysCountLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            daysCountLabel.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
        ])
    }
    
    private func configureScrollView(contentHeight: CGFloat){
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollContentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -2),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: -2),
            
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -4),
            scrollContentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: contentHeight)
        ])
    }
    
    private func configureCollection(){
        
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: params.leftInset, bottom: 0, right: params.rightInset)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(collectionView)
        scrollView.insertSubview(collectionView, belowSubview: buttonsContainer)
        
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: 484),
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor),
            
            collectionView.bottomAnchor.constraint(lessThanOrEqualTo: scrollContentView.bottomAnchor)
        ])
    }
    
    private func configureLimitWarningLabel(){
        
        limitWarningLabel.textColor = .ypRed
        limitWarningLabel.font = UIFont.systemFont(ofSize: 17)
        
        scrollView.addSubview(limitWarningLabel)
        limitWarningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        warningLabelBottomConstraint.append(limitWarningLabel.bottomAnchor.constraint(equalTo: textField.bottomAnchor))
        
        warningLabelBottomConstraint.first?.isActive = true
        limitWarningLabel.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor).isActive = true
    }
    
    private func configureSaveAndCancelButtons(){
        buttonsContainer.backgroundColor = .ypWhite
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        let cancelButtonText = NSLocalizedString("cancel", comment: "Text displayed on cancel button")
        var saveButtonText: String?
        
        switch actionType {
        case .create:
            saveButtonText = NSLocalizedString("create", comment: "Text displayed on create button")
            
        case .edit:
            saveButtonText = NSLocalizedString("save", comment: "Text displayed on create button")
        }
        
        saveButton.setTitle(saveButtonText, for: .normal)
        saveButton.setTitleColor(.ypWhite, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        saveButton.backgroundColor = .ypDarkGray
        saveButton.layer.cornerRadius = 16
        saveButton.layer.masksToBounds = true
        
        cancelButton.setTitle(cancelButtonText, for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.backgroundColor = .ypWhite
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubviewsToScrollView([buttonsContainer, saveButton, cancelButton])
        
        NSLayoutConstraint.activate([
            buttonsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonsContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            saveButton.widthAnchor.constraint(equalToConstant: 161),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.leadingAnchor.constraint(equalTo: buttonsContainer.centerXAnchor, constant: 4),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            cancelButton.widthAnchor.constraint(equalToConstant: 161),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: buttonsContainer.centerXAnchor, constant: -4),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureTitleLabelView(){
        
        titleLabel.text = locolizedTitleBy(actionType)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabelContainer.backgroundColor = .ypWhite
        
        titleLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([titleLabelContainer, titleLabel])
        
        NSLayoutConstraint.activate([
            titleLabelContainer.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabelContainer.bottomAnchor.constraint(equalTo: titleLabelContainer.topAnchor, constant: 63),
            titleLabelContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabelContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: titleLabelContainer.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: titleLabelContainer.centerXAnchor)
        ])
    }
    
    private func configureTextField(under anchor: NSLayoutYAxisAnchor,
                                    constant: CGFloat){
        
        let enterNameText = NSLocalizedString("placeholder.enterTaskName", comment: "")
        
        textField.placeholder = enterNameText
        textField.text = nameOfTask
        textField.delegate = self
        textField.backgroundColor = .ypMediumLightGray
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.leftViewMode = .always
        
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.addTarget(self, action: #selector(didEnterTextInTextField(_:)), for: .editingDidEndOnExit)
        textField.rightView = clearTextFieldButton
        textField.rightViewMode = .whileEditing
        
        
        clearTextFieldButton.addTarget(self, action: #selector(clearTextFieldButtonTapped), for: .touchUpInside)
        clearTextFieldButton.backgroundColor = .ypMediumLightGray
        clearTextFieldButton.setImage(UIImage(named: "x.mark.circle"), for: .normal)
        
        clearTextFieldButton.contentHorizontalAlignment = .leading
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: anchor, constant: constant),
            textField.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            
            clearTextFieldButton.widthAnchor.constraint(equalToConstant: clearTextFieldButton.frame.width + 12)
        ])
    }
    
    private func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: tableCellIdentifier)
        
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorColor = .ypBlack
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: limitWarningLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16)
        ])
        
        if tableViewCells.count == 2 {
            tableView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 149).isActive = true
        } else {
            tableView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 74).isActive = true
        }
    }
    
    private func locolizedTitleBy(_ actionType: ActionType) -> String? {
        
        switch actionType {
        case .create(let value):
            
            if value ==  TaskType.habbit {
                
                return NSLocalizedString("habbitController.title", comment: "Text displayed on the top of screen")
                
            } else if value == TaskType.irregularEvent {
                
                return NSLocalizedString("eventController.title", comment: "Text displayed on the top of screen")
            }
            
        case .edit(let value):
            
            if value ==  TaskType.habbit {
                
                return NSLocalizedString("habbitController.editing.title", comment: "Text displayed on the top of screen")
                
            } else if value == TaskType.irregularEvent {
                
                return NSLocalizedString("eventController.editing.title", comment: "Text displayed on the top of screen")
            }
        }
        
        return nil
    }
    
    private func highLightButton(){
        
        UIView.animate(withDuration: 0.2) {
            
            self.saveButton.backgroundColor = .ypRed
            
        } completion: { isCompleted in
            if isCompleted {
                resetButtonColor()
            }
        }
        
        func resetButtonColor(){
            UIView.animate(withDuration: 0.1) {
                self.saveButton.backgroundColor = .ypDarkGray
            }
        }
    }
    
    private func showWarningLabel(with text: String){
        
        limitWarningLabel.text = text
        isTextFieldAndSaveButtonEnabled(bool: false)
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.4, delay: 0.09) {
                self.warningLabelBottomConstraint.first?.constant = 30
                self.view.layoutIfNeeded()
                
            } completion: { isCompleted in
                
                UIView.animate(withDuration: 0.3, delay: 1) {
                    self.warningLabelBottomConstraint.first?.constant = 0
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.1, execute: {
            
            self.isTextFieldAndSaveButtonEnabled(bool: true)
        })
    }
    
    private func isTextFieldAndSaveButtonEnabled(bool: Bool){
        saveButton.isEnabled = bool
        textField.isEnabled = bool
    }
    
    private func shouldActivateSaveButton(){
        
        if tableViewCells.count > 1 {
            guard !scheduleOfTask.isEmpty else {
                saveButton.backgroundColor = .ypDarkGray
                return
            }
        }
        
        guard
            nameOfTask  != nil,
            nameOfCategory != nil,
            emojiOfTask != nil,
            colorOfTask != nil
        else {
            
            saveButton.backgroundColor = .ypDarkGray
            return
        }
        
        saveButton.backgroundColor = .ypBlack
    }
    
    private func validateNameOfTask(_ text: String) {
        
        if !text.isEmpty, !text.filter({ $0 != Character(" ") }).isEmpty {
            nameOfTask = text.trimmingCharacters(in: .whitespaces)
        } else {
            nameOfTask = nil
        }
    }
    
    private func deselectPreviousColor(of collectionView: UICollectionView){
        
        guard
            let previousColorCell = chosenColorCell,
            let previousColorIndex = collectionView.indexPath(for: previousColorCell)
        else { return }
        
        collectionView.deselectItem(at: previousColorIndex, animated: true)
        chosenColorCell?.layer.borderWidth = 0
        chosenColorCell?.backgroundColor = .clear
    }
    
    private func deselectPreviousEmoji(of collectionView: UICollectionView){
        
        guard
            let previousColorCell = chosenEmojiCell,
            let previousEmojiIndex = collectionView.indexPath(for: previousColorCell)
        else { return }
        
        collectionView.deselectItem(at: previousEmojiIndex, animated: true)
        chosenEmojiCell?.backgroundColor = .clear
    }
    
    private func checkIsTextFieldEmpty() {
        
        if let text = textField.text,
           text.filter({ $0 != Character(" ") }).isEmpty {
            clearTextFieldButtonTapped()
        }
    }
}


extension ChosenTaskController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = .ypMediumLightGray
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.row == 0 {
            cell.updateTextOfCellWith(name: tableViewCells[indexPath.row],
                                      text: nameOfCategory ?? "")
            
        } else if indexPath.row == 1 {
            shouldAddDates(scheduleOfTask, on: cell)
        }
        
        cell.separatorInset = UIEdgeInsets(top: 0.3, left: 16, bottom: 0.3, right: 16)
        
        return cell
    }
}


extension ChosenTaskController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let categoryStore = TaskCategoryStore(appDelegate: appDelegate)
            let viewModel = CategoryViewModel(categoryStore: categoryStore,
                                              chosenCategory: nameOfCategory, categoryModelDelegate: self)
            
            let viewControler = CategoryView(viewModel: viewModel)
            
            present(viewControler, animated: true)
        }
        
        if indexPath.row == 1 {
            
            let viewControler = ScheduleOfTask(delegate: self, wasDatesChosen: scheduleOfTask)
            present(viewControler, animated: true)
        }
    }
}

extension ChosenTaskController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let count: Int
        
        if section == 0 {
            count = emojisArray.count
            collectionView.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: emojiCellIdentifier)
            
        } else {
            collectionView.register(ColorCollectionCell.self, forCellWithReuseIdentifier: colorCellIdentifier)
            
            count = colorsArray.count
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellIdentifier, for: indexPath) as? EmojiCollectionCell else {
                return UICollectionViewCell()
            }
            
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.cellLabel.text = emojisArray[indexPath.row]
            
            if emojisArray[indexPath.row] == emojiOfTask {
                
                cell.isSelected = true
                cell.backgroundColor = .ypMediumLightGray
                chosenEmojiCell = cell
            }
            
            return cell
            
        } else {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCellIdentifier, for: indexPath) as? ColorCollectionCell else {
                return UICollectionViewCell()
            }
            
            cell.colorCell.backgroundColor = colorsArray[indexPath.row]
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 8
            
            if let colorOfTask {
                
                let colorCellHex = colorMarshalling.hexString(from: colorsArray[indexPath.row])
                let taskColorHex = colorMarshalling.hexString(from: colorOfTask)
                
                if colorCellHex == taskColorHex {
                    
                    cell.layer.borderWidth = 3
                    cell.layer.borderColor = colorsArray[indexPath.row].withAlphaComponent(0.3).cgColor
                    chosenColorCell = cell
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderIdentifier, for: indexPath) as? SupplementaryView
        else {
            return UICollectionReusableView()
        }
        
        if indexPath.section == 0 {
            headerView.titleLabel.text = NSLocalizedString("emoji", comment: "")
        } else {
            headerView.titleLabel.text = NSLocalizedString("color", comment: "")
        }
        
        return headerView
    }
}

extension ChosenTaskController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        if cell == chosenColorCell || cell == chosenEmojiCell {
            
            deselectCell(cell, indexPath: indexPath)
        } else {
            selectCell(cell, indexPath: indexPath)
        }
    }
    
    private func deselectCell(_ cell: UICollectionViewCell, indexPath: IndexPath) {
    
        cell.backgroundColor = .clear
        cell.layer.borderWidth = 0
        cell.isSelected = false
        
        if indexPath.section == 0 {
            chosenEmojiCell = nil
            emojiOfTask = nil
        } else {
            chosenColorCell = nil
            colorOfTask = nil
        }
        
        shouldActivateSaveButton()
    }
    
    private func selectCell(_ cell: UICollectionViewCell, indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            deselectPreviousEmoji(of: collectionView)

            chosenEmojiCell = cell
        } else {
            deselectPreviousColor(of: collectionView)
            
            chosenColorCell = cell
        }
        
        if indexPath.section == 0 {
            cell.backgroundColor = .ypColorMilk
            chosenEmojiCell = cell
            emojiOfTask = emojisArray[indexPath.row]
            
        } else {
            
            cell.layer.borderWidth = 3
            cell.layer.borderColor = colorsArray[indexPath.row].withAlphaComponent(0.3).cgColor
            chosenColorCell = cell
            colorOfTask = colorsArray[indexPath.row]
        }
        
        cell.isSelected = true
        
        shouldActivateSaveButton()
    }
}

extension ChosenTaskController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 16
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let text: String
        if section == 0 {
            text = NSLocalizedString("emoji", comment: "")
        } else {
            text = NSLocalizedString("color", comment: "")
        }
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = text
        label.numberOfLines = 0
        
        let width = collectionView.frame.width - 32
        let size = label.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        
        return CGSize(width: collectionView.frame.width, height: size.height)
    }
}

extension ChosenTaskController: ScheduleOfTaskDelegate {
    
    func didDismissScreenWithChanges(dates: [String]) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TableViewCell else {
            return
        }
        
        scheduleOfTask = dates
        shouldAddDates(dates, on: cell)
        shouldActivateSaveButton()
    }
    
    func didRecieveDatesArray(dates: [String]) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TableViewCell else {
            return
        }
        
        scheduleOfTask = dates
        shouldAddDates(dates, on: cell)
        shouldActivateSaveButton()
    }
    
    private func shouldAddDates(_ dates: [String], on cell: TableViewCell){
        
        let daysOfWeek: [String] = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
        
        let sortedDates = dates.sorted { daysOfWeek.firstIndex(of: $0) ?? 0 < daysOfWeek.firstIndex(of: $1) ?? 1}
        
        let datesString: String = sortedDates.map({ date in
            
            if date == daysOfWeek[0] {
                return NSLocalizedString("mon", comment: "")
                
            } else if date == daysOfWeek[1] {
                return NSLocalizedString("tue", comment: "")
                
            } else if date == daysOfWeek[2] {
                return NSLocalizedString("wed", comment: "")
                
            } else if date == daysOfWeek[3] {
                return NSLocalizedString("thu", comment: "")
                
            } else if date == daysOfWeek[4] {
                return NSLocalizedString("fri", comment: "")
                
            } else if date == daysOfWeek[5] {
                return NSLocalizedString("sat", comment: "")
                
            } else if date == daysOfWeek[6] {
                return NSLocalizedString("sun", comment: "")
            }
            
            return ""
        }).joined(separator: ", ")
        
        cell.updateTextOfCellWith(name: tableViewCells[1], text: datesString)
    }
}


extension ChosenTaskController: CategoryModelDelegate{
    func didDismissScreenWithChangesIn(_ category: String?) {
        
        nameOfCategory = category
        
        shouldAddCategoryOnCellTitle(category: category)
        shouldActivateSaveButton()
    }
    
    func didChooseCategory(_ category: String) {
        
        nameOfCategory = category
        shouldAddCategoryOnCellTitle(category: category)
        shouldActivateSaveButton()
    }
    
    private func shouldAddCategoryOnCellTitle(category: String?){
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TableViewCell else { return }
        cell.updateTextOfCellWith(name: tableViewCells[0], text: category ?? "")
    }
}

extension ChosenTaskController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 38
        
        let currentString = (textField.text ?? "") as NSString
        
        let newString = currentString.replacingCharacters(in: range, with: string).trimmingCharacters(in: .newlines)
        
        guard newString.count <= maxLength else {
            
            let limititationText = NSLocalizedString("warning.limititation", comment: "Text before the number of the limit")
            let charatersText = NSLocalizedString("warning.caracters", comment: "Text after the number of the limit")
            
            showWarningLabel(with: limititationText + " \(38) " + charatersText)
            return false
        }
        
        validateNameOfTask(newString)
        shouldActivateSaveButton()
        
        return true
    }
}

//
//  MakeNewCategory.swift
//  Pulse
//
//  Created by Malik Timurkaev on 20.05.2024.
//

import UIKit


final class NewCategoryView: UIViewController {
    
    private let textField = UITextField()
    private let clearTextFieldButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
    private let saveButton = UIButton()
    private let titleLabel = UILabel()
    private let WarningLabel = UILabel()
    
    private var warningLabelBottomConstraint: [NSLayoutConstraint] = []
    private let viewModel: CategoryViewModel
    
    
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        configureTitleLabelView()
        configureTextFieldAndClearButton()
        configureWarningLabel()
        configureSaveButton()
    }
    
    @objc func didEnterTextInTextField(_ sender: UITextField){
        
        guard
            let text = sender.text,
            !text.isEmpty,
            !text.filter({ $0 != Character(" ") }).isEmpty
        else {
            clearTextFieldButtonTapped()
            shouldActivateSaveButton(nil)
            return
        }
        
        shouldActivateSaveButton(text)
        textField.text = text.trimmingCharacters(in: .whitespaces)
    }
    
    @objc func saveButtonTapped(){
        
        let enterCategoryName = NSLocalizedString("warning.enterCategoryName", comment: "Text shows up as warning")
        
        if let nameOfCategory = viewModel.newCategory {
            
            textField.text = nameOfCategory.trimmingCharacters(in: .whitespaces)
            viewModel.storeNewCategory(TaskCategory(titleOfCategory: nameOfCategory, tasksArray: []))
        } else {
            showWarningLabel(with: enterCategoryName)
            highLightButton()
        }
    }
    
    
    @objc func clearTextFieldButtonTapped(){
        textField.text?.removeAll()
    }
    
    private func configureTitleLabelView(){
        let titleLabelText = NSLocalizedString("newCategoryView.title", comment: "Text displayed on the top of screen")
        
        titleLabel.text = titleLabelText
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureTextFieldAndClearButton(){
        let enterNameText = NSLocalizedString("placeholder.enterCategoryName", comment: "")
                
        textField.delegate = self
        textField.backgroundColor = .ypMediumLightGray
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.placeholder = enterNameText
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
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            clearTextFieldButton.widthAnchor.constraint(equalToConstant: clearTextFieldButton.frame.width + 12)
        ])
    }
    
    private func configureWarningLabel(){
        
        WarningLabel.textColor = .ypRed
        WarningLabel.font = UIFont.systemFont(ofSize: 17)
        
        WarningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(WarningLabel)
        view.insertSubview(WarningLabel, belowSubview: textField)
        
        warningLabelBottomConstraint.append(WarningLabel.bottomAnchor.constraint(equalTo: textField.bottomAnchor))
        
        warningLabelBottomConstraint.first?.isActive = true
        WarningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func configureSaveButton(){
        let createButtonTitle = NSLocalizedString("ready", comment: "Text displayed on create button")
        
        saveButton.setTitleColor(.ypWhite, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        saveButton.setTitle(createButtonTitle, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        saveButton.backgroundColor = .ypDarkGray
        saveButton.layer.cornerRadius = 16
        saveButton.layer.masksToBounds = true
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func shouldActivateSaveButton(_ text: String?) {
        
        guard
            let text,
            !text.isEmpty,
            !text.filter({ $0 != Character(" ") }).isEmpty
        else {
            viewModel.updateNameOfNewCategory(nil)
            saveButton.backgroundColor = .ypDarkGray
            return
        }
        
        let newCategory = text.trimmingCharacters(in: .whitespaces)
        viewModel.updateNameOfNewCategory(newCategory)
        saveButton.backgroundColor = .ypBlack
        return
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
    
    private func showWarningLabel(with text: String) {
        
        WarningLabel.text = text
        isTextFieldAndSaveButtonEnabled(bool: false)
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.4, delay: 0.1) {
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
}

extension NewCategoryView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 20
        
        let currentString = (textField.text ?? "") as NSString
        
        let newString = currentString.replacingCharacters(in: range, with: string).trimmingCharacters(in: .newlines)
        
        
        guard newString.count <= maxLength else {
            
            let limititationText = NSLocalizedString("warning.limititation", comment: "Text before the number of the limit")
            let charatersText = NSLocalizedString("warning.caracters", comment: "Text after the number of the limit")
            
            showWarningLabel(with: limititationText + " \(20) " + charatersText)
            return false
        }
        
        shouldActivateSaveButton(newString)
        
        return true
    }
}

extension NewCategoryView: NewCategoryViewProtocol {
    func didStoreNewCategory() {
        dismiss(animated: true)
    }
    
    func categoryAlreadyExists() {
        let categoryAlreadyExists = NSLocalizedString("warning.categoryAlreadyExists", comment: "Text shows up as warning")
        
        showWarningLabel(with: categoryAlreadyExists)
        highLightButton()
    }
}

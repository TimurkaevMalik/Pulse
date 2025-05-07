//
//  CategoryCellView.swift
//  Pulse
//
//  Created by Malik Timurkaev on 19.04.2024.
//

import UIKit


final class CategoryCellView: UITableViewCell {
    
    var nameOfCategory: String?
    let categoryNameLabel = UILabel()
    let textField = UITextField()
    private let clearTextFieldButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
    
    var hidesBottomSeparator = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCategoryNameLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bottomSeparator = subviews.first { $0.frame.minY >= bounds.maxY - 1 && $0.frame.height <= 1 }
        
        bottomSeparator?.isHidden = hidesBottomSeparator
    }
    
    @objc func didEnterTextInTextField(_ sender: UITextField){
        
        guard
            let text = sender.text,
            !text.isEmpty,
            !text.filter({ $0 != Character(" ") }).isEmpty
        else { return }
        
        textField.text = text.trimmingCharacters(in: .whitespaces)
    }
    
    @objc func clearTextFieldButtonTapped(){
        textField.text?.removeAll()
    }
    
    private func configureCategoryNameLabel(){
        categoryNameLabel.text = nameOfCategory
        categoryNameLabel.font = UIFont.systemFont(ofSize: 16)
        
        categoryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubviews([categoryNameLabel])
        
        NSLayoutConstraint.activate([
            categoryNameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 27),
            categoryNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26),
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    func setCornerRadiusForCell(at indexPath: IndexPath, of tableView: UITableView){
    
        let lastRow = tableView.numberOfRows(inSection: indexPath.section) - 1
        self.layer.maskedCorners = []
        self.layer.cornerRadius = 16
        
        if indexPath.row == 0 && indexPath.row == lastRow {
            
            self.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner, .layerMaxXMinYCorner
            ]
        } else if indexPath.row == 0 {
            
            self.layer.maskedCorners = [
                .layerMaxXMinYCorner, .layerMinXMinYCorner
            ]
        } else if indexPath.row == lastRow {
            
            self.layer.maskedCorners = [
                .layerMaxXMaxYCorner, .layerMinXMaxYCorner
            ]
        }
    }
    
    private func configureTextFieldAndClearButton(){
        
        textField.delegate = self
        textField.backgroundColor = .ypMediumLightGray
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.placeholder = "Введите название трекера"
        textField.text = nameOfCategory
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
        contentView.addSubviews([textField])
        
        NSLayoutConstraint.activate([
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            clearTextFieldButton.widthAnchor.constraint(equalToConstant: clearTextFieldButton.frame.width + 12)
        ])
    }
}


extension CategoryCellView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 38
        let currentString = (textField.text ?? "") as NSString
        
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        guard newString.count <= maxLength else { return false }
        
        return true
    }
}

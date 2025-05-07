//
//  TableViewCell.swift
//  Tracker
//
//  Created by Malik Timurkaev on 01.05.2024.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    let cellText = UILabel()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell(){
        
        cellText.numberOfLines = 2
        cellText.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellText)
        
        NSLayoutConstraint.activate([
            cellText.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56)
        ])
    }
    
    
    func updateTextOfCellWith(name: String, text: String){
        let attributedString = NSMutableAttributedString(string:"\(name)\n\(text)")
        attributedString.setColor(UIColor.lightGray, forText: text)
        
        if !text.isEmpty {
            cellText.attributedText = attributedString
            
        } else {
            cellText.text = name
        }
    }
}

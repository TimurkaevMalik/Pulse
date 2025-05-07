//
//  CollorCollectionCell.swift
//  Tracker
//
//  Created by Malik Timurkaev on 29.04.2024.
//

import UIKit

class ColorCollectionCell: UICollectionViewCell {
    
    let colorCell = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureColorCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureColorCell(){
        
        colorCell.layer.masksToBounds = true
        colorCell.layer.cornerRadius = 8
        
        colorCell.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorCell)
        
        NSLayoutConstraint.activate([
            colorCell.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorCell.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            colorCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
    }
}

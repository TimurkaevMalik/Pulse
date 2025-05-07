//
//  EmojiPresenterCell.swift
//  Pulse
//
//  Created by Malik Timurkaev on 29.04.2024.
//

import UIKit

class EmojiCollectionCell: UICollectionViewCell {
    
    let cellLabel = UILabel()
    var emoji: String = ""
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        configureCell()
    }
    
    private func configureCell(){
        
        cellLabel.font = UIFont.systemFont(ofSize: 32)
        cellLabel.textAlignment = .center
        cellLabel.layer.masksToBounds = true
        cellLabel.layer.cornerRadius = 8
        
        
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellLabel)
        
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            cellLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 7),
            cellLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

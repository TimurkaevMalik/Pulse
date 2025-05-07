//
//  StatisticCell.swift
//  Tracker
//
//  Created by Malik Timurkaev on 02.06.2024.
//

import UIKit


class StatisticCell: UITableViewCell {
    
    let viewsContainer = GradientView()
    let cellText = UILabel()
    let statisticNumber = UILabel()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViewsContainer()
        configureStatisticNumber()
        configureCellText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViewsContainer(){
        
        viewsContainer.layer.cornerRadius = 16
        viewsContainer.layer.masksToBounds = true
        viewsContainer.backgroundColor = .ypWhite
        viewsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(viewsContainer)
        
        NSLayoutConstraint.activate([
            viewsContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            viewsContainer.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: 90),
            viewsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func configureStatisticNumber() {
        
        statisticNumber.font = UIFont.boldSystemFont(ofSize: 34)
        statisticNumber.textColor = .ypBlack
        
        statisticNumber.translatesAutoresizingMaskIntoConstraints = false
        viewsContainer.addSubview(statisticNumber)
        
        NSLayoutConstraint.activate([
        
            statisticNumber.topAnchor.constraint(equalTo: viewsContainer.topAnchor, constant: 12),
            statisticNumber.leadingAnchor.constraint(equalTo: viewsContainer.leadingAnchor, constant: 12),
            statisticNumber.trailingAnchor.constraint(equalTo: viewsContainer.trailingAnchor, constant: -12)
        ])
    }
    
    private func configureCellText(){
        
        cellText.numberOfLines = 1
        cellText.backgroundColor = .ypWhite
        cellText.textColor = .ypBlack
        cellText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        cellText.translatesAutoresizingMaskIntoConstraints = false
        viewsContainer.addSubview(cellText)
        
        NSLayoutConstraint.activate([
            cellText.bottomAnchor.constraint(equalTo: viewsContainer.bottomAnchor, constant: -12),
            cellText.leadingAnchor.constraint(equalTo: viewsContainer.leadingAnchor, constant: 12),
            cellText.trailingAnchor.constraint(equalTo: viewsContainer.trailingAnchor, constant: -12)
        ])
    }
}

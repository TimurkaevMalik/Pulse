//
//  CollectionViewCell.swift
//  Tracker
//
//  Created by Malik Timurkaev on 14.04.2024.
//

import UIKit

final class CollectionViewCell: UICollectionViewCell {
    
    weak var delegate: CollectionViewCellDelegate?
    
    var idOfCell: UUID?
    let view = UIView()
    let nameLable = UILabel()
    let emoji = UILabel()
    let daysCount = UILabel()
    let doneButton = UIButton()
    let pinedImageView = UIImageView()
    var count: Int?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLabels()
        configureButton()
        configurepinedImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapDoneButton(){
        
        delegate?.cellPlusButtonTapped(self)
    }
    
    private func configureView(){
        let interction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(interction)
        
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(contentView.frame.height * 2/5)),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func configureLabels(){
        
        nameLable.textAlignment = .left
        nameLable.numberOfLines = 2
        nameLable.font = UIFont.systemFont(ofSize: 12)
        nameLable.textColor = .white
        
        daysCount.font = UIFont.systemFont(ofSize: 12)
        daysCount.textColor = UIColor(named: "YPBlack")
        daysCount.text = "\(String(describing: count)) день"
        
        emoji.backgroundColor = UIColor(named: "YPWhite")?.withAlphaComponent(0.3)
        emoji.layer.cornerRadius = 13
        emoji.layer.masksToBounds = true
        emoji.font = UIFont.systemFont(ofSize: 14)
        emoji.textAlignment = .center
        
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        daysCount.translatesAutoresizingMaskIntoConstraints = false
        emoji.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([nameLable, emoji])
        contentView.addSubview(daysCount)
        NSLayoutConstraint.activate([
            nameLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            nameLable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            nameLable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            
            emoji.widthAnchor.constraint(equalToConstant: 24),
            emoji.heightAnchor.constraint(equalToConstant: 24),
            emoji.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            emoji.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            
            daysCount.widthAnchor.constraint(equalToConstant: 101),
            daysCount.heightAnchor.constraint(equalToConstant: 18),
            daysCount.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCount.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 16)
        ])
    }
    
    private func configureButton(){
        
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        
        doneButton.layer.cornerRadius = 17
        doneButton.layer.masksToBounds = true
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    
    func configurepinedImageView() {
        
        view.addSubview(pinedImageView)
        pinedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pinedImageView.heightAnchor.constraint(equalToConstant: 12),
            pinedImageView.widthAnchor.constraint(equalToConstant: 8),
            pinedImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            pinedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    
    private func highLightButton(){
        
        UIView.animate(withDuration: 0.2) {
            
            self.doneButton.backgroundColor = .red
            
        } completion: { isCompleted in
            if isCompleted {
                resetButtonColor()
            }
        }
        
        func resetButtonColor(){
            UIView.animate(withDuration: 0.2) {
                self.doneButton.backgroundColor = self.view.backgroundColor
            }
        }
    }
    
    func shouldTapButton(_ cell: CollectionViewCell, date selectedDate: Date) -> Bool? {
        
        guard
            var count = cell.count,
            Date() >= selectedDate
        else {
            highLightButton()
            return nil
        }
        
        let locolizedText = NSLocalizedString("numberOfDays", comment: "")
        
        if doneButton.imageView?.image?.pngData() == UIImage(named: "WhitePlus")?.pngData() {
            
            doneButton.setImage(UIImage(named: "CheckMark"), for: .normal)
            doneButton.backgroundColor = view.backgroundColor?.withAlphaComponent(0.3)
            
            self.count = count + 1
            count += 1
            
            daysCount.text = String(format: locolizedText, count)
            
            return true
        } else {
            
            doneButton.setImage(UIImage(named: "WhitePlus"), for: .normal)
            doneButton.backgroundColor = view.backgroundColor?.withAlphaComponent(1)
            
            self.count = count - 1
            count -= 1
            
            daysCount.text = String(format: locolizedText, count)
            
            return false
        }
    }
}

extension CollectionViewCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return delegate?.contextMenuForCell(self)
    }
}

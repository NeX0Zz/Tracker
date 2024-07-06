import UIKit

final class IrregularViewCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "chevron")
        image.tintColor = .gray
        return image
    }()
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        
//        if traitCollection.userInterfaceStyle == .dark {
//            addCategory.setTitleColor(.black, for: .normal)
//            addCategory.backgroundColor = .white
//        } else {
//            addCategory.setTitleColor(.whiteDay, for: .normal)
//            addCategory.backgroundColor = .blackDay
//        }
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .backgroundDay
        clipsToBounds = true
        addSubview(titleLabel)
        addSubview(image)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 24),
            image.heightAnchor.constraint(equalToConstant: 24)
        ])
    } 
    
    func update(with title: String) {
        let attributedText = NSMutableAttributedString(string: title)
        
        if let rangeOfNewLine = title.range(of: "\n") {
            let rangeOfFirstLine = NSRange(title.startIndex..<rangeOfNewLine.lowerBound, in: title)
            let rangeOfSecondLine = NSRange(rangeOfNewLine.upperBound..<title.endIndex, in: title)
            
            attributedText.addAttribute(.foregroundColor, value: UIColor.blackDay, range: rangeOfFirstLine)
            attributedText.addAttribute(.foregroundColor, value: UIColor.grayy, range: rangeOfSecondLine)
        } else {
            attributedText.addAttribute(.foregroundColor, value: UIColor.blackDay, range: NSRange(title.startIndex..<title.endIndex, in: title))
        }
        
        titleLabel.attributedText = attributedText

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

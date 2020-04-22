//
//  ALKFriendGenericCardCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 05/12/18.
//

import Applozic
import Foundation
import Kingfisher

open class ALKFriendGenericCardMessageCell: ALKGenericCardBaseCell {
    var messageView = ALKFriendMessageView()
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func update(viewModel: ALKMessageViewModel, width: CGFloat) {
        messageView.update(viewModel: viewModel)
        let messageWidth = width - (ChatCellPadding.ReceivedMessage.Message.left +
            ChatCellPadding.ReceivedMessage.Message.right)
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        layoutIfNeeded()

        super.update(viewModel: viewModel, width: width)
    }

    override func setupViews() {
        super.setupViews()
        setupCollectionView()

        contentView.addViewsForAutolayout(views: [collectionView, messageView])
        contentView.bringSubviewToFront(messageView)

        let leftPadding = ChatCellPadding.ReceivedMessage.Message.left
        let rightPadding = ChatCellPadding.ReceivedMessage.Message.right
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftPadding).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * rightPadding).isActive = true
        messageViewHeight.isActive = true

        let width = CGFloat(ALKMessageStyle.receivedBubble.widthPadding)
        let templateLeftPadding = leftPadding + 64 - width

        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: templateLeftPadding).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: ALKFriendGenericCardMessageCell.cardTopPadding).isActive = true
        collectionView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.collectionView.rawValue).isActive = true
    }

    open override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let messageWidth = width - (ChatCellPadding.ReceivedMessage.Message.left +
            ChatCellPadding.ReceivedMessage.Message.right)
        let messageHeight = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        let cardHeight = super.cardHeightFor(message: viewModel, width: width)
        return cardHeight + messageHeight + 10 // Extra 10 below complete view. Modify this for club/unclub.
    }

    private func setupCollectionView() {
        let layout: TopAlignedFlowLayout = TopAlignedFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        collectionView = ALKGenericCardCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }
}

open class ALKFriendGenericCardCell: ALKGenericCardBaseCell {
    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 18.5
        layer.masksToBounds = true
        imv.isUserInteractionEnabled = true
        return imv
    }()

    fileprivate var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isOpaque = true
        return label
    }()

    enum Padding {
        enum NameLabel {
            static let top: CGFloat = 6
            static let leading: CGFloat = 57
            static let trailing: CGFloat = 57
            static let height: CGFloat = 16
        }

        enum TimeLabel {
            static let leading: CGFloat = 10
        }

        enum AvatarImageView {
            static let top: CGFloat = 18
            static let bottom: CGFloat = 0
            static let leading: CGFloat = 9
            static let height: CGFloat = 37
            static let width: CGFloat = 37
        }
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupStyle() {
        super.setupStyle()
        nameLabel.setStyle(ALKMessageStyle.displayName)
        timeLabel.setStyle(ALKMessageStyle.time)
    }

    open override func update(viewModel: ALKMessageViewModel, width: CGFloat) {
        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)

        if let url = viewModel.avatarURL {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            avatarImageView.kf.setImage(with: resource, placeholder: placeHolder)
        } else {
            avatarImageView.image = placeHolder
        }
        nameLabel.text = viewModel.displayName
        timeLabel.text = viewModel.time
        layoutIfNeeded()
        super.update(viewModel: viewModel, width: width)
    }

    override func setupViews() {
        super.setupViews()
        setupCollectionView()
        contentView.addViewsForAutolayout(views: [avatarImageView, collectionView, nameLabel, timeLabel])

        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.NameLabel.top).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.NameLabel.leading).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.NameLabel.trailing).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: Padding.NameLabel.height).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: Padding.AvatarImageView.top).isActive = true
        avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: Padding.AvatarImageView.bottom).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.AvatarImageView.leading).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: Padding.AvatarImageView.height).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: Padding.AvatarImageView.width).isActive = true

        let width = CGFloat(ALKMessageStyle.receivedBubble.widthPadding)
        let templateLeftPadding = 64 - width

        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: templateLeftPadding).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: ALKGenericCardBaseCell.cardTopPadding).isActive = true
        collectionView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.collectionView.rawValue).isActive = true

        timeLabel.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: Padding.TimeLabel.leading).isActive = true
        timeLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
    }

    open override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let height: CGFloat = 30 // 6 + 16 + 4 + 2 + 2
        let cardHeight = super.cardHeightFor(message: viewModel, width: width)
        return cardHeight + height + 10 // Extra 10 below complete view. Modify this for club/unclub.
    }

    private func setupCollectionView() {
        let layout: TopAlignedFlowLayout = TopAlignedFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        collectionView = ALKGenericCardCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }
}

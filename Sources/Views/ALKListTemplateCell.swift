//
//  ALKListTemplateCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 18/02/19.
//

import Kingfisher
import UIKit

// MARK: - `ALKListTemplateCell` for sender side.

public class ALKMyMessageListTemplateCell: ALKListTemplateCell {
    var messageView = ALKMyMessageView()
    lazy var messageViewHeight = messageView.heightAnchor.constraint(equalToConstant: 0)

    public override func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)
        super.update(viewModel: viewModel, maxWidth: maxWidth)
    }

    public override class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        let templateHeight = super.rowHeight(viewModel: viewModel, maxWidth: maxWidth)
        return height + templateHeight + paddingBelowCell
    }

    override func setupConstraints() {
        let leftPadding = ChatCellPadding.SentMessage.Message.left
        let rightPadding = ChatCellPadding.SentMessage.Message.right
        contentView.addViewsForAutolayout(views: [messageView, listTemplateView])
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftPadding).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * rightPadding).isActive = true
        messageViewHeight.isActive = true

        let width = CGFloat(ALKMessageStyle.sentBubble.widthPadding)
        let templateLeftPadding = leftPadding + width
        let templateRightPadding = rightPadding - width
        listTemplateView.topAnchor.constraint(equalTo: messageView.bottomAnchor).isActive = true
        listTemplateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: templateLeftPadding).isActive = true
        listTemplateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * templateRightPadding).isActive = true
        listTemplateHeight.isActive = true
    }
}

// MARK: - `ALKListTemplateCell` for receiver side.

public class ALKFriendMessageListTemplateCell: ALKListTemplateCell {
    var messageView = ALKFriendMessageView()
    lazy var messageViewHeight = self.messageView.heightAnchor.constraint(equalToConstant: 0)

    public override func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        let messageWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        messageViewHeight.constant = height
        messageView.update(viewModel: viewModel)
        super.update(viewModel: viewModel, maxWidth: maxWidth)
    }

    public override class func rowHeight(viewModel: ALKMessageViewModel,
                                         maxWidth: CGFloat) -> CGFloat {
        let messageWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.Message.left + ChatCellPadding.ReceivedMessage.Message.right)
        let height = ALKFriendMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        let templateHeight = super.rowHeight(viewModel: viewModel, maxWidth: maxWidth)
        return height + templateHeight + paddingBelowCell + 5 // Padding between messages
    }

    override func setupConstraints() {
        contentView.addViewsForAutolayout(views: [messageView, listTemplateView])

        let leftPadding = ChatCellPadding.ReceivedMessage.Message.left
        let rightPadding = ChatCellPadding.ReceivedMessage.Message.right
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ChatCellPadding.ReceivedMessage.Message.top).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftPadding).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * rightPadding).isActive = true
        messageViewHeight.isActive = true

        let width = CGFloat(ALKMessageStyle.receivedBubble.widthPadding)
        let templateLeftPadding = leftPadding + 64 - width
        let templateRightPadding = rightPadding - width
        listTemplateView.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 5).isActive = true
        listTemplateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: templateLeftPadding).isActive = true
        listTemplateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * templateRightPadding).isActive = true
        listTemplateHeight.isActive = true
    }
}

// MARK: - `ALKMyListTemplateCell` for sender side if text message is not there.

public class ALKMyListTemplateCell: ALKListTemplateCell {
    enum Padding {
        enum StateView {
            static let bottom: CGFloat = 1
            static let right: CGFloat = 2
            static let height: CGFloat = 9
            static let width: CGFloat = 17
        }

        enum TimeLabel {
            static let right: CGFloat = 2
            static let bottom: CGFloat = 2
        }
    }

    // MARK: Fileprivate properties

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    // MARK: - Public methods

    public override func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        super.update(viewModel: viewModel, maxWidth: maxWidth)
        timeLabel.text = viewModel.time
        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }

    public override class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        let messageWidth = maxWidth -
            (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
        let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        let templateHeight = super.rowHeight(viewModel: viewModel, maxWidth: maxWidth)
        return height + templateHeight + paddingBelowCell
    }

    // MARK: - Override methods

    override func setupStyle() {
        super.setupStyle()
        timeLabel.setStyle(ALKMessageStyle.time)
        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }

    override func setupConstraints() {
        let leftPadding = ChatCellPadding.SentMessage.Message.left
        let rightPadding = ChatCellPadding.SentMessage.Message.right
        contentView.addViewsForAutolayout(views: [stateView, timeLabel, listTemplateView])

        let width = CGFloat(ALKMessageStyle.sentBubble.widthPadding)
        let templateLeftPadding = leftPadding + width
        let templateRightPadding = rightPadding - width
        listTemplateView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        listTemplateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: templateLeftPadding).isActive = true
        listTemplateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * templateRightPadding).isActive = true
        listTemplateHeight.isActive = true

        stateView.bottomAnchor.constraint(equalTo: listTemplateView.bottomAnchor, constant: -1 * Padding.StateView.bottom).isActive = true

        stateView.trailingAnchor.constraint(equalTo: listTemplateView.leadingAnchor, constant: -1 * Padding.StateView.right).isActive = true

        stateView.heightAnchor.constraint(equalToConstant: Padding.StateView.height).isActive = true

        stateView.widthAnchor.constraint(equalToConstant: Padding.StateView.width).isActive = true

        timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor).isActive = true

        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -1 * Padding.TimeLabel.right).isActive = true

        timeLabel.bottomAnchor.constraint(equalTo: listTemplateView.bottomAnchor, constant: Padding.TimeLabel.bottom).isActive = true
    }
}

// MARK: - `ALKFriendListTemplateCell` for receiver side if message text is not there.

public class ALKFriendListTemplateCell: ALKListTemplateCell {
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
            static let leading: CGFloat = 9
            static let height: CGFloat = 37
        }
    }

    // MARK: Fileprivate properties

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var bubbleView: UIImageView = {
        let bv = UIImageView()
        bv.clipsToBounds = true
        bv.isUserInteractionEnabled = false
        bv.isOpaque = true
        return bv
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

    // MARK: - Public methods

    public override func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
        if let url = viewModel.avatarURL {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            avatarImageView.kf.setImage(with: resource, placeholder: placeHolder)
        } else {
            avatarImageView.image = placeHolder
        }
        nameLabel.text = viewModel.displayName
        super.update(viewModel: viewModel, maxWidth: maxWidth)
        timeLabel.text = viewModel.time
    }

    public override class func rowHeight(viewModel: ALKMessageViewModel,
                                         maxWidth: CGFloat) -> CGFloat {
        let height: CGFloat = 30 // 6 + 16 + 4 + 2 + 2
        let templateHeight = super.rowHeight(viewModel: viewModel, maxWidth: maxWidth)
        return height + templateHeight + paddingBelowCell + 5 // Padding between messages
    }

    // MARK: - Override methods

    override func setupStyle() {
        super.setupStyle()
        nameLabel.setStyle(ALKMessageStyle.displayName)
        timeLabel.setStyle(ALKMessageStyle.time)
    }

    override func setupConstraints() {
        contentView.addViewsForAutolayout(views: [nameLabel, avatarImageView, listTemplateView, timeLabel])

        let leftPadding = ChatCellPadding.ReceivedMessage.Message.left
        let rightPadding = ChatCellPadding.ReceivedMessage.Message.right

        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.NameLabel.top).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.NameLabel.leading).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.NameLabel.trailing).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: Padding.NameLabel.height).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: Padding.AvatarImageView.top).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.AvatarImageView.leading).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: Padding.AvatarImageView.height).isActive = true
        avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor).isActive = true

        let width = CGFloat(ALKMessageStyle.receivedBubble.widthPadding)
        let templateLeftPadding = leftPadding + 64 - width
        let templateRightPadding = rightPadding - width
        listTemplateView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        listTemplateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: templateLeftPadding).isActive = true
        listTemplateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * templateRightPadding).isActive = true
        listTemplateHeight.isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: listTemplateView.trailingAnchor, constant: Padding.TimeLabel.leading).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: listTemplateView.bottomAnchor).isActive = true
    }
}

// MARK: - `ALKListTemplateCell`

public class ALKListTemplateCell: ALKChatBaseCell<ALKMessageViewModel> {
    static var paddingBelowCell: CGFloat = 10

    var listTemplateView: ListTemplateView = {
        let view = ListTemplateView(frame: .zero)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

    lazy var listTemplateHeight = listTemplateView.heightAnchor.constraint(equalToConstant: 0)

    public var templateSelected: ((_ text: String?, _ action: ListTemplate.Action) -> Void)? {
        didSet {
            listTemplateView.selected = templateSelected
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(viewModel: ALKMessageViewModel, maxWidth _: CGFloat) {
        guard let metadata = viewModel.metadata,
            let template = try? TemplateDecoder.decode(ListTemplate.self, from: metadata) else {
            listTemplateView.isHidden = true
            layoutIfNeeded()
            return
        }
        listTemplateView.isHidden = false
        listTemplateView.update(item: template)
        listTemplateHeight.constant = ListTemplateView.rowHeight(template: template)
        layoutIfNeeded()
    }

    public class func rowHeight(viewModel: ALKMessageViewModel, maxWidth _: CGFloat) -> CGFloat {
        guard let metadata = viewModel.metadata,
            let template = try? TemplateDecoder.decode(ListTemplate.self, from: metadata) else {
            return CGFloat(0)
        }
        return ListTemplateView.rowHeight(template: template)
    }

    func setupConstraints() {
        fatalError("This method must be overriden.")
    }
}

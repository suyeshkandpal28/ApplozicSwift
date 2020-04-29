//
//  ALKFriendQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by apple on 15/04/20.
//

import Foundation
import Kingfisher

public class ALKFriendQuickReplyButtonCell: ALKChatBaseCell<ALKMessageViewModel> {
    enum Padding {
        enum NameLabel {
            static let top: CGFloat = 6
            static let leading: CGFloat = 57
            static let trailing: CGFloat = 57
            static let height: CGFloat = 16
        }

        enum AvatarImageView {
            static let top: CGFloat = 18
            static let leading: CGFloat = 9
            static let height: CGFloat = 37
            static let width: CGFloat = 37
        }

        enum TimeLabel {
            static var leading: CGFloat = 2.0
            static var bottom: CGFloat = 2.0
            static let maxWidth: CGFloat = 200
        }
    }

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

    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    var quickReplyView = SuggestedReplyView()
    var quickReplySelected: ((_ index: Int, _ title: String) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        quickReplyView.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupStyle() {
        super.setupStyle()
        nameLabel.setStyle(ALKMessageStyle.displayName)
        timeLabel.setStyle(ALKMessageStyle.time)
    }

    public func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
        if let url = viewModel.avatarURL {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            avatarImageView.kf.setImage(with: resource, placeholder: placeHolder)
        } else {
            avatarImageView.image = placeHolder
        }
        nameLabel.text = viewModel.displayName
        timeLabel.text = viewModel.time
        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            ReceivedMessageView.Config.TimeLabel.maxWidth,
            font: MessageTheme.receivedMessage.time.font
        )
        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)

        var suggestedReplyData: SuggestedReplyMessage?
        if viewModel.messageType == .button {
            suggestedReplyData = viewModel.linkOrSubmitButton()
        } else if viewModel.messageType == .quickReply {
            suggestedReplyData = viewModel.suggestedReply()
        }
        guard let data = suggestedReplyData else {
            quickReplyView.isHidden = true
            return
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.QuickReply.left + ChatCellPadding.ReceivedMessage.Message.right)
        quickReplyView.update(model: data, maxWidth: quickReplyViewWidth)
    }

    public class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        let minimumHeight: CGFloat = 60 // 55 is avatar image... + padding
        let height: CGFloat = 30 // 6 + 16 + 4 + 2 + 2
        var suggestedReplyData: SuggestedReplyMessage?
        if viewModel.messageType == .button {
            suggestedReplyData = viewModel.linkOrSubmitButton()
        } else if viewModel.messageType == .quickReply {
            suggestedReplyData = viewModel.suggestedReply()
        }

        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        guard let data = suggestedReplyData else {
            return minimumHeight
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.ReceivedMessage.QuickReply.left + ChatCellPadding.ReceivedMessage.Message.right)
        return height
            + SuggestedReplyView.rowHeight(model: data, maxWidth: quickReplyViewWidth)
            + ChatCellPadding.ReceivedMessage.QuickReply.top
            + ChatCellPadding.ReceivedMessage.QuickReply.bottom
            + timeLabelSize.height.rounded(.up)
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [avatarImageView, nameLabel, quickReplyView, timeLabel])
        bringSubviewToFront(avatarImageView)
        bringSubviewToFront(nameLabel)
        bringSubviewToFront(timeLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.NameLabel.top),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.NameLabel.leading),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.NameLabel.trailing),
            nameLabel.heightAnchor.constraint(equalToConstant: Padding.NameLabel.height),

            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: Padding.AvatarImageView.top),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.AvatarImageView.leading),
            avatarImageView.heightAnchor.constraint(equalToConstant: Padding.AvatarImageView.height),
            avatarImageView.widthAnchor.constraint(equalToConstant: Padding.AvatarImageView.width),
            quickReplyView.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: ChatCellPadding.ReceivedMessage.QuickReply.top
            ),
            quickReplyView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: ChatCellPadding.ReceivedMessage.QuickReply.left
            ),
            quickReplyView.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -ChatCellPadding.ReceivedMessage.Message.right
            ),
            quickReplyView.bottomAnchor.constraint(
                equalTo: timeLabel.topAnchor,
                constant: -ChatCellPadding.ReceivedMessage.QuickReply.bottom
            ),
            timeLabel.leadingAnchor.constraint(equalTo: quickReplyView.leadingAnchor, constant: Padding.TimeLabel.leading),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1 * Padding.TimeLabel.bottom),
            timeLabelWidth,
            timeLabelHeight,
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
        ])
    }
}

extension ALKFriendQuickReplyButtonCell: Tappable {
    public func didTap(index: Int?, title: String) {
        guard let quickReplySelected = quickReplySelected, let index = index else { return }
        quickReplySelected(index, title)
    }
}

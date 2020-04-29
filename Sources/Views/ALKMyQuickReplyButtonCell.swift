//
//  ALKMyQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by apple on 15/04/20.
//

import Foundation
import Kingfisher

public class ALKMyQuickReplyButtonCell: ALKChatBaseCell<ALKMessageViewModel> {
    enum Padding {
        enum StateView {
            static let bottom: CGFloat = 2
            static let right: CGFloat = 2
            static let height: CGFloat = 9
            static let width: CGFloat = 17
        }

        enum TimeLabel {
            static let right: CGFloat = 2
            static let left: CGFloat = 2
            static let bottom: CGFloat = 2
            static let maxWidth: CGFloat = 200
        }
    }

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

    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    var quickReplyView = SuggestedReplyView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupStyle() {
        super.setupStyle()
        timeLabel.setStyle(ALKMessageStyle.time)
        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }

    public func update(viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        timeLabel.text = viewModel.time
        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
        var suggestedReplyData: SuggestedReplyMessage?
        if viewModel.messageType == .button {
            suggestedReplyData = viewModel.linkOrSubmitButton()
        } else if viewModel.messageType == .quickReply {
            suggestedReplyData = viewModel.suggestedReply()
        }
        timeLabel.text = viewModel.time
        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            ReceivedMessageView.Config.TimeLabel.maxWidth,
            font: MessageTheme.receivedMessage.time.font
        )
        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)

        guard let data = suggestedReplyData else {
            quickReplyView.isHidden = true
            return
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.SentMessage.QuickReply.left + ChatCellPadding.SentMessage.QuickReply.right)
        quickReplyView.update(model: data, maxWidth: quickReplyViewWidth)
    }

    public class func rowHeight(viewModel: ALKMessageViewModel, maxWidth: CGFloat) -> CGFloat {
        var height: CGFloat = 10 // Padding
        height += 20 // (6 + 4) + 10 for extra padding
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
            return height
        }
        let quickReplyViewWidth = maxWidth -
            (ChatCellPadding.SentMessage.QuickReply.left + ChatCellPadding.SentMessage.QuickReply.right)
        return height
            + SuggestedReplyView.rowHeight(model: data, maxWidth: quickReplyViewWidth)
            + ChatCellPadding.SentMessage.QuickReply.top
            + ChatCellPadding.SentMessage.QuickReply.bottom + timeLabelSize.height.rounded(.up)
    }

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [stateView, timeLabel, quickReplyView])
        bringSubviewToFront(stateView)

        NSLayoutConstraint.activate([
            quickReplyView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: ChatCellPadding.SentMessage.QuickReply.top
            ),
            quickReplyView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -ChatCellPadding.SentMessage.QuickReply.right
            ),
            quickReplyView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: ChatCellPadding.SentMessage.QuickReply.left),
            quickReplyView.bottomAnchor.constraint(
                equalTo: timeLabel.topAnchor,
                constant: -ChatCellPadding.SentMessage.QuickReply.bottom
            ),
            stateView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Padding.StateView.bottom),
            stateView.trailingAnchor.constraint(equalTo: quickReplyView.trailingAnchor, constant: -1 * Padding.StateView.right),
            stateView.heightAnchor.constraint(equalToConstant: Padding.StateView.height),
            stateView.widthAnchor.constraint(equalToConstant: Padding.StateView.width),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Padding.TimeLabel.bottom),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: Padding.TimeLabel.left),
            timeLabelWidth,
            timeLabelHeight,
            timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -1 * Padding.TimeLabel.right),
        ])
    }
}

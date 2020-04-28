//
//  ReceivedButtonsView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 25/09/19.
//

import UIKit

public class ReceivedButtonsCell: UITableViewCell {
    // MARK: - Public properties

    public var tapped: ((_ index: Int, _ name: String) -> Void)?

    public struct Config {
        public static var buttonTopPadding: CGFloat = 4
        public static var padding = Padding(left: 10, right: 60, top: 10, bottom: 10)
        public static var maxWidth = UIScreen.main.bounds.width
        public static var buttonWidth = maxWidth -
            (padding.left + padding.right
                + ReceivedMessageView.Config.ProfileImage.width
                + ReceivedMessageView.Config.MessageView.leftPadding)
    }

    // MARK: - Fileprivate properties

    fileprivate lazy var buttons = SuggestedReplyView()
    fileprivate lazy var messageView = ReceivedMessageView(
        frame: .zero,
        padding: messageViewPadding,
        maxWidth: Config.maxWidth
    )
    fileprivate lazy var messageViewHeight = messageView.heightAnchor.constraint(equalToConstant: 0)
    fileprivate var messageViewPadding: Padding

    // MARK: - Initializer

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        messageViewPadding = Padding(left: Config.padding.left,
                                     right: Config.padding.right,
                                     top: Config.padding.top,
                                     bottom: Config.buttonTopPadding)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buttons.delegate = self
        setupConstraints()
        backgroundColor = .clear
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the `ReceivedButtonsCell`.
    ///
    /// - Parameter model: object that conforms to `SuggestedReplyMessage`
    public func update(model: SuggestedReplyMessage) {
        guard !model.message.isMyMessage else {
            print("😱😱😱Inconsistent information passed to the view.😱😱😱")
            print("For ReceivedMessage value of isMyMessage should be false")
            return
        }
        messageView.update(model: model.message)
        messageViewHeight.constant = ReceivedMessageView.rowHeight(
            model: model.message,
            maxWidth: Config.maxWidth,
            padding: messageViewPadding
        )
        buttons.update(model: model, maxWidth: Config.buttonWidth)
    }

    /// It is used to get exact height of `ReceivedButtonsCell` using messageModel, width and padding
    ///
    /// - Parameters:
    ///   - model: object that conforms to `SuggestedReplyMessage`
    /// - Returns: exact height of the view.
    public static func rowHeight(model: SuggestedReplyMessage) -> CGFloat {
        let messageViewPadding = Padding(left: Config.padding.left,
                                         right: Config.padding.right,
                                         top: Config.padding.top,
                                         bottom: Config.buttonTopPadding)
        let messageHeight = ReceivedMessageView.rowHeight(model: model.message, maxWidth: Config.maxWidth, padding: messageViewPadding)
        let buttonHeight = SuggestedReplyView.rowHeight(model: model, maxWidth: Config.buttonWidth)
        return messageHeight + buttonHeight + Config.padding.bottom
    }

    private func setupConstraints() {
        addViewsForAutolayout(views: [messageView, buttons])
        let leadingMargin =
            Config.padding.left
                + ReceivedMessageView.Config.ProfileImage.width
                + ReceivedMessageView.Config.MessageView.leftPadding
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: topAnchor),
            messageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageViewHeight,

            buttons.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 0),
            buttons.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            buttons.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingMargin),
            buttons.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Config.padding.bottom),
        ])
    }
}

extension ReceivedButtonsCell: Tappable {
    public func didTap(index: Int?, title: String) {
        guard let tapped = tapped, let index = index else { return }
        tapped(index, title)
    }
}

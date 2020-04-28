//
//  ReceivedFAQMessageCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 03/06/19.
//

import UIKit

/// FAQMessageCell for receiver side.
///
/// It contains `FAQMessageView` and `ReceivedMessageView`
/// It also contains `Config` which is used to configure views properties. Values can be changed for customizations.
/// For handling button clicks of FAQMessage, use faqSelected property.
public class ReceivedFAQMessageCell: UITableViewCell {
    // MARK: Public properties

    /// Configuration to adjust padding and maxWidth for the view.
    public struct Config {
        public static var padding = Padding(left: 10, right: 60, top: 10, bottom: 10)
        public static var maxWidth = UIScreen.main.bounds.width
        public static var faqTopPadding: CGFloat = 4
        public static var faqRightPadding: CGFloat = 20
    }

    /// Closure to get callbacks when buttons are tapped.
    public var faqSelected: ((_ index: Int?, _ title: String) -> Void)? {
        didSet {
            faqView.faqSelected = faqSelected
        }
    }

    // MARK: Fileprivate properties

    fileprivate lazy var messageView = ReceivedMessageView(
        frame: .zero,
        padding: messageViewPadding,
        maxWidth: Config.maxWidth
    )

    fileprivate lazy var faqView = FAQMessageView(
        frame: .zero,
        faqStyle: FAQMessageTheme.receivedMessage,
        alignLeft: true
    )

    fileprivate var messageViewPadding: Padding

    fileprivate lazy var messageViewHeight = messageView.heightAnchor.constraint(equalToConstant: 0)

    static var faqWidth = Config.maxWidth - Config.faqRightPadding
        - (Config.padding.left
            + ReceivedMessageView.Config.ProfileImage.width
            + ReceivedMessageView.Config.MessageView.leftPadding)

    // MARK: Initializer

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        messageViewPadding = Padding(left: Config.padding.left,
                                     right: Config.padding.right,
                                     top: Config.padding.top,
                                     bottom: Config.faqTopPadding)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    /// It updates `SentFAQMessageCell`.
    /// Sets FAQmessage, text message, time, name, profile image.
    ///
    /// - Parameter model: `FAQMessage` used to update the cell.
    public func update(model: FAQMessage) {
        guard !model.message.isMyMessage else {
            print("😱😱😱Inconsistent information passed to the view.😱😱😱")
            print("For Received view isMyMessage should be false")
            return
        }
        messageView.update(model: model.message)
        messageViewHeight.constant = ReceivedMessageView.rowHeight(model: model.message, maxWidth: Config.maxWidth, padding: messageViewPadding)

        faqView.update(model: model, maxWidth: ReceivedFAQMessageCell.faqWidth)
        /// Set frame
        let height = ReceivedFAQMessageCell.rowHeight(model: model)
        frame.size = CGSize(width: Config.maxWidth, height: height)
    }

    /// It's used to get the exact height of cell.
    ///
    /// - Parameter model: `FAQMessage` used for updating the cell.
    /// - Returns: Exact height of cell.
    public class func rowHeight(model: FAQMessage) -> CGFloat {
        return FAQMessageSizeCalculator().rowHeight(model: model, maxWidth: Config.maxWidth, padding: Config.padding)
    }

    // MARK: - Private helper methods

    private func setupConstraints() {
        addViewsForAutolayout(views: [messageView, faqView])
        let leadingMargin =
            Config.padding.left
                + ReceivedMessageView.Config.ProfileImage.width
                + ReceivedMessageView.Config.MessageView.leftPadding
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: topAnchor),
            messageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageViewHeight,

            faqView.topAnchor.constraint(equalTo: messageView.bottomAnchor),
            faqView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingMargin),
            faqView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Config.faqRightPadding),
            faqView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Config.padding.bottom),
        ])
    }
}

/// FAQMessageCell for receiver side.
///
/// It contains `FAQMessageView`
/// It also contains `Config` which is used to configure views properties. Values can be changed for customizations.
/// For handling button clicks of FAQMessage, use faqSelected property.
public class ReceivedFAQCell: UITableViewCell {
    // MARK: Public properties

    /// Configuration to adjust padding and maxWidth for the view.
    public struct Config {
        public static var padding = Padding(left: 10, right: 60, top: 10, bottom: 10)
        public static var maxWidth = UIScreen.main.bounds.width
        public static var faqTopPadding: CGFloat = 4
        public static var faqRightPadding: CGFloat = 20
    }

    /// Closure to get callbacks when buttons are tapped.
    public var faqSelected: ((_ index: Int?, _ title: String) -> Void)? {
        didSet {
            faqView.faqSelected = faqSelected
        }
    }

    // MARK: Fileprivate properties

    fileprivate lazy var faqView = FAQMessageView(
        frame: .zero,
        faqStyle: FAQMessageTheme.receivedMessage,
        alignLeft: true
    )

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.setStyle(MessageTheme.receivedMessage.time)
        lb.isOpaque = true
        return lb
    }()

    fileprivate var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage(named: "contact-placeholder", in: Bundle.richMessageKit, compatibleWith: nil)
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        imv.layer.cornerRadius = 18.5
        imv.layer.masksToBounds = true
        imv.isUserInteractionEnabled = true
        return imv
    }()

    fileprivate var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.setStyle(MessageTheme.receivedMessage.displayName)
        label.isOpaque = true
        return label
    }()

    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    static var faqWidth = Config.maxWidth - Config.faqRightPadding
        - (Config.padding.left
            + ReceivedMessageView.Config.ProfileImage.width
            + ReceivedMessageView.Config.MessageView.leftPadding)

    // MARK: Initializer

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    /// It updates `SentFAQMessageCell`.
    /// Sets FAQmessage, text message, time, name, profile image.
    ///
    /// - Parameter model: `FAQMessage` used to update the cell.
    public func update(model: FAQMessage) {
        guard !model.message.isMyMessage else {
            print("😱😱😱Inconsistent information passed to the view.😱😱😱")
            print("For Received view isMyMessage should be false")
            return
        }

        faqView.update(model: model, maxWidth: ReceivedFAQMessageCell.faqWidth)
        /// Set frame
        let height = ReceivedFAQCell.rowHeight(model: model)
        frame.size = CGSize(width: Config.maxWidth, height: height)

        // Set time

        timeLabel.text = model.message.time
        let timeLabelSize = model.message.time.rectWithConstrainedWidth(
            ReceivedMessageView.Config.TimeLabel.maxWidth,
            font: MessageTheme.receivedMessage.time.font
        )
        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)

        // Set name
        nameLabel.text = model.message.displayName

        guard let url = model.message.imageURL else { return }
        ImageCache.downloadImage(url: url) { [weak self] image in
            guard let image = image else { return }
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }
    }

    /// It's used to get the exact height of cell.
    ///
    /// - Parameter model: `FAQMessage` used for updating the cell.
    /// - Returns: Exact height of cell.
    public class func rowHeight(model: FAQMessage) -> CGFloat {
        let config = ReceivedMessageView.Config.self

        let totalHeightPadding = Config.padding.top + Config.padding.bottom
        let calculatedHeight = totalHeightPadding + config.DisplayName.height

        let timeLabelSize = model.message.time.rectWithConstrainedWidth(
            ReceivedMessageView.Config.TimeLabel.maxWidth,
            font: MessageTheme.receivedMessage.time.font)

        let faqHeight = FAQMessageView.rowHeight(model: model, maxWidth: ReceivedFAQMessageCell.faqWidth, style: FAQMessageTheme.receivedMessage)

        return calculatedHeight + faqHeight + timeLabelSize.height.rounded(.up)
    }

    // MARK: - Private helper methods

    private func setupConstraints() {
        let nameRightPadding = max(Config.padding.right, ReceivedMessageView.Config.DisplayName.rightPadding)
        addViewsForAutolayout(views: [avatarImageView, nameLabel, faqView, timeLabel])
        let leadingMargin =
            Config.padding.left
                + ReceivedMessageView.Config.ProfileImage.width
                + ReceivedMessageView.Config.MessageView.leftPadding
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: ReceivedMessageView.Config.ProfileImage.topPadding),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Config.padding.left),
            avatarImageView.widthAnchor.constraint(equalToConstant: ReceivedMessageView.Config.ProfileImage.width),
            avatarImageView.heightAnchor.constraint(equalToConstant: ReceivedMessageView.Config.ProfileImage.height),

            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Config.padding.top),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: ReceivedMessageView.Config.DisplayName.leftPadding),
            nameLabel.heightAnchor.constraint(equalToConstant: ReceivedMessageView.Config.DisplayName.height),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -1 * nameRightPadding),

            faqView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            faqView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingMargin),
            faqView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Config.faqRightPadding),
            faqView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -1 * Config.padding.bottom),

            timeLabel.leadingAnchor.constraint(equalTo: faqView.leadingAnchor, constant: ReceivedMessageView.Config.TimeLabel.leftPadding),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Config.padding.bottom),
            timeLabelWidth,
            timeLabelHeight,
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -1 * Config.padding.right),
        ])
    }
}

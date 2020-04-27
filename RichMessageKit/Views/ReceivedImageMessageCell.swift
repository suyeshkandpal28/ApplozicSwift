//
//  ReceivedImageMessageView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 20/05/19.
//

import UIKit

public class ReceivedImageMessageCell: UITableViewCell {
    // MARK: - Public properties

    /// It is used to inform the delegate that the image is tapped. URL of tapped image is sent.
    public var delegate: Tappable?

    public struct Config {
        public static var imageBubbleTopPadding: CGFloat = 4
        public static var padding = Padding(left: 10, right: 60, top: 10, bottom: 10)
        public static var maxWidth = UIScreen.main.bounds.width
    }

    // MARK: - Private properties

    fileprivate lazy var messageView = ReceivedMessageView(
        frame: .zero,
        padding: messageViewPadding,
        maxWidth: Config.maxWidth
    )

    fileprivate var messageViewPadding: Padding
    fileprivate var imageBubble: ImageContainer
    fileprivate var imageBubbleWidth: CGFloat
    fileprivate lazy var messageViewHeight = messageView.heightAnchor.constraint(equalToConstant: 0)
    fileprivate var imageUrl: String?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        messageViewPadding = Padding(left: Config.padding.left,
                                     right: Config.padding.right,
                                     top: Config.padding.top,
                                     bottom: Config.imageBubbleTopPadding)
        imageBubble = ImageContainer(frame: .zero, maxWidth: Config.maxWidth, isMyMessage: false)
        imageBubbleWidth = Config.maxWidth * ImageBubbleTheme.receivedMessage.widthRatio
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        setupGesture()
        backgroundColor = .clear
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updated the `ImageMessageView`.
    ///
    /// - WARNING: `MessageModel`'s isMyMessage should be same as what is passed in initialization.
    /// - Parameter model: object that conforms to `MessageModel`
    public func update(model: ImageMessage) {
        guard !model.message.isMyMessage else {
            print("😱😱😱Inconsistent information passed to the view.😱😱😱")
            print("For Received view isMyMessage should be false")
            return
        }
        messageView.update(model: model.message)
        messageViewHeight.constant = ReceivedMessageView.rowHeight(model: model.message, maxWidth: Config.maxWidth, padding: messageViewPadding)

        /// Set frame
        let height = ReceivedImageMessageCell.rowHeight(model: model)
        frame.size = CGSize(width: Config.maxWidth, height: height)

        imageUrl = model.url
        imageBubble.update(model: model)
    }

    /// It is used to get exact height of `ImageMessageView` using messageModel, width and padding
    ///
    /// - NOTE: Font is not used. Change `ImageBubbleStyle.captionStyle.font`
    /// - Parameters:
    ///   - model: object that conforms to `ImageMessage`
    /// - Returns: exact height of the view.
    public static func rowHeight(model: ImageMessage) -> CGFloat {
        return ImageMessageViewSizeCalculator().rowHeight(model: model, maxWidth: Config.maxWidth, padding: Config.padding)
    }

    private func setupConstraints() {
        addViewsForAutolayout(views: [messageView, imageBubble])
        let leadingMargin =
            Config.padding.left
                + ReceivedMessageView.Config.ProfileImage.width
                + ReceivedMessageView.Config.MessageView.leftPadding
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: topAnchor),
            messageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageViewHeight,

            imageBubble.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 0),
            imageBubble.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingMargin),
            imageBubble.widthAnchor.constraint(equalToConstant: imageBubbleWidth),
            imageBubble.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Config.padding.bottom),
        ])
    }

    @objc private func imageTapped() {
        guard let delegate = delegate else {
            print("❌❌❌ Delegate is not set. To handle image click please set delegate.❌❌❌")
            return
        }
        guard let imageUrl = imageUrl else {
            print("😱😱😱 ImageUrl is found nil. 😱😱😱")
            return
        }
        delegate.didTap(index: 0, title: imageUrl)
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGesture.numberOfTapsRequired = 1
        imageBubble.addGestureRecognizer(tapGesture)
    }
}

public class ReceivedImageCell: UITableViewCell {
    // MARK: - Public properties

    /// It is used to inform the delegate that the image is tapped. URL of tapped image is sent.
    public var delegate: Tappable?

    public struct Config {
        public static var imageBubbleTopPadding: CGFloat = 4
        public static var padding = Padding(left: 10, right: 60, top: 10, bottom: 10)
        public static var maxWidth = UIScreen.main.bounds.width
    }

    // MARK: - Private properties

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

    fileprivate var imageBubble: ImageContainer
    fileprivate var imageBubbleWidth: CGFloat
    fileprivate var imageUrl: String?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        imageBubble = ImageContainer(frame: .zero, maxWidth: Config.maxWidth, isMyMessage: false)
        imageBubbleWidth = Config.maxWidth * ImageBubbleTheme.receivedMessage.widthRatio
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        setupGesture()
        backgroundColor = .clear
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updated the `ImageMessageView`.
    ///
    /// - WARNING: `MessageModel`'s isMyMessage should be same as what is passed in initialization.
    /// - Parameter model: object that conforms to `MessageModel`
    public func update(model: ImageMessage) {
        guard !model.message.isMyMessage else {
            print("😱😱😱Inconsistent information passed to the view.😱😱😱")
            print("For Received view isMyMessage should be false")
            return
        }
        nameLabel.text = model.message.displayName
        timeLabel.text = model.message.time

        /// Set frame
        let height = ReceivedImageCell.rowHeight(model: model)
        frame.size = CGSize(width: Config.maxWidth, height: height)

        imageUrl = model.url
        imageBubble.update(model: model)

        guard let url = model.message.imageURL else { return }
        ImageCache.downloadImage(url: url) { [weak self] image in
            guard let image = image else { return }
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }
    }

    /// It is used to get exact height of `ImageMessageView` using messageModel, width and padding
    ///
    /// - NOTE: Font is not used. Change `ImageBubbleStyle.captionStyle.font`
    /// - Parameters:
    ///   - model: object that conforms to `ImageMessage`
    /// - Returns: exact height of the view.
    public static func rowHeight(model: ImageMessage) -> CGFloat {
        let config = ReceivedMessageView.Config.self

        let totalHeightPadding = Config.padding.top + Config.padding.bottom
        let calculatedHeight = totalHeightPadding + config.DisplayName.height
        let imageBubbleHeight = ImageBubbleSizeCalculator().rowHeight(model: model, maxWidth: Config.maxWidth)
        return calculatedHeight + imageBubbleHeight + Config.padding.bottom + Config.padding.top
    }

    private func setupConstraints() {
        let nameRightPadding = max(Config.padding.right, ReceivedMessageView.Config.DisplayName.rightPadding)
        addViewsForAutolayout(views: [avatarImageView, nameLabel, imageBubble, timeLabel])
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

            imageBubble.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            imageBubble.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingMargin),
            imageBubble.widthAnchor.constraint(equalToConstant: imageBubbleWidth),
            imageBubble.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Config.padding.bottom),

            timeLabel.leadingAnchor.constraint(equalTo: imageBubble.trailingAnchor, constant: ReceivedMessageView.Config.TimeLabel.leftPadding),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Config.padding.bottom),
            timeLabelWidth,
            timeLabelHeight,
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -1 * Config.padding.right),
        ])
    }

    @objc private func imageTapped() {
        guard let delegate = delegate else {
            print("❌❌❌ Delegate is not set. To handle image click please set delegate.❌❌❌")
            return
        }
        guard let imageUrl = imageUrl else {
            print("😱😱😱 ImageUrl is found nil. 😱😱😱")
            return
        }
        delegate.didTap(index: 0, title: imageUrl)
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGesture.numberOfTapsRequired = 1
        imageBubble.addGestureRecognizer(tapGesture)
    }
}

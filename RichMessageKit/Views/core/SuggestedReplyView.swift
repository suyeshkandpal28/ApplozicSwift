//
//  SuggestedReplyView.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 18/01/19.
//

import UIKit

/// It's a staggered grid view of buttons.
///
/// Use `alignLeft` property to align the buttons to left or right side.
/// Use `maxWidth` property if view has to be constrained with some maximum width.
/// Pass custom `SuggestedReplyConfig` to modify font and color of view.
/// - NOTE: It uses an array of dictionary where each dictionary should have `title` key which will be used as button text.
public class SuggestedReplyView: UIView {
    // MARK: Public properties

    /// Configuration for SuggestedReplyView.
    /// It will configure font and color of suggested reply buttons.
    public struct SuggestedReplyConfig {
        public var font = UIFont.systemFont(ofSize: 14)
        public var color = UIColor(red: 85, green: 83, blue: 183)
        public init() {}
    }

    // MARK: Internal properties

    // This is used to align the view to left or right. Gets value from message.isMyMessage
    var alignLeft: Bool = true

    let font: UIFont
    let color: UIColor
    weak var delegate: Tappable?

    var model: SuggestedReplyMessage?

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: Initializers

    /// Initializer for `SuggestedReplyView`
    ///
    /// - Parameters:
    ///   - maxWidth: Max Width to constrain view.
    /// Gives information about the title and index of quick reply selected. Indexing starts from 1.
    public init(config: SuggestedReplyConfig = SuggestedReplyConfig()) {
        font = config.font
        color = config.color
        super.init(frame: .zero)
        setupConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public methods

    /// Creates Suggested reply buttons using dictionary.
    ///
    /// - Parameter - model: Object that conforms to `SuggestedReplyMessage`.
    public func update(model: SuggestedReplyMessage, maxWidth: CGFloat) {
        self.model = model
        /// Set frame size.
        let width = maxWidth
        let height = SuggestedReplyView.rowHeight(model: model, maxWidth: width, font: font)
        let size = CGSize(width: width, height: height)
        frame.size = size

        alignLeft = !model.message.isMyMessage

        setupSuggestedReplyButtons(model, maxWidth: maxWidth)
    }

    /// It calculates height of `SuggestedReplyView` based on the dictionary passed.
    ///
    /// - NOTE: Padding is not used.
    /// - Parameters:
    ///   - model: Object that conforms to `SuggestedReplyModel`.
    ///   - maxWidth: MaxWidth to constrain view. pass same value used while initialization.
    ///   - font: Font for suggested replies. Pass the custom SuggestedReplyConfig font used while initialization.
    /// - Returns: Returns height of view based on passed parameters.
    public static func rowHeight(model: SuggestedReplyMessage,
                                 maxWidth: CGFloat,
                                 font: UIFont = SuggestedReplyConfig().font) -> CGFloat {
        return SuggestedReplyViewSizeCalculator().rowHeight(model: model, maxWidth: maxWidth, font: font)
    }

    // MARK: Private methods

    private func setupConstraints() {
        addViewsForAutolayout(views: [mainStackView])
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func setupSuggestedReplyButtons(_ suggestedMessage: SuggestedReplyMessage, maxWidth: CGFloat) {
        mainStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        var width: CGFloat = 0
        var subviews = [UIView]()
        for index in 0 ..< suggestedMessage.suggestion.count {
            let title = suggestedMessage.suggestion[index].title
            let type = suggestedMessage.suggestion[index].type
            var button: CurvedImageButton!
            if type == .link {
                let image = UIImage(named: "link", in: Bundle.richMessageKit, compatibleWith: nil)
                button = curvedButton(title: title, image: image, index: index, maxWidth: maxWidth)
            } else {
                button = curvedButton(title: title, image: nil, index: index, maxWidth: maxWidth)
            }
            width += button.buttonWidth() + 10 // Button Padding

            if width >= maxWidth {
                guard !subviews.isEmpty else {
                    let stackView = horizontalStackView(subviews: [button])
                    mainStackView.addArrangedSubview(stackView)
                    width = 0
                    continue
                }
                let hiddenView = hiddenViewUsing(currWidth: width - button.buttonWidth(), maxWidth: maxWidth, subViews: subviews)
                alignLeft ? subviews.append(hiddenView) : subviews.insert(hiddenView, at: 0)
                width = button.buttonWidth() + 10
                let stackView = horizontalStackView(subviews: subviews)
                mainStackView.addArrangedSubview(stackView)
                subviews.removeAll()
                subviews.append(button)
            } else {
                subviews.append(button)
            }
        }
        let hiddenView = hiddenViewUsing(currWidth: width, maxWidth: maxWidth, subViews: subviews)
        alignLeft ? subviews.append(hiddenView) : subviews.insert(hiddenView, at: 0)
        let stackView = horizontalStackView(subviews: subviews)
        mainStackView.addArrangedSubview(stackView)
    }

    private func horizontalStackView(subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }

    private func hiddenViewUsing(currWidth: CGFloat, maxWidth: CGFloat, subViews _: [UIView]) -> UIView {
        let unusedWidth = maxWidth - currWidth - 20
        let height = (subviews[0] as? CurvedImageButton)?.buttonHeight() ?? 0
        let size = CGSize(width: unusedWidth, height: height)

        let view = UIView()
        view.backgroundColor = .clear
        view.frame.size = size
        return view
    }

    private func curvedButton(title: String, image: UIImage?, index: Int, maxWidth: CGFloat) -> CurvedImageButton {
        let button = CurvedImageButton(title: title, image: image, maxWidth: maxWidth)
        button.delegate = self
        button.index = index
        return button
    }
}

extension SuggestedReplyView: Tappable {
    public func didTap(index: Int?, title: String) {
        guard let index = index, let suggestion = model?.suggestion[index] else { return }
        let replyToBeSend = suggestion.reply ?? title
        delegate?.didTap(index: index, title: replyToBeSend)
    }
}

//
//  ALKVideoCell.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 10/07/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import Applozic
import AVKit

class ALKVideoCell: ALKChatBaseCell<ALKMessageViewModel>,
                    ALKReplyMenuItemProtocol,ALKReportMessageMenuItemProtocol {

    enum State {
        case download
        case downloading(progress: Double, totalCount: Int64)
        case downloaded(filePath: String)
        case upload
    }

    var photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    var timeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()

    var fileSizeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()

    fileprivate var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.isHidden = true
        return button
    }()

    fileprivate var downloadButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "DownloadiOS", in: Bundle.applozic, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor.black
        return button
    }()

    fileprivate var playButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "PLAY", in: Bundle.applozic, compatibleWith: nil)
        button.setImage(image, for: .normal)
        return button
    }()

    fileprivate var uploadButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "UploadiOS2", in: Bundle.applozic, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor.black
        return button
    }()

    fileprivate let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "close", in: Bundle.applozic, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.isHidden = true
        return button
    }()

    var bubbleView: UIView = {
        let bv = UIView()
        bv.clipsToBounds = true
        bv.isUserInteractionEnabled = false
        return bv
    }()

    var progressView: KDCircularProgress = {
        let view = KDCircularProgress(frame: .zero)
        view.startAngle = -90
        view.clockwise = true
        return view
    }()

    private var frontView: ALKTappableView = {
        let view = ALKTappableView()
        view.alpha = 1.0
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()

    var url: URL?

    var uploadTapped:((Bool) ->Void)?
    var uploadCompleted: ((_ responseDict: Any?) ->Void)?

    var downloadTapped:((Bool) ->Void)?

    class func topPadding() -> CGFloat {
        return 12
    }

    class func bottomPadding() -> CGFloat {
        return 16
    }

    override class func rowHeigh(viewModel: ALKMessageViewModel,width: CGFloat) -> CGFloat {

        let heigh: CGFloat

        if viewModel.ratio < 1 {
            heigh = viewModel.ratio == 0 ? (width*0.48) : ceil((width*0.48)/viewModel.ratio)
        } else {
            heigh = ceil((width*0.64)/viewModel.ratio)
        }

        return topPadding()+heigh+bottomPadding()
    }

    override func update(viewModel: ALKMessageViewModel) {

        self.viewModel = viewModel
        timeLabel.text = viewModel.time

        if viewModel.isMyMessage {
            if viewModel.isSent || viewModel.isAllRead || viewModel.isAllReceived {
                if let filePath = viewModel.filePath, !filePath.isEmpty {
                    updateView(for: State.downloaded(filePath: filePath))
                } else {
                    if SessionQueue.shared.containsSession(withIdentifier: viewModel.identifier) {
                        updateView(for: State.downloading(progress: 0, totalCount: 0))
                    } else {
                        updateView(for: State.download)
                    }
                }
            } else {
                if SessionQueue.shared.containsSession(withIdentifier: viewModel.identifier) {
                    updateView(for: State.downloading(progress: 0, totalCount: 0))
                } else {
                    updateView(for: State.upload)
                }
            }
        } else {
            if let filePath = viewModel.filePath, !filePath.isEmpty {
                updateView(for: State.downloaded(filePath: filePath))
            } else {
                if SessionQueue.shared.containsSession(withIdentifier: viewModel.identifier) {
                    updateView(for: State.downloading(progress: 0, totalCount: 0))
                } else {
                    updateView(for: State.download)
                }
            }
        }

    }

    @objc func actionTapped(button: UIButton) {
        button.isEnabled = false
    }

    override func setupStyle() {
        super.setupStyle()

        timeLabel.setStyle(ALKMessageStyle.time)
        fileSizeLabel.setStyle(ALKMessageStyle.time)
    }

    override func setupViews() {
        super.setupViews()
        playButton.isHidden = true
        progressView.isHidden = true
        uploadButton.isHidden = true

        frontView.addGestureRecognizer(longPressGesture)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)

        contentView.addViewsForAutolayout(views: [frontView, photoView,bubbleView, timeLabel,fileSizeLabel, downloadButton, playButton, progressView, uploadButton, cancelButton])
        contentView.bringSubviewToFront(photoView)
        contentView.bringSubviewToFront(frontView)
        contentView.bringSubviewToFront(actionButton)
        contentView.bringSubviewToFront(downloadButton)
        contentView.bringSubviewToFront(playButton)
        contentView.bringSubviewToFront(progressView)
        contentView.bringSubviewToFront(uploadButton)
        contentView.bringSubviewToFront(cancelButton)

        frontView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        frontView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        frontView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        frontView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true

        bubbleView.topAnchor.constraint(equalTo: photoView.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: photoView.bottomAnchor).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: photoView.leftAnchor).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: photoView.rightAnchor).isActive = true

        downloadButton.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        downloadButton.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        downloadButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        downloadButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

        uploadButton.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        uploadButton.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        uploadButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        uploadButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

        playButton.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 60).isActive = true

        progressView.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: 60).isActive = true

        cancelButton.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

        fileSizeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
    }

    deinit {
        actionButton.removeTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }

    func menuReply(_ sender: Any) {
        menuAction?(.reply)
    }

    func menuReport(_ sender: Any) {
        menuAction?(.reportMessage)
    }

    @objc private func buttonAction(_ selector: UIButton) {
        switch selector {
        case downloadButton:
            updateView(for: .downloading(progress: 0, totalCount: 0))
            downloadTapped?(true)
        case uploadButton:
            uploadTapped?(true)
        case cancelButton:
            guard let viewModel = viewModel else { return }
            if SessionQueue.shared.cancelSession(withIdentifier: viewModel.identifier) {
                if let filePath = viewModel.filePath, !filePath.isEmpty {
                    updateView(for: .upload)
                } else {
                    updateView(for: .download)
                }
            }
        case playButton:
            let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.mediaViewer, bundle: Bundle.applozic)

            let nav = storyboard.instantiateInitialViewController() as? UINavigationController
            let vc = nav?.viewControllers.first as? ALKMediaViewerViewController
            let dbService = ALMessageDBService()
            guard let messages = dbService.getAllMessagesWithAttachment(
                forContact: viewModel?.contactId,
                andChannelKey: viewModel?.channelKey,
                onlyDownloadedAttachments: true) as? [ALMessage] else { return }

            let messageModels = messages.map { $0.messageModel }
            NSLog("Messages with attachment: ", messages )

            guard let viewModel = viewModel as? ALKMessageModel,
                let currentIndex = messageModels.index(of: viewModel) else { return }
            vc?.viewModel = ALKMediaViewerViewModel(messages: messageModels, currentIndex: currentIndex, localizedStringFileName: localizedStringFileName)
            UIViewController.topViewController()?.present(nav!, animated: true, completion: {
                self.playButton.isEnabled = true
            })
        default:
            print("Do nothing")
        }
    }

    fileprivate func updateView(for state: State) {
        switch state {
        case .download:
            uploadButton.isHidden = true
            downloadButton.isHidden = false
            photoView.image = UIImage(named: "VIDEO", in: Bundle.applozic, compatibleWith: nil)
            playButton.isHidden = true
            progressView.isHidden = true
            cancelButton.isHidden = true
        case .downloaded(let filePath):
            uploadButton.isHidden = true
            downloadButton.isHidden = true
            progressView.isHidden = true
            cancelButton.isHidden = true
            viewModel?.filePath = filePath
            playButton.isHidden = false
            let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = docDirPath.appendingPathComponent(filePath)
            photoView.image = getThumbnail(filePath: path)
            
        case .downloading(let progress, _):
            // show progress bar
            print("downloading")
            uploadButton.isHidden = true
            downloadButton.isHidden = true
            playButton.isHidden = true
            progressView.isHidden = false
            cancelButton.isHidden = false
            progressView.angle = progress
            photoView.image = UIImage(named: "VIDEO", in: Bundle.applozic, compatibleWith: nil)
        case .upload:
            downloadButton.isHidden = true
            progressView.isHidden = true
            cancelButton.isHidden = true
            playButton.isHidden = true
            photoView.image = UIImage(named: "VIDEO", in: Bundle.applozic, compatibleWith: nil)
            uploadButton.isHidden = false

        }
    }

    private func getThumbnail(filePath: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: filePath , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)

        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

    func isCallbackForCurrentCell(_ taskId: String?) -> Bool {
        guard
            let messageId = viewModel?.identifier,
            let taskId = taskId,
            taskId.contains(messageId)
            else {
                return false
        }
        return true
    }
}

extension ALKVideoCell: ALKHTTPManagerUploadDelegate {
    func dataUploaded(task: ALKUploadTask) {
        if !isCallbackForCurrentCell(task.identifier) {
            return
        }
        NSLog("Data uploaded: \(task.totalBytesUploaded) out of total: \(task.totalBytesExpectedToUpload)")
        let progress = task.totalBytesUploaded.degree(outOf: task.totalBytesExpectedToUpload)
        self.updateView(for: .downloading(progress: progress, totalCount: task.totalBytesExpectedToUpload))
    }

    func dataUploadingFinished(task: ALKUploadTask) {
        if !isCallbackForCurrentCell(task.identifier) {
            return
        }
        NSLog("VIDEO CELL DATA UPLOADED FOR PATH: %@", viewModel?.filePath ?? "")
        if task.uploadError == nil && task.completed == true && task.filePath != nil {
            DispatchQueue.main.async {
                self.updateView(for: State.downloaded(filePath: task.filePath ?? ""))
            }
        } else {
            DispatchQueue.main.async {
                self.updateView(for: .upload)
            }
        }
    }
}

extension ALKVideoCell: ALKHTTPManagerDownloadDelegate {
    func dataDownloaded(task: ALKDownloadTask) {
        if !isCallbackForCurrentCell(task.identifier) {
            return
        }
        NSLog("VIDEO CELL DATA UPDATED AND FILEPATH IS: %@", viewModel?.filePath ?? "")
        let total = task.totalBytesExpectedToDownload
        let progress = task.totalBytesDownloaded.degree(outOf: total)
        self.updateView(for: .downloading(progress: progress, totalCount: total))
    }

    func dataDownloadingFinished(task: ALKDownloadTask) {
        guard task.downloadError == nil, let filePath = task.filePath, let identifier = task.identifier, let _ = self.viewModel else {
            if isCallbackForCurrentCell(task.identifier) {
                updateView(for: .download)
            }
            return
        }
        ALMessageDBService().updateDbMessageWith(key: "key", value: identifier, filePath: filePath)
        DispatchQueue.main.async {
            if self.isCallbackForCurrentCell(task.identifier) {
                self.updateView(for: .downloaded(filePath: filePath))
            }
        }
    }
}

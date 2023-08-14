//
//  InputLinkViewController.swift
//  IJKMediaPlayerDemo
//
//  Created by Thu Le on 19/07/2022.
//  Copyright © 2022 BeLive. All rights reserved.
//

import Foundation
import UIKit
import IJKMediaFramework

// let urlStr = "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
// let urlStr = "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
let urlStr = "https://68789.liveplay.myqcloud.com/live/avplayerTest.m3u8"

class InputLinkViewController: UIViewController {
    @IBOutlet weak var linkTextView: UITextView! {
        didSet {
            linkTextView.layer.borderColor = UIColor.gray.cgColor
            linkTextView.layer.borderWidth = 1
            linkTextView.text = urlStr
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func playButtonTapped(sender: Any?) {
        guard let url = linkTextView.text, !url.isEmpty else { return }

        PlayerViewController.present(in: self, with: url)
    }
}

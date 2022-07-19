//
//  InputLinkViewController.swift
//  IJKMediaPlayerDemo
//
//  Created by Thu Le on 19/07/2022.
//  Copyright © 2022 lee5783. All rights reserved.
//

import Foundation
import UIKit
import IJKMediaFramework

class InputLinkViewController: UIViewController {
    @IBOutlet weak var linkTextView: UITextView! {
        didSet {
            linkTextView.layer.borderColor = UIColor.gray.cgColor
            linkTextView.layer.borderWidth = 1
            linkTextView.text = "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
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

//
//  PlayerViewController.swift
//  IJKMediaPlayerDemo
//
//  Created by Thu Le on 19/07/2022.
//  Copyright © 2022 BeLive. All rights reserved.
//

import UIKit
import IJKMediaFramework

class PlayerViewController: UIViewController {
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerControlsView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var curentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var seekbar: UISlider!
    private var isSliderDragging = false

    public private(set) var url: URL!
    private var player: IJKMediaPlayback?

    private var timer: Timer?

    static func present(in controller: UIViewController, with urlString: String) {
        let storyboard = UIStoryboard(name: "MediaPlayer", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController else { return }
        guard let url = URL(string: urlString) else { return }
        playerVC.url = url
        playerVC.modalPresentationStyle = .fullScreen
        playerVC.modalTransitionStyle = .coverVertical
        controller.present(playerVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initPlayer()
        initPlaybackControls()
    }

    private func initPlayer() {
        let option = IJKFFOptions.byDefault()
        #if DEBUG
        option?.showHudView = true
        #endif
        guard let ffPlayer = IJKFFMoviePlayerController(contentURL: self.url, with: option) else { return }
        ffPlayer.scalingMode = .aspectFit
        ffPlayer.shouldAutoplay = true
        ffPlayer.view.frame = playerView.bounds
        ffPlayer.view.translatesAutoresizingMaskIntoConstraints = true
        ffPlayer.view.autoresizingMask = .flexibleWidth.union(.flexibleHeight)
        playerView.addSubview(ffPlayer.view)
        self.player = ffPlayer

        self.registerPlayerObservers()
    }

    private func initPlaybackControls() {
        self.seekbar.minimumValue = 0
        self.seekbar.maximumValue = 0
        self.curentTimeLabel.text = 0.toClockTime
        self.durationLabel.text = 0.toClockTime

        self.playButton.addTarget(self, action: #selector(playPauseBtnTapped(_:)), for: .touchUpInside)
        seekbar.isContinuous = true
        seekbar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: [.valueChanged, .touchCancel])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        unregisterPlayerObservers()
    }

    deinit {
        unregisterPlayerObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player?.prepareToPlay()
        self.startPeriodicTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.player?.shutdown()
        self.stopPeriodicTimer()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @objc func playPauseBtnTapped(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        if player.isPlaying() {
            player.pause()
        } else {
            player.play()
        }
    }

    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began, .moved:
                isSliderDragging = true
                let seekTime = TimeInterval(slider.value)
                curentTimeLabel.text = seekTime.toClockTime
            case .ended, .cancelled:
                // seek here
                let seekTime = TimeInterval(slider.value)
                self.player?.currentPlaybackTime = seekTime

                isSliderDragging = false
            default:
                break
            }
        }
    }
}

extension PlayerViewController {
    func registerPlayerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: self.player)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidFinish(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.player)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange(_:)), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: self.player)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: self.player)
    }

    func unregisterPlayerObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: self.player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: self.player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: self.player)
    }

    @objc func loadStateDidChange(_ notification: Notification) {
        //    MPMovieLoadStateUnknown        = 0,
        //    MPMovieLoadStatePlayable       = 1 << 0,
        //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
        //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
        if let loadState = player?.loadState {
            if loadState.contains(.playthroughOK) {
                print("loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: \(loadState)\n")
            }
            else if loadState.contains(.stalled) {
                print("loadStateDidChange: IJKMPMovieLoadStateStalled: \(loadState)\n")
            }
            else {
                print("loadStateDidChange: ???: \(loadState)\n")
            }
        }

    }
    @objc func moviePlayBackDidFinish(_ notification: Notification) {
        //    MPMovieFinishReasonPlaybackEnded,
        //    MPMovieFinishReasonPlaybackError,
        //    MPMovieFinishReasonUserExited
        let reason = notification.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! Int
        switch reason {
        case IJKMPMovieFinishReason.playbackEnded.rawValue:
            print("playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: \(reason)\n")
        case IJKMPMovieFinishReason.userExited.rawValue:
            print("playbackStateDidChange: IJKMPMovieFinishReasonUserExited: \(reason)\n")
        case IJKMPMovieFinishReason.playbackError.rawValue:
            print("playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: \(reason)\n")
        default:
            print("playbackPlayBackDidFinish: ???: \(reason)\n")
        }
    }

    @objc func mediaIsPreparedToPlayDidChange(_ notification: Notification) {
        print("mediaIsPreparedToPlayDidChange\n")
        guard let player = self.player else {
            return
        }

        if player.isPreparedToPlay {
            self.durationLabel.text = player.duration.toClockTime
            self.seekbar.minimumValue = 0
            self.seekbar.maximumValue = Float(player.duration)
        }
    }

    @objc func moviePlayBackStateDidChange(_ notification: Notification) {
        //    MPMoviePlaybackStateStopped,
        //    MPMoviePlaybackStatePlaying,
        //    MPMoviePlaybackStatePaused,
        //    MPMoviePlaybackStateInterrupted,
        //    MPMoviePlaybackStateSeekingForward,
        //    MPMoviePlaybackStateSeekingBackward
        guard player != nil else {
            return
        }
        switch player!.playbackState {
        case .stopped:
            print("IJKMPMoviePlayBackStateDidChange \(String(describing: player?.playbackState)): stoped")
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
            break
        case .playing:
            print("IJKMPMoviePlayBackStateDidChange \(String(describing: player?.playbackState)): playing")
            self.playButton.setImage(UIImage(named: "ic_pause"), for: .normal)
            break
        case .paused:
            print("IJKMPMoviePlayBackStateDidChange \(String(describing: player?.playbackState)): paused")
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
            break
        case .interrupted:
            print("IJKMPMoviePlayBackStateDidChange \(String(describing: player?.playbackState)): interrupted")
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
            break
        case .seekingForward, .seekingBackward:
            print("IJKMPMoviePlayBackStateDidChange \(String(describing: player?.playbackState)): seeking")
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
            break
        }
    }
}

extension PlayerViewController {
    func startPeriodicTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {[weak self] _ in
            self?.updatePlayerTime()
        })
    }

    @objc func updatePlayerTime() {
        guard let player = self.player, player.isPreparedToPlay else { return }
        if !isSliderDragging {
            curentTimeLabel.text = player.currentPlaybackTime.toClockTime
            seekbar.value = Float(player.currentPlaybackTime)
        }
    }

    func stopPeriodicTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension Double {
    var toClockTime: String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

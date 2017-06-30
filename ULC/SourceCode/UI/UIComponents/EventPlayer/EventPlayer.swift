//
//  EventPlayer.swift
//  ULC
//
//  Created by Cruel Ultron on 3/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit
import KSYMediaPlayer
import SnapKit
import MediaPlayer

protocol EventPlayable {
    var player:KSYMoviePlayerController! { get };
    func play(let name: String);
    func stop();
    func pause();
    func resume();
}

protocol FullScreenModeProtocol: class {
    func changeScreenSize(type: ScreenSizeEvent);
}

enum ScreenSizeEvent {
    case FullScreen
    case WindowScreen
}

class EventPlayer: UIView, EventPlayable {
    var player:KSYMoviePlayerController! = nil;

	@IBOutlet weak var windowModeButton: UIButton!
	@IBOutlet weak var volumeButton: UIButton!
	@IBOutlet weak var volumeSlider: UISlider!
	@IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var bottomContentView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var allTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fullScreenBtn: UIButton!
    
    weak var fullScrennDelegate:FullScreenModeProtocol?;
    var screenType: ScreenSizeEvent = .WindowScreen;
    
    private var volume:Float = 0.0;
    private var mute = false;
	private var _duration = 0;

    private var timer:NSTimer?
	let audioSession = AVAudioSession.sharedInstance()

	func configureSliders() {
		if let volumeImage = R.image.hls_volume_dot_icon() {
			 let size = CGSizeMake(15, 15)
			volumeSlider.setThumbImage(imageResize(volumeImage, sizeChange: size), forState: .Normal)
		}

		if let progressImage = R.image.hls_progress_dot_icon() {
			let size = CGSizeMake(20, 20)
			progressSlider.setThumbImage(imageResize(progressImage, sizeChange: size), forState: .Normal)
		}
		progressSlider.backgroundColor = UIColor.clearColor()
		volumeSlider.minimumValue = 0
		volumeSlider.maximumValue = 1.0

		volumeSlider.value = AVAudioSession.sharedInstance().outputVolume

		volumeSlider.trackRectForBounds(CGRect(origin: volumeSlider.bounds.origin, size: CGSize(width: volumeSlider.bounds.size.width, height: 10)))

		self.progressSlider.addTarget(self, action: #selector(progressSliderDidEndSliding(_:)), forControlEvents: ([.TouchUpInside,.TouchUpOutside]))
		self.progressSlider.addTarget(self, action: #selector(progressSliderBeganSliding(_:)), forControlEvents: ([.TouchDown]))


		do {
			try audioSession.setActive(true)
			audioSession.addObserver(self, forKeyPath: "outputVolume",
		                         options: NSKeyValueObservingOptions.New, context: nil)
		} catch {

        }
	}

	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath == "outputVolume" {
			volume = AVAudioSession.sharedInstance().outputVolume

			volumeSlider.value = volume

			if volume == 0.0 {
				if let volumeOffImage = R.image.hls_volume_off_icon(){
					volumeButton.setImage(volumeOffImage, forState: .Normal)
				}
			} else {
				if let volumeOnImage = R.image.hls_volume_icon() {
					volumeButton.setImage(volumeOnImage, forState: .Normal)
				}
			}
			if player != nil {
				player.setVolume(volume * 2, rigthVolume: volume * 2);
			}
		}
	}


	func imageResize (image:UIImage, sizeChange:CGSize)-> UIImage{

		let hasAlpha = true
		let scale: CGFloat = 0.0 // Use scale factor of main screen

		UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
		image.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))

		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		return scaledImage
	}

	func progressSliderDidEndSliding(notification: NSNotification){
		let val = Double(progressSlider.value)
		player.seekTo(val / 1000, accurate: true)
		player.prepareToPlay()
		player.play()
		timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
	}

	func progressSliderBeganSliding(notification: NSNotification){
		timer?.invalidate()
		player.pause()
	}


	@IBAction func progressSliderAction(sender: AnyObject) {
	}


	func configureProgressSlider(duration:Int) {
		_duration = duration
		progressSlider.minimumValue = 0
		progressSlider.value = 0
		let calculatedDuration = Float((duration))
		progressSlider.maximumValue = calculatedDuration
        if duration >= 3_600_000 {
            allTimeLabel.text = "\(duration.msToSeconds.hourMinuteSecondMS)"
        } else {
            allTimeLabel.text = "\(duration.msToSeconds.minuteSecondMS)"
        }
	}

	func timerAction() {
        if player.currentPlaybackTime >= 3_600 {
            currentTimeLabel.text = "\(player.currentPlaybackTime.hourMinuteSecondMS)"
        } else {
            currentTimeLabel.text = "\(player.currentPlaybackTime.minuteSecondMS)"
        }
		progressSlider.setValue(Float(player.currentPlaybackTime * 1000), animated: true)
		if player.isPlaying() {
			playButton.setImage(R.image.hls_pause_icon(), forState: .Normal);
		} else {
			playButton.setImage(R.image.hls_play_icon(), forState: .Normal);
		}
	}

	func releasePlayer() {
        timer?.invalidate()
        timer = nil;
        
		if player != nil {
			if player.isPlaying() {
				player.stop()
			}
			player = nil
		}
		audioSession.removeObserver(self, forKeyPath: "outputVolume")
	}

    func play(let name: String) {
		timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        guard let url = NSURL(string: Constants.BASE_URL + "/vod/index/\(name).m3u8") else { return }
        if  player != nil {
            player.pause();
            player.stop();
            player = nil;
        }
        player = KSYMoviePlayerController(contentURL: url);
        if player.view.superview == nil {
            self.addSubview(player.view);
        }
        player.prepareToPlay();
        player.play();
    }
    
    @IBAction func volumeChanged(sender: AnyObject) {
		changeVolumeState(sender)
    }

	func changeVolumeState(sender: AnyObject) {
		guard let slider = sender as? UISlider else { return }
		if player == nil {
			return;
		}
		volume = slider.value;
		player.setVolume(slider.value * 2, rigthVolume: slider.value * 2); // multiply value to 2 because system value scalar 0~1 and player scalar 0~2

		if volume == 0 {
			if let volumeOffImage = R.image.hls_volume_off_icon(){
				volumeButton.setImage(volumeOffImage, forState: .Normal)
			}
		} else {
			if let volumeOnImage = R.image.hls_volume_icon() {
				volumeButton.setImage(volumeOnImage, forState: .Normal)
			}
		}

		let volumeView = MPVolumeView()
		if let view = volumeView.subviews.first as? UISlider
		{
			view.value = volume   // set b/w 0 t0 1.0
		}

	}

	@IBAction func volumePowerAction(sender: AnyObject) {
		changeMuteState()
	}


	@IBAction func playButtonPowerAction(sender: AnyObject) {
		changePlayMode()
	}
    
    @IBAction func playOrPause(sender: AnyObject) {
		changePlayMode()
    }

	func changePlayMode() {
	if player == nil {
	return;
		}
		if player.isPlaying() {
			player.pause();
			playButton.setImage(R.image.hls_play_icon(), forState: .Normal);
			playButton.setImage(R.image.hls_play_icon(), forState: .Selected);
		} else {
			player.play();
			playButton.setImage(R.image.hls_pause_icon(), forState: .Normal);
			playButton.setImage(R.image.hls_pause_icon(), forState: .Selected);
		}
	}

    @IBAction func fullScreenModel(sender: AnyObject) {
        if screenType == .WindowScreen {
            screenType = .FullScreen;
            fullScreenBtn.setImage(R.image.hls_contract_icon(), forState: .Normal);
            fullScreenBtn.setImage(R.image.hls_contract_icon(), forState: .Selected);
            player.scalingMode = MPMovieScalingMode.AspectFit;
        } else {
            screenType = .WindowScreen;
            fullScreenBtn.setImage(R.image.hls_expand_icon(), forState: .Normal);
            fullScreenBtn.setImage(R.image.hls_expand_icon(), forState: .Selected);
            player.scalingMode = MPMovieScalingMode.AspectFill;
        }
        fullScrennDelegate?.changeScreenSize(screenType);
    }

	func changeMuteState() {
		if player == nil { return }
		if mute {
			mute = false;
			if let volumeOnImage = R.image.hls_volume_icon() {
				volumeButton.setImage(volumeOnImage, forState: .Normal)
			}
			volumeSlider.value = volume
			player.setVolume(volume, rigthVolume: volume);
		} else {
			mute = true;
			if let volumeOffImage = R.image.hls_volume_off_icon(){
				volumeButton.setImage(volumeOffImage, forState: .Normal)
			}
			volumeSlider.value = 0
			player.setVolume(0, rigthVolume: 0);
		}
	}

    @IBAction func mute(sender: AnyObject) {
        changeMuteState()
    }
    
    override func updateConstraints() {
        super.updateConstraints();
        if player != nil && player.view.superview != nil {
            player.view.snp_remakeConstraints(closure: { (make) in
                make.left.top.right.equalTo(0);
                make.bottom.equalTo(progressSlider.snp_top);
            })
        }
    }
    
    final func stop() {
        if player != nil {
            player.pause();
            player.stop();
            player = nil;
        }
    }
    
    final func pause() {
        if player != nil {
            player.pause();
        }
    }
    final func resume() {
        if player != nil {
            player.play();
        }
    }
}

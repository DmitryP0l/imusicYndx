//
//  ViewController.swift
//  imusicYndx
//
//  Created by Dmitry P on 4.09.22.
//


import UIKit
import AVKit


final class ViewController: UIViewController {
    
    private var dataSourceTracks: [Track] = [Track(trackName: "1", cover: "pic1", artist: "first", fileName:     "blackbird-lonely-bird"),
                                             Track(trackName: "2", cover: "pic2", artist: "second", fileName: "blackbird-trapped"),
                                             Track(trackName: "3", cover: "pic3", artist: "third", fileName: "blackbird-lonely-bird"),
                                             Track(trackName: "4", cover: "pic4", artist: "fourth", fileName: "blackbird-trapped")]
    
    private let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    private var currentTrack: Track? {
        didSet {
            nameTrackLabel.text = currentTrack?.trackName
            artistTrackLabel.text = currentTrack?.artist
            playTrack(named: currentTrack?.fileName)
        }
    }
    
    private let collectionView: UICollectionView = {
        
       let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 300)
        //layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CollectionViewCellTrack.self, forCellWithReuseIdentifier: CollectionViewCellTrack.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .red
        return collectionView
    }()
    
    private let nameTrackLabel: UILabel = {
       let label = UILabel()
        label.backgroundColor = .white
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistTrackLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.text = "artist track"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressTrackBar: UISlider = {
        let slider = UISlider()
        slider.backgroundColor = .white
        slider.minimumValue = 0
        slider.tintColor = .green
        slider.tintColor = .gray
        slider.addTarget(Any?.self, action: #selector(handleCurrentTimeSlider), for: .allEvents)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.text = "00.00"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let allTimeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.text = "00.00"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backwardButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "backward"), for: .normal)
        button.addTarget(Any?.self, action: #selector(backwardButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.addTarget(Any?.self, action: #selector(playButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton(type: .system) //?
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "forward"), for: .normal)
        button.addTarget(Any?.self, action: #selector(forwardButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        currentTrack = dataSourceTracks.first
        
        setupCollectionView()
        setupTrackLabels()
        setupProgressTrackBar()
        setupTimeLabels()
        setubButtons()
        
    }
    
    //MARK: - Methods
    
    private func playTrack(named: String?) {
        guard  let url = Bundle.main.url(forResource: named , withExtension: "mp3") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
    }
    
    // slider
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale:  1))
        let percentage = currentTimeSeconds / durationSeconds
        progressTrackBar.value = Float(percentage)
    }
    
    // time uislider label
    private func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationTimeText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.allTimeLabel.text = "-\(currentDurationTimeText)"
            self?.updateCurrentTimeSlider()
        }
    }
    
    //action slider
   @objc func handleCurrentTimeSlider(_ sender: UISlider) {
        let percetage = progressTrackBar.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percetage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
//    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
//        let index = tracks.firstIndex(of: track)
//        guard let myIndex = index else { return nil }
//        var nextTrack: SearchViewModel.Cell
//        if myIndex - 1 == -1 {
//            nextTrack = tracks[tracks.count - 1]
//        } else {
//            nextTrack = tracks[myIndex - 1]
//            self.track = nextTrack
//        }
//       return nextTrack
//    }
    
    @objc func backwardButtonAction() {
        print("back")
        let visibleItems: NSArray = self.collectionView.indexPathsForVisibleItems as NSArray
            let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        let nextItem: IndexPath = IndexPath(item: currentItem.item - 1, section: 0)
            if nextItem.row < dataSourceTracks.count && nextItem.row >= 0 {
                self.collectionView.scrollToItem(at: nextItem, at: .right, animated: true)
                self.currentTrack = self.dataSourceTracks[nextItem.item]
            } else {
                self.collectionView.scrollToItem(at: [0, dataSourceTracks.count - 1], at: .right, animated: true)
                self.currentTrack = self.dataSourceTracks[dataSourceTracks.count - 1]
            }
    }
    
    @objc func playButtonAction() {
        
        observePlayerCurrentTime()
        
        if player.timeControlStatus == .paused {
            print("play")
           player.play()
            playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
//            enlagreTrackImageView()
        } else {
            player.pause()
            print("pause")
            playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
//            reduceTrackImageView()
        }
    }
    
    @objc func forwardButtonAction() {
        print("forward")
        let visibleItems: NSArray = self.collectionView.indexPathsForVisibleItems as NSArray
           let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
           let nextItem: IndexPath = IndexPath(item: currentItem.item + 1, section: 0)
                  if nextItem.row < dataSourceTracks.count {
                      self.collectionView.scrollToItem(at: nextItem, at: .left, animated: true)
                self.currentTrack = self.dataSourceTracks[nextItem.item]
                  } else {
                      self.collectionView.scrollToItem(at: [0, dataSourceTracks.startIndex], at: .left, animated: true)
                      self.currentTrack = self.dataSourceTracks[dataSourceTracks.startIndex]
                  }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceTracks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellTrack.identifier, for: indexPath) as? CollectionViewCellTrack
        else { return UICollectionViewCell() }
        
        let cover = dataSourceTracks[indexPath.row].cover
        cell.imageView.image = UIImage(named: cover)
       
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            guard let visibleCell = self.collectionView.visibleCells.first else { return }
            guard let indexPath = self.collectionView.indexPath(for: visibleCell) else { return }
            self.currentTrack = self.dataSourceTracks[indexPath.item]
            //print(indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}


//MARK: - UI Setup

extension ViewController {
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 316).isActive = true
    }
    
    private func setupTrackLabels() {
        view.addSubview(nameTrackLabel)
        view.addSubview(artistTrackLabel)
        
        nameTrackLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 30).isActive = true
        nameTrackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        nameTrackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        nameTrackLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        artistTrackLabel.topAnchor.constraint(equalTo: nameTrackLabel.bottomAnchor, constant: 8).isActive = true
        artistTrackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        artistTrackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        artistTrackLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    private func setupProgressTrackBar() {
        view.addSubview(progressTrackBar)
        
        progressTrackBar.topAnchor.constraint(equalTo: artistTrackLabel.bottomAnchor, constant: 20).isActive = true
        progressTrackBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        progressTrackBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        progressTrackBar.heightAnchor.constraint(equalToConstant: 4).isActive = true
    }
    
    private func setupTimeLabels() {
        view.addSubview(currentTimeLabel)
        view.addSubview(allTimeLabel)
        
        currentTimeLabel.topAnchor.constraint(equalTo: progressTrackBar.bottomAnchor, constant: 12).isActive = true
        currentTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        allTimeLabel.topAnchor.constraint(equalTo: progressTrackBar.bottomAnchor, constant: 12).isActive = true
        allTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        allTimeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
    
    private func setubButtons() {
        view.addSubview(backwardButton)
        view.addSubview(playPauseButton)
        view.addSubview(forwardButton)
        
        playPauseButton.topAnchor.constraint(equalTo: progressTrackBar.bottomAnchor, constant: 100).isActive = true
        playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        backwardButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -50).isActive = true
        backwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor).isActive = true
        backwardButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backwardButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        forwardButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 50).isActive = true
        forwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

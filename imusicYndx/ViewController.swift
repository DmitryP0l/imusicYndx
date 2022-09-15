//
//  ViewController.swift
//  imusicYndx
//
//  Created by Dmitry P on 4.09.22.
//

//поправить констрейнты
//поправть изображение кнопки плей при окончании трека
//по окончании трека, переключаться на следующий и играть

//коллекшен к самому верху. высота = ширина.
//высота для лэйбл и слайдер
//слайдер с таймером в отдельную вью


//  [1, 2,    1, 2,         1, 2]         (0, 1,   2, 3,        4, 5) (6)         (0, 1,   0, 1,        0, 1)
//  [2, 3,    1, 2, 3,      1, 2]         (0, 1,   2, 3, 4,     5, 6) (7)         (1, 2,   0, 1, 2,     0, 1)
//  [3, 4,    1, 2, 3, 4,   1, 2]         (0, 1,   2, 3, 4, 5,  6, 7) (8)         (2, 3,   0, 1, 2, 3,  0, 1)

import UIKit
import AVKit

final class ViewController: UIViewController {
    
    private let trackList: [Track] =
    [Track(trackName: "1", cover: "pic1", artist: "first", fileName: "blackbird-lonely-bird"),
     Track(trackName: "2", cover: "pic2", artist: "second", fileName: "blackbird-trapped"),
     Track(trackName: "3", cover: "pic3", artist: "third", fileName:"blackbird-lonely-bird"),
     Track(trackName: "4", cover: "pic4", artist: "fourht", fileName: "blackbird-trapped")]
    
    
    //[Track(trackName: "1", cover: "pic1", artist: "first", fileName:"blackbird-lonely-bird"),
    //Track(trackName: "2", cover: "pic2", artist: "second", fileName: "blackbird-trapped"),
    //Track(trackName: "3", cover: "pic3", artist: "third", fileName: "blackbird-lonely-bird"),
    //Track(trackName: "4", cover: "pic4", artist: "fourht", fileName: "blackbird-trapped")]
    
    private var dataSourceTracks: [Track] = []
    
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
        collectionView.register(CollectionViewCellTrack.self, forCellWithReuseIdentifier:
                                    CollectionViewCellTrack.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .red
        return collectionView
    }()
    
    private let containerViewInfo: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let containerViewButtons: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemCyan
        return view
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
        
        setupCollectionView()
        prepareDataSourceTracks()
        setupStartCell()
        
        setupContainerViews()
        setupProgressTrackBar()
        setupTimeLabels()
        setupTrackLabels()
        setubButtons()
    }
    
    //MARK: - Methods
    
    private func prepareDataSourceTracks() {
        let firstPart = Array(trackList.prefix(through: 1))
        let lastPart = Array(trackList.suffix(2))
        let newArray = lastPart + trackList + firstPart
        dataSourceTracks = newArray
        collectionView.reloadData()
        print("first ---- \(firstPart)")
        print("last ----\(lastPart)")
        print("newArray ------\(newArray)")
    }
    
    private func setupStartCell() {
        currentTrack = dataSourceTracks[2]
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: 2, section: 0), at: .left, animated: true)
        collectionView.isPagingEnabled = true
    }
    
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
    
    
    @objc func backwardButtonAction() {
        print("back")
        let visibleItems: NSArray = self.collectionView.indexPathsForVisibleItems as NSArray
        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        let nextItem: IndexPath = IndexPath(item: currentItem.item - 1, section: 0)
        if nextItem.row < dataSourceTracks.count && nextItem.row >= 0 {
            self.collectionView.scrollToItem(at: nextItem, at: .right, animated: false)
            self.currentTrack = self.dataSourceTracks[nextItem.item]
        } else {
            self.collectionView.scrollToItem(at: [0, dataSourceTracks.count - 1], at: .right, animated: false)
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
            self.collectionView.scrollToItem(at: nextItem, at: .left, animated: false)
            self.currentTrack = self.dataSourceTracks[nextItem.item]
        } else {
            self.collectionView.scrollToItem(at: [0, dataSourceTracks.startIndex], at: .left, animated: false)
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
            let pageFloat = (scrollView.contentOffset.x / scrollView.frame.size.width)
            let pageInt = Int(round(pageFloat))
            print(pageInt)
            switch pageInt {
            case 0:
                self.collectionView.scrollToItem(at: IndexPath(item: self.dataSourceTracks.count - 4, section: 0), at: .left, animated: false)

            case self.dataSourceTracks.count - 2:
                self.collectionView.scrollToItem(at: [0, 2], at: .left, animated: false)
            default:
                break
            }
        }
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
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
    }
    
    private func setupContainerViews() {
        view.addSubview(containerViewInfo)
        view.addSubview(containerViewButtons)
        
        containerViewInfo.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        containerViewInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerViewInfo.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerViewInfo.heightAnchor.constraint(equalToConstant: view.frame.height / 5).isActive = true
        
        containerViewButtons.topAnchor.constraint(equalTo: containerViewInfo.bottomAnchor).isActive = true
        containerViewButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerViewButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerViewButtons.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupTrackLabels() {
        
        containerViewInfo.addSubview(artistTrackLabel)
        containerViewInfo.addSubview(nameTrackLabel)
        
        
        artistTrackLabel.bottomAnchor.constraint(equalTo: progressTrackBar.topAnchor, constant: -18).isActive = true
        artistTrackLabel.leadingAnchor.constraint(equalTo: containerViewInfo.leadingAnchor).isActive = true
        artistTrackLabel.trailingAnchor.constraint(equalTo: containerViewInfo.trailingAnchor).isActive = true
        artistTrackLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        nameTrackLabel.bottomAnchor.constraint(equalTo: artistTrackLabel.topAnchor, constant: -8).isActive = true
        nameTrackLabel.leadingAnchor.constraint(equalTo: containerViewInfo.leadingAnchor).isActive = true
        nameTrackLabel.trailingAnchor.constraint(equalTo: containerViewInfo.trailingAnchor).isActive = true
        nameTrackLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    private func setupProgressTrackBar() {
        
        containerViewInfo.addSubview(progressTrackBar)
        
        progressTrackBar.centerYAnchor.constraint(equalTo: containerViewInfo.centerYAnchor, constant: 10).isActive = true
        progressTrackBar.leadingAnchor.constraint(equalTo: containerViewInfo.leadingAnchor, constant: 8).isActive = true
        progressTrackBar.trailingAnchor.constraint(equalTo: containerViewInfo.trailingAnchor, constant: -8).isActive = true
        progressTrackBar.heightAnchor.constraint(equalToConstant: 4).isActive = true
    }
    
    private func setupTimeLabels() {
        containerViewInfo.addSubview(currentTimeLabel)
        containerViewInfo.addSubview(allTimeLabel)
        
        currentTimeLabel.topAnchor.constraint(equalTo: progressTrackBar.bottomAnchor, constant: 20).isActive = true
        currentTimeLabel.leadingAnchor.constraint(equalTo: containerViewInfo.leadingAnchor, constant: 8).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        allTimeLabel.topAnchor.constraint(equalTo: progressTrackBar.bottomAnchor, constant: 20).isActive = true
        allTimeLabel.trailingAnchor.constraint(equalTo: containerViewInfo.trailingAnchor, constant: -8).isActive = true
        allTimeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
    
    private func setubButtons() {
        containerViewButtons.addSubview(backwardButton)
        containerViewButtons.addSubview(playPauseButton)
        containerViewButtons.addSubview(forwardButton)
        
        playPauseButton.centerYAnchor.constraint(equalTo: containerViewButtons.centerYAnchor, constant: -10).isActive = true
        playPauseButton.centerXAnchor.constraint(equalTo: containerViewButtons.centerXAnchor).isActive = true
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

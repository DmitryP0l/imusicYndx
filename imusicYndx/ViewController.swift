//
//  ViewController.swift
//  imusicYndx
//
//  Created by Dmitry P on 4.09.22.
//

//поправть изображение кнопки плей при окончании трека
//по окончании трека, переключаться на следующий и играть
// добить логику на кнопках

//работа с документацией есть делегат, унаследовали, подписывать куда?




//  [1, 2,    1, 2,         1, 2]         (0, 1,   2, 3,        4, 5) (6)         (0, 1,   0, 1,        0, 1)
//  [2, 3,    1, 2, 3,      1, 2]         (0, 1,   2, 3, 4,     5, 6) (7)         (1, 2,   0, 1, 2,     0, 1)
//  [3, 4,    1, 2, 3, 4,   1, 2]         (0, 1,   2, 3, 4, 5,  6, 7) (8)         (2, 3,   0, 1, 2, 3,  0, 1)

import UIKit
import AVKit

final class ViewController: UIViewController {
    
    private let trackList: [Track] = Track.allCases
    private var dataSource: [Track] = []
    private var currentTrack: Track? {
        didSet {
            setDataCurrentTrack()
        }
    }
    
    private let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    private var collectionView: UICollectionView = {
        let layout = CustomCollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private var centralCell: CollectionViewCellTrack?
    
    private let containerViewInfo: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let containerViewButtons: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let nameTrackLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 22)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistTrackLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressTrackBar: UISlider = {
        let slider = UISlider()
        slider.backgroundColor = .clear
        slider.minimumValue = 0
        slider.tintColor = .gray
        slider.addTarget(Any?.self, action: #selector(handleCurrentTimeSlider), for: .allEvents)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = "00.00"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let allTimeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
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
        setViews()
        setCollectionView()
        prepareDataSource()
        setStartCell()
        notificationAudioDidEnded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.contentInset.left = (UIScreen.main.bounds.width/6)
        self.collectionView.contentInset.right = (UIScreen.main.bounds.width/6)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.collectionView.contentInset.left = (UIScreen.main.bounds.width/6)
//        self.collectionView.contentInset.right = (UIScreen.main.bounds.width/6)
//    }
    
    //MARK: - Methods
    
    private func setCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CollectionViewCellTrack.self, forCellWithReuseIdentifier:
                                    CollectionViewCellTrack.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }
    
    private func prepareDataSource() {
        
        if trackList.count == 1 {
            guard let trackList = trackList.first else { return }
                let newArray = [Track](repeating: trackList, count: 5)
            dataSource = newArray
            collectionView.reloadData()
        } else {
            let firstPart = Array(trackList.prefix(through: 1))
            let lastPart = Array(trackList.suffix(2))
            let newArray = lastPart + trackList + firstPart
            dataSource = newArray
            collectionView.reloadData()
        }
        
        //        print("first ---- \(firstPart)")
        //        print("last ----\(lastPart)")
        //        print("newArray ------\(newArray)")
    }
    
    private func setStartCell() {
        currentTrack = dataSource[2]
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: 2, section: 0), at: .left, animated: true)
    }
    
    private func playTrack(named: String?) {
        guard  let url = Bundle.main.url(forResource: named , withExtension: "mp3") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
    }
    
    private func setDataCurrentTrack() {
        nameTrackLabel.text = currentTrack?.trackName
        artistTrackLabel.text = currentTrack?.artist
        playTrack(named: currentTrack?.fileName)
//        if let cover = currentTrack?.cover {
//            DispatchQueue.main.async {
//                self.view.backgroundColor =  UIImage(named: cover)?.averageColor
//            }
//        }
    }
    
    @objc func backwardButtonAction() {
        print("back")
        let visibleItems: NSArray = self.collectionView.indexPathsForVisibleItems as NSArray
        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        let nextItem: IndexPath = IndexPath(item: currentItem.item - 1, section: 0)
        if nextItem.row < dataSource.count && nextItem.row >= 0 {
            self.collectionView.scrollToItem(at: nextItem, at: .right, animated: false)
            self.currentTrack = self.dataSource[nextItem.item]
        } else {
            self.collectionView.scrollToItem(at: [0, dataSource.count - 1], at: .right, animated: false)
            self.currentTrack = self.dataSource[dataSource.count - 1]
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
        if nextItem.row < dataSource.count {
            self.collectionView.scrollToItem(at: nextItem, at: .left, animated: false)
            self.currentTrack = self.dataSource[nextItem.item]
        } else {
            self.collectionView.scrollToItem(at: [0, dataSource.startIndex], at: .left, animated: false)
            self.currentTrack = self.dataSource[dataSource.startIndex]
        }
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
    
    private func notificationAudioDidEnded() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil
        )
    }
    
    @objc func audioDidEnded() {
        print("IT'S DONE!")
        forwardButtonAction()
        player.play()
    }
}


//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellTrack.identifier, for: indexPath) as? CollectionViewCellTrack
        else { return UICollectionViewCell() }
        let cover = dataSource[indexPath.row].cover
        let labelName = dataSource[indexPath.row].trackName
        let model = CellModel.init(imageName: cover, labelNum: labelName)
        cell.model = model
        
        cell.labelNoIndexPath.text = "indexPath - \(indexPath.row)"
        return cell
    }
    
    
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        
            let pageFloat = (scrollView.contentOffset.x / scrollView.frame.size.width)
            let pageInt = Int(round(pageFloat))
            print(pageInt)
            switch pageInt {
            case 0:
                self.collectionView.scrollToItem(at: IndexPath(item: self.dataSource.count - 4, section: 0), at: .left, animated: false)
            case self.dataSource.count - 2:
                self.collectionView.scrollToItem(at: [0, 2], at: .left, animated: false)
            default:
                break
            }
        
        DispatchQueue.main.async {
            let centerPoint = CGPoint(x: self.collectionView.frame.midX, y: self.collectionView.frame.midY)
            let collectionViewCenterPoint = self.view.convert(centerPoint, to: self.collectionView)
            if let indexPath = self.collectionView.indexPathForItem(at: collectionViewCenterPoint) {
                self.currentTrack = self.dataSource[indexPath.item]
            }
        }
    }
    
    
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let centralPoint = CGPoint(x: collectionView.frame.width/2 + scrollView.contentOffset.x,
//                                   y: collectionView.frame.height/2 + scrollView.contentOffset.y)
//        if let indexPath = collectionView.indexPathForItem(at: centralPoint), self.centralCell == nil {
//            self.centralCell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellTrack
//            self.currentTrack = dataSource[indexPath.item]
//            //                self.centralCell?.transformToLarge()
//        }
//
//        if let cell = self.centralCell {
//            let offsetX = centralPoint.x - cell.center.x
//            //разобраться что к чему
//            if offsetX < -15 || offsetX > 15 {
//                //                    self.centralCell?.transformToStandart()
//                self.centralCell = nil
//            }
//        }
//    }
    
}


//MARK: - UI Setup

extension ViewController {
    private func setViews() {
        view.backgroundColor = .lightGray
        
        view.addSubview(collectionView)
        view.addSubview(containerViewInfo)
        view.addSubview(containerViewButtons)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width/3)*2).isActive = true
        
        containerViewInfo.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        containerViewInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerViewInfo.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerViewInfo.heightAnchor.constraint(equalToConstant: view.frame.height / 5).isActive = true
        
        containerViewButtons.topAnchor.constraint(equalTo: containerViewInfo.bottomAnchor).isActive = true
        containerViewButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerViewButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerViewButtons.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        setupContainerViewInfo()
        setupContainerViewButtons()
    }
    
    private func setupContainerViewInfo() {
        containerViewInfo.addSubview(artistTrackLabel)
        containerViewInfo.addSubview(nameTrackLabel)
        containerViewInfo.addSubview(progressTrackBar)
        containerViewInfo.addSubview(currentTimeLabel)
        containerViewInfo.addSubview(allTimeLabel)
        
        artistTrackLabel.bottomAnchor.constraint(equalTo: progressTrackBar.topAnchor, constant: -18).isActive = true
        artistTrackLabel.leadingAnchor.constraint(equalTo: containerViewInfo.leadingAnchor).isActive = true
        artistTrackLabel.trailingAnchor.constraint(equalTo: containerViewInfo.trailingAnchor).isActive = true
        artistTrackLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        nameTrackLabel.bottomAnchor.constraint(equalTo: artistTrackLabel.topAnchor, constant: -8).isActive = true
        nameTrackLabel.leadingAnchor.constraint(equalTo: containerViewInfo.leadingAnchor).isActive = true
        nameTrackLabel.trailingAnchor.constraint(equalTo: containerViewInfo.trailingAnchor).isActive = true
        nameTrackLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        progressTrackBar.centerYAnchor.constraint(equalTo: containerViewInfo.centerYAnchor, constant: 10).isActive = true
        progressTrackBar.leadingAnchor.constraint(equalTo: containerViewInfo.leadingAnchor, constant: 8).isActive = true
        progressTrackBar.trailingAnchor.constraint(equalTo: containerViewInfo.trailingAnchor, constant: -8).isActive = true
        progressTrackBar.heightAnchor.constraint(equalToConstant: 4).isActive = true
        
        currentTimeLabel.topAnchor.constraint(equalTo: progressTrackBar.bottomAnchor, constant: 20).isActive = true
        currentTimeLabel.leadingAnchor.constraint(equalTo: containerViewInfo.leadingAnchor, constant: 8).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        allTimeLabel.topAnchor.constraint(equalTo: progressTrackBar.bottomAnchor, constant: 20).isActive = true
        allTimeLabel.trailingAnchor.constraint(equalTo: containerViewInfo.trailingAnchor, constant: -8).isActive = true
        allTimeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
    
    private func setupContainerViewButtons() {
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

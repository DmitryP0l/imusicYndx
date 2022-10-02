//
//  ViewController.swift
//  imusicYndx
//
//  Created by Dmitry P on 4.09.22.

// загружать с ячейкой в центре!


import UIKit
import AVKit
import MarqueeLabel

final class ViewController: UIViewController {
    
    private let trackList: [Track] = Track.allCases
    private var dataSource: [Track] = []
    private var currentTrack: Track? {
        didSet {
            setDataCurrentTrack()
        }
    }
    private var centerPoint = CGPoint(x: 0, y: 0)
    private var collectionViewCenterPoint = CGPoint(x: 0, y: 0)
    private var indexPathItem: Int?
    private var indexPath: IndexPath? {
        didSet {
            indexPathItem = indexPath?.item
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
    
    private let nameTrackLabel: MarqueeLabel = {
        let label = MarqueeLabel.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), duration: 8.0, fadeLength: 1.0)
        label.trailingBuffer = 80
        label.fadeLength = 20
        label.animationDelay = 2
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistTrackLabel: MarqueeLabel = {
        let label = MarqueeLabel.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), duration: 8.0, fadeLength: 1.0)
        label.trailingBuffer = 80
        label.fadeLength = 20
        label.animationDelay = 2
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
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
        label.textColor = .white
        label.text = "00:00"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let allTimeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.tintColor = .white
        button.bounds.size.height = 60
        button.bounds.size.width = 60
        button.layer.cornerRadius = button.bounds.size.height / 2
        button.setImage(UIImage(systemName: "backward.end"), for: .normal)
        button.addTarget(Any?.self, action: #selector(backwardButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        button.bounds.size.height = 80
        button.bounds.size.width = 80
        button.layer.cornerRadius = button.bounds.size.height / 2
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.addTarget(Any?.self, action: #selector(playButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.tintColor = .white
        button.setImage(UIImage(systemName: "forward.end"), for: .normal)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.contentInset.left = (UIScreen.main.bounds.width/6)
        self.collectionView.contentInset.right = (UIScreen.main.bounds.width/6)
        
        setCoordinateCentralCell()
        indexPathItem = indexPath?.item
    }
    
    //MARK: - Methods
    
    private func setCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CollectionViewCellTrack.self,
                                forCellWithReuseIdentifier: CollectionViewCellTrack.identifier)
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
    }
    
    private func setStartCell() {
        currentTrack = dataSource[2]
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: 2, section: 0), at: .left, animated: true)
    }
    
    private func setCoordinateCentralCell() {
        centerPoint = CGPoint(x: self.collectionView.frame.midX, y: self.collectionView.frame.midY)
        collectionViewCenterPoint = self.view.convert(centerPoint, to: self.collectionView)
        indexPath = self.collectionView.indexPathForItem(at: collectionViewCenterPoint)
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
        if let cover = currentTrack?.cover {
            UIView.animate(withDuration: 1, delay: 0.7) {
                self.view.backgroundColor =  UIImage(named: cover)?.averageColor
            } completion: { _ in }
        }
    }
    
    @objc func backwardButtonAction() {
        print("back")
        
        guard let indexPath = indexPath, let indexPathItem = indexPathItem else { return }
        switch indexPathItem {
        case 1:
            self.collectionView.scrollToItem(at: IndexPath(item: self.dataSource.count - 4, section: 0), at: .left, animated: false)
            self.collectionView.scrollToItem(at: [0, 4], at: .left, animated: false)
            self.indexPath = [0, 4]
            currentTrack = self.dataSource[4]
        default:
            let backIndexPath = IndexPath(item: indexPath.item - 1, section: 0)
            collectionView.scrollToItem(at: backIndexPath, at: .right, animated: false)
            self.indexPath = backIndexPath
            collectionView.reloadData()
            currentTrack = self.dataSource[backIndexPath.item]
        }
    }
    
    @objc func playButtonAction() {
        observePlayerCurrentTime()
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            transformToEnlarge()
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            transformToReduce()
        }
    }
    
    func transformToEnlarge() {
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        setCoordinateCentralCell()
        
        if let indexPath = indexPath {
            self.centralCell = (self.collectionView.cellForItem(at: indexPath) as? CollectionViewCellTrack)
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
                self.centralCell?.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.centralCell?.imageView.layer.cornerRadius = 8
            }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func transformToReduce() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
        self.centralCell?.imageView.transform = CGAffineTransform.identity
        }
    }
    
    @objc func forwardButtonAction() {
        guard let indexPath = indexPath, let indexPathItem = indexPathItem else { return }
        let nextIndexPath = IndexPath(item: indexPath.item + 1, section: 0)
        
        switch indexPathItem {
        case self.dataSource.count - 2:
            self.collectionView.scrollToItem(at: [0, 3], at: .left, animated: false)
            self.indexPath = [0, 3]
            currentTrack = self.dataSource[nextIndexPath.item]
        default:
            collectionView.scrollToItem(at: nextIndexPath, at: .left, animated: false)
            self.indexPath = nextIndexPath
            currentTrack = self.dataSource[nextIndexPath.item]
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
        let model = CellModel.init(imageName: cover)
        cell.model = model
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        setCoordinateCentralCell()
        indexPathItem = indexPath?.item
        
        switch indexPathItem {
        case 0:
            self.collectionView.scrollToItem(at: IndexPath(item: self.dataSource.count - 2, section: 0), at: .left, animated: false)
        case 1:
            self.collectionView.scrollToItem(at: IndexPath(item: self.dataSource.count - 3, section: 0), at: .left, animated: false)
        case self.dataSource.count - 2:
            self.collectionView.scrollToItem(at: [0, 2], at: .left, animated: false)
        case self.dataSource.count - 1:
            self.collectionView.scrollToItem(at: [0, 3], at: .left, animated: false)
        default:
            break
        }
        
        DispatchQueue.main.async {
            if let indexPath = self.indexPath {
                let currentTrack = self.dataSource[indexPath.item]
                if self.currentTrack != currentTrack {
                    self.currentTrack = currentTrack
                    if self.player.timeControlStatus == .playing {
                        self.transformToEnlarge()
                    }
                }
            }
        }
        
        if self.player.timeControlStatus == .playing {
            self.transformToEnlarge()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        let centerPoint = CGPoint(x: self.collectionView.frame.size.width / 2 + scrollView.contentOffset.x,
                                  y: self.collectionView.frame.size.height / 2 + scrollView.contentOffset.y)
        
        if let cell = self.centralCell {
            let offsetX = centerPoint.x - cell.center.x
            let switchOffset: CGFloat = UIScreen.main.bounds.width / 3
            if offsetX < -switchOffset || offsetX > switchOffset {
                    transformToReduce()
                self.centralCell = nil
            }
        }
    }
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
        artistTrackLabel.leadingAnchor.constraint(equalTo: containerViewInfo.leadingAnchor, constant: 8).isActive = true
        artistTrackLabel.trailingAnchor.constraint(equalTo: containerViewInfo.trailingAnchor).isActive = true
        artistTrackLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        nameTrackLabel.bottomAnchor.constraint(equalTo: artistTrackLabel.topAnchor, constant: -8).isActive = true
        nameTrackLabel.leadingAnchor.constraint(equalTo: containerViewInfo.leadingAnchor, constant: 8).isActive = true
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
        
        backwardButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -20).isActive = true
        backwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor).isActive = true
        backwardButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        backwardButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        forwardButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 20).isActive = true
        forwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
    }
}

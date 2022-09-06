//
//  ViewController.swift
//  imusicYndx
//
//  Created by Dmitry P on 4.09.22.
//

import UIKit
import AVFoundation


final class ViewController: UIViewController {

    var player: AVAudioPlayer!


     func playSound() {
         guard let url = Bundle.main.url(forResource: "A" , withExtension: "wav") else { return }
         player = try! AVAudioPlayer(contentsOf: url)
         player.play()
     }
    
    
    
//    func playSound() {
//        // Load a local sound file
//        guard let soundFileURL = Bundle.main.url(
//            forResource: "blackbirdFoggyNight",
//            withExtension: "mp3"
//        ) else {
//            return
//        }
//
//        do {
//            // Configure and activate the AVAudioSession
//            try AVAudioSession.sharedInstance().setCategory(
//                AVAudioSession.Category.soloAmbient
//            )
//
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            // Play a sound
//            let player = try AVAudioPlayer(
//                contentsOf: soundFileURL
//            )
//
//            player.play()
//        }
//        catch {
//            // Handle error
//        }
//    }
    
    
    
    private let collectionView: UICollectionView = {
        
       let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 300)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CollectionViewCellTrack.self, forCellWithReuseIdentifier: CollectionViewCellTrack.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let nameTrackLabel: UILabel = {
       let label = UILabel()
        label.backgroundColor = .white
        label.text = "name track"
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
        label.text = "03.45"
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
    
    private let playButton: UIButton = {
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
        setupTrackLabels()
        setupProgressTrackBar()
        setupTimeLabels()
        setubButtons()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4).isActive = true
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
        view.addSubview(playButton)
        view.addSubview(forwardButton)
        
        playButton.topAnchor.constraint(equalTo: progressTrackBar.bottomAnchor, constant: 100).isActive = true
        playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        backwardButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -50).isActive = true
        backwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        backwardButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backwardButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        forwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 50).isActive = true
        forwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc func backwardButtonAction() {
        print("back")
    }
    
    @objc func playButtonAction() {
        print("play")
        playSound()
        
        
    }
    
    @objc func forwardButtonAction() {
        print("forward")
    }
}



//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellTrack.identifier, for: indexPath) as? CollectionViewCellTrack
        else { return UICollectionViewCell() }
        return cell
    }
}

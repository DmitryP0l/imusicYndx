//
//  ViewController.swift
//  imusicYndx
//
//  Created by Dmitry P on 4.09.22.
//

import UIKit

final class ViewController: UIViewController {

    private let collectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CollectionViewCellTrack.self, forCellWithReuseIdentifier: CollectionViewCellTrack.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
}

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

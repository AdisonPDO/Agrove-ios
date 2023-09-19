//
//  GardenerFriendsVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 13/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class GardenerFriendsVC: UIViewController {
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    
    private var imageVCs: [ImageVC] = []
    private var pageViewController: UIPageViewController!
    
    private enum Consts {
        static let edgeInsets = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 10)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "GardernerSelectedCell", bundle: nil), forCellWithReuseIdentifier: "GardenerAddCCell")
        collectionView.register(UINib(nibName: "GardernerNotSelectedCell", bundle: nil), forCellWithReuseIdentifier: "GardenerPlantCCell")
        initPVC([Asset.jardin.image, Asset.jardin2.image])
        //tableView.register(UINib(nibName: "GardenerFloorTCell", bundle: nil), forCellReuseIdentifier: "gardenerFloorCell")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.collectionView.scrollRectToVisible(.zero, animated: false)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case StoryboardSegue.GardernerFriend.embeddedPageViewController.rawValue:
            pageViewController = (segue.destination as! UIPageViewController)
            pageViewController.dataSource = self
        default:
            break
        }
    }
    
    private func initPVC(_ images: [UIImage]) {
        guard let pageViewController = pageViewController else { return }
        imageVCs = images.map { image in
            let vc = StoryboardScene.GardernerFriend.imageVC.instantiate()
            vc.image = image
            return vc
        }
        pageControl.numberOfPages = images.count
        pageViewController.setViewControllers([imageVCs.first!], direction: .forward, animated: false, completion: nil)
    }
}

extension GardenerFriendsVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = imageVCs.index(of: viewController as! ImageVC), index > 0 else { return nil }
        pageControl.currentPage = index - 1
        return imageVCs[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = imageVCs.index(of: viewController as! ImageVC), index < imageVCs.count else { return nil }
        pageControl.currentPage = index + 1
        return imageVCs[index + 1]
    }
    
}

extension GardenerFriendsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gardenerFloorCell", for: indexPath) as! GardenerFloorTCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
}

extension GardenerFriendsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return Consts.edgeInsets
        }
        return .zero
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 4
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GardenerSelectedCell", for: indexPath) as! GardenerSelectedCVC
            configureCell(cell: cell, index: indexPath, value: 0.75)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GardernerNotSelectedCell", for: indexPath)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func configureCell(cell: GardenerSelectedCVC, index: IndexPath, value: Float) {
        
        let circularProgress = cell.circularProgressView!
        circularProgress.progressColor = Styles.PlantRGreenProgressBarFriend
        circularProgress.trackColor = Styles.PlantRGreenBarFriend
        circularProgress.setProgressWithAnimation(duration: 1.0, value: value)
    }
}

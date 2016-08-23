//
//  MorePicturesViewController.swift
//  GetSystemAlbum
//
//  Created by 黄启明 on 16/8/22.
//  Copyright © 2016年 huatengIOT. All rights reserved.
//
//从系统相册中获取多张图片
//思路
//
//导入头文件#import <Photos/Photos.h>
//PHAsset : 一个资源, 比如一张图片\一段视频
//PHAssetCollection : 一个相簿

import UIKit
import Photos

class MorePicturesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    
    var dataArray = [AnyObject]()
    let cellID = "cell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        creatCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getMorePicture(sender: AnyObject) {
        let myPhotoViewController = MyPhotoViewController()
        myPhotoViewController.maxSelectedCount = 4
        
        //使用闭包传递数据
        myPhotoViewController.performSelectedPhotosBlock{(assetArray: Array<PHAsset>) in
            self.dataArray = assetArray
            self.collectionView.reloadData()
        }
        presentViewController(myPhotoViewController, animated: true, completion: nil)
        
    }
    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //创建collectionView
    private func creatCollectionView() {
        flowLayout.itemSize = CGSizeMake((screenW - 10 * 3) / 2, (screenW - 10 * 3) / 2)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        collectionView = UICollectionView(frame: CGRectMake(0, 100, screenW, screenH - 100), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.whiteColor()
        
        collectionView.registerClass(MainCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! MainCollectionViewCell
        PHImageManager.defaultManager().requestImageForAsset(dataArray[indexPath.row] as! PHAsset, targetSize: CGSizeMake(view.bounds.width, view.bounds.height), contentMode: .AspectFit, options: nil) { (result: UIImage?, dict: Dictionary?) in

            cell.imageView.image = result
            
            if result == nil{
                PHImageManager.defaultManager().requestImageForAsset(self.dataArray[indexPath.row] as! PHAsset, targetSize: CGSizeZero, contentMode: .AspectFit, options: nil, resultHandler: { (result: UIImage?, dict: Dictionary?) in
                   cell.imageView.image = result ?? UIImage(named: "iw_none")
                  
                })
            }
        }
        return cell
    }
}

class MainCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        //设置图片
        imageView.frame = contentView.bounds
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

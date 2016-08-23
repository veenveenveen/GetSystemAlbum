//
//  MyPhotoViewController.swift
//  GetSystemAlbum
//
//  Created by 黄启明 on 16/8/23.
//  Copyright © 2016年 huatengIOT. All rights reserved.
//

import UIKit
import Photos

//MARK: - 屏幕宽高
let screenW = UIScreen.mainScreen().bounds.size.width
let screenH = UIScreen.mainScreen().bounds.size.height

class MyPhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
    
    /*********  图片选择数量，唯一需要外部传入的值，默认为1  *********/
    var maxSelectedCount = 1
    
    //MARK: - 顶部视图 和 底部视图
    //顶部视图
    let topView = UIView()
    let topViewH: CGFloat = 70
    //底部视图
    let bottomView = UIView()
    let bottomViewH: CGFloat = 50
    //底部视图中显示选择个数的lable
    let countLable = UILabel()

    //数据源
    private var photos = PHFetchResult()
    //collectionView 布局
    private let flowLayout = UICollectionViewFlowLayout()
    //collectionView 用于显示图片
    private var myCollectionView: UICollectionView!
    //collectionView 复用标识
    private let cellID = "mycell"
    
    //定义一个数组用于保存已选择的图片
    private var selectedPhotosArray = [PHAsset]()
    
    //选择图片的数量大于给定的数量 给用户提示
    private var alertController = UIAlertController()
    
    //创建一个字典 用来存放Cell的唯一标示符 
    private var cellDict = [NSIndexPath: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.lightGrayColor()
        
        creatCollectionView()
        
        getAllPhotos()
        
        setTopView()
        
        setBottomView()
        
        initAlert()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initAlert() {
        alertController = UIAlertController(title: nil, message: "最多只能选择 \(maxSelectedCount) 张照片", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            
        }))
    }
    
    //MARK: - 定义闭包
    typealias myBlock = (assetArray: Array<PHAsset>) -> Void
    var selectedPhotosBlock: myBlock!
    //—————闭包回调——————
    func performSelectedPhotosBlock(callBack: myBlock) {
        selectedPhotosBlock = callBack
    }
    
    //MARK: - 设置topView 和 bottomView
    private func setTopView() {
        //设置topView
        topView.frame = CGRectMake(0, 0, screenW, topViewH)
        topView.backgroundColor = UIColor.whiteColor()
        view.addSubview(topView)
        //设置主标题
        let titleLable = UILabel()
        titleLable.text = "全部图片"
        titleLable.textAlignment = .Center
        titleLable.font = UIFont.systemFontOfSize(17.0)
        titleLable.textColor = UIColor.orangeColor()
        titleLable.frame = CGRectMake((topView.frame.size.width - 80) / 2, (topView.frame.size.height - 16 - 20) / 2 + 16, 80, 20)
        topView.addSubview(titleLable)
        //设置主标题右侧的返回按钮
        let backButton = UIButton()
        backButton.setTitle("返回", forState: .Normal)
        backButton.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        backButton.setTitleColor(UIColor.init(red: 28/255, green: 124/255, blue: 255/255, alpha: 1.0), forState: .Normal)
        backButton.frame = CGRectMake(topView.frame.size.width - 50, (topView.frame.size.height - 16 - 20) / 2 + 16, 30, 20)
        topView.addSubview(backButton)
        backButton.addTarget(self, action: #selector(backToFront), forControlEvents: .TouchUpInside)
    }
    
    func backToFront() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func setBottomView() {
        //设置bottomView
        bottomView.backgroundColor = UIColor.init(red: 252/255, green: 201/255, blue: 23/255, alpha: 1.0)
        bottomView.frame = CGRectMake(0, screenH, screenW, 50)
        view.addSubview(bottomView)
        //设置用于显示选取的图片的个数的lable
        countLable.backgroundColor = UIColor.greenColor()
        countLable.textColor = UIColor.whiteColor()
        countLable.textAlignment = .Center
        countLable.frame = CGRectMake((bottomView.frame.size.width - 70) / 2, (bottomView.frame.size.height - 22) / 2, 22, 22)
        countLable.layer.cornerRadius = countLable.frame.size.width / 2
        countLable.layer.masksToBounds = true
        bottomView.addSubview(countLable)
        //设置完成按钮
        let completedButton = UIButton()
        completedButton.setTitle("完成", forState: .Normal)
        completedButton.titleLabel?.textAlignment = .Center
        completedButton.setTitleColor(UIColor.init(red: 28/255, green: 124/255, blue: 255/255, alpha: 1.0), forState: .Normal)
        completedButton.frame = CGRectMake((bottomView.frame.size.width - 70) / 2 + 28, (bottomView.frame.size.height - 20) / 2, 40, 20)
        completedButton.addTarget(self, action: #selector(completedBtnClick), forControlEvents: .TouchUpInside)
        bottomView.addSubview(completedButton)
    }
    func completedBtnClick() {
        if selectedPhotosBlock != nil {
            self.selectedPhotosBlock(assetArray: selectedPhotosArray)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - 获取系统所有照片
    private func getAllPhotos() {
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
        //获取所有照片的集合体
        let allOptions = PHFetchOptions()
        //对内部元素排序 按时间从近到远
        allOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        //将元素集合拆解开 allResults 内部是一个一个的PHAsset单元
        let allResults = PHAsset.fetchAssetsWithOptions(allOptions)
        
        //将数据赋值给数据源
        photos = allResults
        myCollectionView.reloadData()
        
    }
    //PHPhotoLibraryChangeObserver  第一次获取相册信息，这个方法只会进入一次
    func photoLibraryDidChange(changeInstance: PHChange) {
        getAllPhotos()
    }
    
    //MARK: - 创建collectionView
    private func creatCollectionView() {
        //设置每行显示四张图片（竖屏）
        let margin: CGFloat = 3
        let cellWidth = (screenW - 5 * margin) / 4
        
        //设置 Item 的 Size
        flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth)
        //设置 Item 的四周边距
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        //设置同一竖中上下相邻的两个 Item 之间的间距
        flowLayout.minimumLineSpacing = margin
        //设置同一行中相邻的两个 Item 之间的间距
        flowLayout.minimumInteritemSpacing = margin
        //设置collectionView
        myCollectionView = UICollectionView(frame: CGRectMake(0, topViewH, screenW, screenH - topViewH), collectionViewLayout: flowLayout)
        
        myCollectionView.backgroundColor = UIColor.whiteColor()
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
//        myCollectionView.registerClass(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        
        view.addSubview(myCollectionView)
    }
    
    //MARK: - 代理方法
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //给每一个cell注册一个ID
        var identifier = cellDict[indexPath]
        if identifier == nil {
            identifier = cellID + String(indexPath)
            cellDict[indexPath] = identifier
            myCollectionView.registerClass(MyCollectionViewCell.self, forCellWithReuseIdentifier: identifier!)
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier!, forIndexPath: indexPath) as! MyCollectionViewCell
        //展示图片CGSizeMake(screenW, screenH) 注意内存问题
        PHImageManager.defaultManager().requestImageForAsset(photos[indexPath.row] as! PHAsset, targetSize: CGSizeMake(150, 150), contentMode: .AspectFit, options: nil) { (result: UIImage?, dict: Dictionary?) in
            //将获取的图片显示出来
            cell.imageView.image = result
            if result == nil {
                PHImageManager.defaultManager().requestImageForAsset(self.photos[indexPath.row] as! PHAsset, targetSize: CGSizeZero, contentMode: .AspectFit, options: nil, resultHandler: { (result: UIImage?, dict: Dictionary?) in
                    cell.imageView.image = result ?? UIImage(named: "iw_none")
                })
            }
        }
        //  判断图片是否已经被选择
//        cell.isChoosed = isSelectedArray[indexPath.row].boolValue
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        print("选择")
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! MyCollectionViewCell
        
        if selectedPhotosArray.count == maxSelectedCount && !currentCell.isChoosed {
            presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            currentCell.isChoosed = !currentCell.isChoosed
            
            if currentCell.isChoosed {
                selectedPhotosArray.append(photos[indexPath.row] as! PHAsset)
                //            print(selectedPhotosArray.count)
            }
            else {
                if let index = selectedPhotosArray.indexOf(photos[indexPath.row] as! PHAsset) {
                    selectedPhotosArray.removeAtIndex(index)
                }
                //            print("未选择")
            }
            //显示选择数量
            countNumberShow()
        }
    }
    func countNumberShow() {
        
        var originY: CGFloat
        
        if selectedPhotosArray.count > 0 {
            originY = screenH - bottomViewH
//            myCollectionView.frame.size.height = screenH - topViewH - bottomViewH
        }
        else {
            originY = screenH
//            myCollectionView.frame.size.height = screenH - topViewH
        }
        //仿射变换
        UIView.animateWithDuration(0.3, animations: {
            if self.selectedPhotosArray.count > 0 {
                self.myCollectionView.frame.size.height = screenH - self.topViewH - self.bottomViewH
            }
            if self.selectedPhotosArray.count == 0 {
                self.myCollectionView.frame.size.height = screenH - self.topViewH
            }
            self.bottomView.frame.origin.y = originY
            self.countLable.text = String(self.selectedPhotosArray.count)
            UIView.animateWithDuration(0.2, animations: {
                self.countLable.transform = CGAffineTransformMakeScale(0.34, 0.34)
                self.countLable.transform = CGAffineTransformScale(self.countLable.transform, 3, 3)
            })
        })
    }
}

//MARK: - 自定义Cell类
class MyCollectionViewCell: UICollectionViewCell {
    
    let selectButton = UIButton()
    let imageView = UIImageView()
    //cell是否被选择
    var isChoosed = false {
        didSet {
            selectButton.selected = isChoosed
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        //设置图片
        imageView.frame = contentView.bounds
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        //设置选择按钮
        selectButton.frame = CGRectMake(contentView.bounds.size.width * 3 / 4, 2, contentView.bounds.size.width / 4, contentView.bounds.size.width / 4)
        selectButton.setBackgroundImage(UIImage(named: "iw_unselected"), forState: .Normal)
        selectButton.setBackgroundImage(UIImage(named: "iw_selected"), forState: .Selected)
        imageView.addSubview(selectButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

//
//  ViewController.swift
//  GetSystemAlbum
//
//  Created by 黄启明 on 16/8/22.
//  Copyright © 2016年 huatengIOT. All rights reserved.
//
//思路
//
//1.利用UIImagePickerController可以从系统自带的App(照片\相机)中获得图片
//2.设置代理,遵守代理协议
//注意这个UIImagePickerController类比较特殊,需要遵守两个代理协议
//@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
//3.实现代理的方法didFinishPickingMediaWithInfo


import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func getImgFromIPC(sender: AnyObject) {
        //判断相册是否可打开
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)  {
            let imgPicker = UIImagePickerController()
            //设置打开照片相册类型
            imgPicker.sourceType = .PhotoLibrary
            //设置代理
            imgPicker.delegate = self
            presentViewController(imgPicker, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //获取图片后的操作
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        image.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        image.contentMode = .ScaleAspectFill
    }
}


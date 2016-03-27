//
//  JWAnimatedImageView.swift
//  JWAnimatedImageExample
//
//  Created by 王佳玮 on 16/3/14.
//  Copyright © 2016年 JW. All rights reserved.
//

import ImageIO
import UIKit
let _gifImageKey = malloc(4)
let _cacheKey = malloc(4)
let _currentImageKey = malloc(4)
let _displayOrderIndexKey = malloc(4)
let _syncFactorKey = malloc(4)
let _haveCacheKey = malloc(4)
let _loopTimeKey = malloc(4)
public extension UIImageView{
    
    public func AddGifImage(gifImage:UIImage,manager:JWAnimationManager,loopTime:Int){
        if (manager.SearchImageView(self)==false){
            self.loopTime = loopTime
            self.gifImage = gifImage
            self.displayOrderIndex = 0
            self.syncFactor = 0
            self.cache = NSCache()
            self.currentImage = UIImage(CGImage: CGImageSourceCreateImageAtIndex(self.gifImage.imageSource!,0,nil)!)
            manager.AddImageView(self)
            self.haveCache = manager.CheckForCache(self)
            if(self.haveCache==true){//Init --> Display(cache)
                changetoCacheMode()
            }
            //else :Init --> Display(nocache)
        }else{
            
            self.loopTime = loopTime
            if(manager.CheckForCache(self)==true && self.haveCache==false){
                changetoCacheMode()
                
            }//Suspended(nocache) --> Display(cache)
            if(manager.CheckForCache(self)==false && self.haveCache==true){
                changetoNOCacheMode()
            }//Suspended(cache) --> Display(nocache)
            
            //else:Suspended(cache) --> Display(cache)
            //     Suspended(nocache) --> Display(nocache)
        }
    }
    
    public func AddGifImage(gifImage:UIImage,manager:JWAnimationManager){
        // -1 means always run
        AddGifImage(gifImage,manager: manager,loopTime: -1);
    }
    
    public func changetoNOCacheMode(){
        //Display(cache) --> Display(nocache)
        self.cache.removeAllObjects()
        self.haveCache = false
    }
    
    public func changetoCacheMode(){
        //Display(nocache) --> Display(cache)
        prepareCache()
        self.haveCache = true
    }
    
    public func updateCurrentImage(manager:JWAnimationManager){
        
        if(isDisplayedInScreen(self)==true){
            if(loopTime != 0){
                    if(self.haveCache==false){
                            self.currentImage = UIImage(CGImage: CGImageSourceCreateImageAtIndex(self.gifImage.imageSource!,self.gifImage.displayOrder![self.displayOrderIndex],nil)!)
                        }else{
                            self.currentImage = (cache.objectForKey(self.displayOrderIndex) as? UIImage)!
                    }
                updateIndex()
            }else{
                manager.DeleteImageView(self)
                //Display(cache) --> End(cache)
                //Display(nocache) --> End(nocache)
                //End(cache) --> End(nocache)
                //Auto:End(nocache) -->Init
                
            }
        }else{
            if(manager.CheckForCache(self)==false && self.haveCache==true){
                manager.DeleteImageView(self)
            }//Suspended(cache) --> Suspended(nocache)
            //Auto:Suspended(nocache) -->Init
        }
    }
    
    public func isDisplayedInScreen(imageView:UIImageView) ->Bool{
        //NOTE:This judge may not work in some cases,but does't cause crush.
        if (self.hidden||self.superview == nil) {
            return false;
        }
        let screenRect = UIScreen.mainScreen().bounds
        let viewRect = imageView.convertRect(self.frame, fromView:self.superview)
        let intersectionRect = CGRectIntersection(viewRect, screenRect);
        if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
            return false;
        }
        return true;
    }
    
    private func updateIndex(){
        self.syncFactor = (self.syncFactor+1)%gifImage.displayRefreshFactor!
        if(self.syncFactor==0){
            self.displayOrderIndex = (self.displayOrderIndex+1)%self.gifImage.imageCount!
            if(displayOrderIndex==0){
                self.loopTime -= 1;
            }
        }
    }
    
    private func prepareCache(){
        self.cache.removeAllObjects()
        for i in 0..<self.gifImage.displayOrder!.count {
            let image = UIImage(CGImage: CGImageSourceCreateImageAtIndex(self.gifImage.imageSource!,self.gifImage.displayOrder![i],nil)!)
            self.cache.setObject(image,forKey:i)
        }
    }
    
    public var gifImage:UIImage{
        get {
            return (objc_getAssociatedObject(self, _gifImageKey) as! UIImage)
        }
        set {
            objc_setAssociatedObject(self, _gifImageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
        public var currentImage:UIImage{
        get {
            return (objc_getAssociatedObject(self, _currentImageKey) as! UIImage)
        }
        set {
            objc_setAssociatedObject(self, _currentImageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    private var displayOrderIndex:Int{
        get {
            return (objc_getAssociatedObject(self, _displayOrderIndexKey) as! Int)
        }
        set {
            objc_setAssociatedObject(self, _displayOrderIndexKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    private var syncFactor:Int{
        get {
            return (objc_getAssociatedObject(self, _syncFactorKey) as! Int)
        }
        set {
            objc_setAssociatedObject(self, _syncFactorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    public var loopTime:Int{
        get {
            return (objc_getAssociatedObject(self, _loopTimeKey) as! Int)
        }
        set {
            objc_setAssociatedObject(self, _loopTimeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    private var haveCache:Bool{
        get {
            return (objc_getAssociatedObject(self, _haveCacheKey) as! Bool)
        }
        set {
            objc_setAssociatedObject(self, _haveCacheKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    private var cache:NSCache{
        get {
            return (objc_getAssociatedObject(self, _cacheKey) as! NSCache)
        }
        set {
            objc_setAssociatedObject(self, _cacheKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
}

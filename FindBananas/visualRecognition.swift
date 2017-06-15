//
//  visualRecognition.swift
//  FindBananas
//
//  Created by EricYang on 2017/6/12.
//  Copyright © 2017年 eric. All rights reserved.
//

import Foundation
import Alamofire

class visualRecognition{
    
    var imageClasses:[String] = []
    
    
    func classify(fileURL:URL, complete: @escaping DownloadComplete){
        
        let url = "\(url_base)api_key=\(apiKey)&version=\(version)"
        
        
        
        Alamofire.upload(fileURL, to: url).responseJSON { response in
            
            //print(response)
            
            self.imageClasses = []
            
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                
                if let Arr = dict["images"] as? [Dictionary<String, AnyObject>]{
                    
                    if let Arr2 = Arr[0]["classifiers"] as? [Dictionary<String, AnyObject>]{
                        
                        if let classesArr = Arr2[0]["classes"] as? [Dictionary<String, AnyObject>]{
                            
                            for vrclass in classesArr{
                                
                                if let c = vrclass["class"] as? String{
                                    self.imageClasses.append(c)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            print(self.imageClasses)
            complete()
            
        }
        
        
    }
    
    
}

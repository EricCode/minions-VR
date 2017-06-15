//
//  ViewController.swift
//  FindBananas
//
//  Created by EricYang on 2017/6/12.
//  Copyright © 2017年 eric. All rights reserved.
//

import UIKit
import SVProgressHUD
import Social
import AVFoundation

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var showMinion: UIView!

    
    let imagePicker = UIImagePickerController()
    let target = "banana"
    
    var classificationResults:[String] = []
    var musicPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        showMinion.transform = CGAffineTransform.init(scaleX: 0, y: 0)

        
    }
    
    func initAudio(){
        
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")!
        
        do{
            musicPlayer = try AVAudioPlayer(contentsOf: URL(string:path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            
        }catch let err as NSError{
            
            print(err.debugDescription)
        }
        
        
        
    }
    

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
        if let playMusic = musicPlayer?.isPlaying{
            
            if playMusic{
                
                musicPlayer.stop()
            }
        }
        
        
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        navigationItem.title = ""
        SVProgressHUD.show()
        showMinion.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            
            //build fileURL of the image
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
           
            // run visual recognition
            
            let vr = visualRecognition()
            
            vr.classify(fileURL: fileURL, complete: {
                
                var findTarget = false
                
                for imageC in vr.imageClasses{
                    
                    if imageC.contains(self.target){
                        
                        findTarget = true
                    }
                }
                
                if findTarget {
                    
                    DispatchQueue.main.async {
                        
                        
                        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica", size: 27.0)!, NSForegroundColorAttributeName : UIColor.white]
                        
                        self.navigationItem.title = "\(self.target.capitalized) !!!"

                        UIView.animate(withDuration: 0.5, animations: {
                            self.showMinion.transform = CGAffineTransform.identity
                        })
                        
                        self.initAudio()
                        
                    }
                    
                }else{
                    
                    DispatchQueue.main.async {
                        
                        
                        
                        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica", size: 27.0)!, NSForegroundColorAttributeName : UIColor.white]
                        

                        self.navigationItem.title = "\(vr.imageClasses[0].capitalized) ?"
                    }
                    
                }
                
                DispatchQueue.main.async {
                    
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }

            })
            
            
            
        }else{
            
            print("There was an error picking image")
        }
        
    }

    @IBAction func ShareTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            vc?.setInitialText("I find the favorite food of Minions -- Bananas")
            vc?.add(#imageLiteral(resourceName: "mininon with banana4"))
            present(vc!, animated: true, completion: nil)
        }
        
        if musicPlayer.isPlaying{
            musicPlayer.stop()

        }
        
    }
    
    @IBAction func OkTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 1, animations: {
            self.showMinion.transform = CGAffineTransform.init(translationX: 0, y: -1000)
        })
        
        if musicPlayer.isPlaying{
            musicPlayer.stop()
        }

        
    }
    

}


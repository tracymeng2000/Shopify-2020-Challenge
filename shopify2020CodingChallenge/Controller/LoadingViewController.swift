//
//  LoadingViewController.swift
//  shopify2020CodingChallenge
//
//  Created by Tracy Meng on 2019-09-16.
//  Copyright © 2019 Tracy Meng. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    
    var list = [Data]()
    var urlList = [URL]()
    var imageList = [UIImage]()
    var loaded : Bool = false
    private let host : String = "shopicruit.myshopify.com"
    private let productPath : String = "/admin/products.json"
    private let imagePath : String = "/admin/api/2019-07/products/"
    private let token = "c32313df0d0ef512ca64d5b336a0d7c6";
    private let getImageURL = "https://shopicruit.myshopify.com/admin/api/2019-07/products/";
    private let imageDotJSON = "/images.json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //reset list and load the images from url
        imageList.removeAll()
        urlList.removeAll()
        self.loadResouces()
    }
    

    func loadResouces(){
        let session = URLSession.shared
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = self.host
        urlComponents.path = self.productPath
        urlComponents.queryItems = [URLQueryItem(name: "access_token", value: self.token)]
        if let url = urlComponents.url {
            session.dataTask(with: url, completionHandler: {
                data, response, error in
                if let error = error{
                    print(error)
                    return
                }
                guard let data = data else{
                    print("missing data")
                    return
                }
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]{
                    if let products = json["products"] as? Array<[String : Any]>{
                        for p in products {
                            if let productId = p["id"] as? Int{
                                var urlToGetImage = URLComponents()
                                urlToGetImage.scheme = "https"
                                urlToGetImage.host = self.host
                                urlToGetImage.path =  self.imagePath + String(productId) + self.imageDotJSON
                                urlToGetImage.queryItems = [
                                    URLQueryItem(name: "access_token", value: self.token)
                                ]
                                if let imageURL = urlToGetImage.url{
                                    self.urlList.append(imageURL)
                                }
                            }
                        }
                    }
                }
                self.loadImages()
            }).resume()
        }
    }
    
    func loadImages (){
        let loadImageGroup = DispatchGroup()
        for imageURL in self.urlList{
            loadImageGroup.enter()
            let session = URLSession.shared
            session.dataTask(with: imageURL, completionHandler: {
                data, response, error in
                loadImageGroup.leave()
                if let error = error{
                    print(error)
                    return
                }
                guard let data = data else{
                    print("data fetch failed")
                    return
                }
                
                if let imageJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                    if let images = imageJson["images"] as? Array<[String : Any]>{
                        for image in images{
                            if let src = image["src"] as? String{
                                if let srcAsURL = URL(string: src){
                                    if let data = try? Data(contentsOf: srcAsURL as URL){
                                        if let image = UIImage(data: data as Data){
                                            self.imageList.append(image)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }).resume()
        }
        loadImageGroup.notify(queue: .main) {
            //loading finishes, goes to main screen
            self.performSegue(withIdentifier: "goToGame", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame"{
            let destVC = segue.destination as! GameViewController
            destVC.imageList = self.imageList
        }
    }
    
}


//
//  VideoThumbnailCollectionViewCell.swift
//  demoAmityTiktok
//
//  Created by Thanaphat Thanawatpanya on 3/10/2565 BE.
//

import UIKit
import AVFoundation
import Alamofire
import AlamofireImage

class VideoThumbnailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var videoThumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        /** Set video thumbnail to nil **/
        videoThumbnail.image = nil
    }
    
    func configure(post: PostModel) {
        /** Set video thumbnail by download image with Alamofire **/
        Alamofire.request(post.thumbnailPathURL!).responseImage { response in
            if case .success(let currentVideoThumbnail) = response.result {
                /** Set video thumbnail by amity data **/
                self.videoThumbnail.image = currentVideoThumbnail
            } else {
                /** Set video thumbnail by downloaded video **/
                if let video = post.amityVideoData {
                    self.setVideoThumbnailByVideoURL(videoURL: video.fileURL) { currentVideoThumbnail in
                        self.videoThumbnail.image = currentVideoThumbnail
                    }
                }
                
            }
        }
    }
    
    private func setVideoThumbnailByVideoURL(videoURL: String, completion: @escaping ((_ currentVideoThumbnail: UIImage?)->Void)) {
        let url = URL(fileURLWithPath: videoURL)
        DispatchQueue.global().async {
                let asset = AVAsset(url: url)
                let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                avAssetImageGenerator.appliesPreferredTrackTransform = true
                let thumnailTime = CMTimeMake(value: 2, timescale: 1)
                do {
                    let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                    let thumbImage = UIImage(cgImage: cgThumbImage)
                    DispatchQueue.main.async {
                        completion(thumbImage)
                    }
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
    }

}

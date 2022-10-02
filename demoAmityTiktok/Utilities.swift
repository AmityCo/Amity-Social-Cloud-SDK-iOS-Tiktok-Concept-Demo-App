//
//  Utilities.swift
//  demoAmityTiktok
//
//  Created by Thanaphat Thanawatpanya on 2/10/2565 BE.
//

import Foundation
import AmitySDK

struct Utilities {
    struct Amity {
        static func getConnectedClient() -> AmityClient? {
            let valueInAppDelegate = UIApplication.shared.delegate as? AppDelegate
            if let connectedClient = valueInAppDelegate?.amityClient {
                return connectedClient
            } else {
                return nil
            }
        }
    }
    
    struct UI {
        enum PopupType {
            case OK
            case OK_WITH_POP_VIEW
            case YES_NO
        }
        
        enum MediaType {
            case photo
            case video
        }
        
        static func showAlertPopup(title: String, detail: String, type: PopupType, recentViewController: UIViewController) {
            let alertWindow: UIAlertController = UIAlertController(title: title, message: detail, preferredStyle: .alert)
            
            switch type {
            case .OK:
                alertWindow.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: {_ in }))
            case .OK_WITH_POP_VIEW:
                alertWindow.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: { action in
                    recentViewController.navigationController?.popViewController(animated: true)
                }))
            case .YES_NO:
                alertWindow.addAction(UIAlertAction(title: NSLocalizedString("NO", comment: "NO"), style: .cancel, handler: {_ in }))
                alertWindow.addAction(UIAlertAction(title: NSLocalizedString("YES", comment: "YES"), style: .destructive, handler: { action in
                    recentViewController.navigationController?.popViewController(animated: true)
                }))
            }
            
            recentViewController.present(alertWindow, animated: true, completion: nil)
        }
        
        static func showProgressPopup(recentViewController: UIViewController) -> UIAlertController {
            let alertWindow = UIAlertController(title: "Progressing", message: "0%", preferredStyle: .alert)
            recentViewController.present(alertWindow, animated: true)
            return alertWindow
        }
        
        static func createChooseMediaMenu(recentViewController: UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate, mediaType: MediaType) {
            let choosePhotoMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cameraVC = UIImagePickerController()
            cameraVC.delegate = recentViewController
            cameraVC.allowsEditing = true
            
            switch mediaType {
            case .photo:
                cameraVC.mediaTypes = ["public.image"]
            case .video:
                cameraVC.mediaTypes = ["public.movie"]
            }
            
//            choosePhotoMenu.addAction(UIAlertAction(title: "Shoot \(mediaType)", style: .default, handler: { action in
//                print("Open camera for shoot \(mediaType)")
//                cameraVC.sourceType = .camera // Will deprecated
//
//                recentViewController.present(cameraVC, animated: true)
//            }))
            choosePhotoMenu.addAction(UIAlertAction(title: "Upload \(mediaType)", style: .default, handler: { action in
                print("Choose \(mediaType) from library")
                cameraVC.sourceType = .photoLibrary // Will deprecated

                recentViewController.present(cameraVC, animated: true)
            }))
            choosePhotoMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            recentViewController.present(choosePhotoMenu, animated: true)
        }
    }
    
    struct Time {
        static func getDateTimeTextByDateEachCase(dateInputed: Date) -> String{
            /** Set formatter **/
            let dayFormatter = DateFormatter()
            dayFormatter.timeZone = TimeZone.ReferenceType.local
            dayFormatter.dateFormat = "EEE"
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeZone = TimeZone.ReferenceType.local
            timeFormatter.dateFormat = "hh:mm a"
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.ReferenceType.local
            dateFormatter.dateFormat = "YYYY/MM/dd"
            
            /** Get Date now **/
            let dateNow = Date()
            
            /** Check date of date now and date inputed for set format each case **/
            if dateFormatter.string(from: dateNow) == dateFormatter.string(from: dateInputed) {
                /** Case 1 : date of date now and date inputed are same -> return time only **/
                return timeFormatter.string(from: dateInputed)
            } else {
                let last7days: Date = Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
                let rangeDateForGetDayOnly = last7days...dateNow
                
                if rangeDateForGetDayOnly.contains(dateInputed) {
                    /** Case 2 : date of date inputed is in range last 7 days -> return day only **/
                    return dayFormatter.string(from: dateInputed)
                } else {
                    /** Case 3 : date of date inputed is out of range last 7 days -> return full date time **/
                    return dateFormatter.string(from: dateInputed)
                }
            }
        }
        
        static func getTimeTextByDate(dateInputed: Date) -> String {
            /** Set formatter **/
            let timeFormatter = DateFormatter()
            timeFormatter.timeZone = TimeZone.ReferenceType.local
            timeFormatter.dateFormat = "hh:mm a"
            
            return timeFormatter.string(from: dateInputed)
        }
        
        static func getDateTimeTextByDate(dateInputed: Date) -> String {
            /** Set formatter **/
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.ReferenceType.local
            dateFormatter.dateFormat = "EEE, MMM dd"
            
            return dateFormatter.string(from: dateInputed)
        }
    }
}

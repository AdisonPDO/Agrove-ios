//
//  ScannerVC.swift
//  MaxiCoffee
//
//  Created by cyril chaillan on 12/08/2020.
//  Copyright © 2020 Devid. All rights reserved.
//

import AVFoundation
import UIKit
import Firebase

class ScannerVC: UIViewController {
    
    @IBOutlet var vCaptureRegion: UIView!
    @IBOutlet weak var activityResultScanner: UIActivityIndicatorView!
    
    var dismissDelegate: DismissDelegate?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoCaptureDevice: AVCaptureDevice?
    
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    private var handleAddToOwners: UInt?
    private var userAddToOwners: DatabaseReference?
    
    var popupMessage = NSLocalizedString("the_qr_code_information_is_not_recognized", comment: "the qr code information is not recognized")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initScanner()
        self.bindUI()
        self.subscribeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.dismissDelegate?.didDismiss()
        if let handleAddToOwners = handleAddToOwners {
            userAddToOwners?.removeObserver(withHandle: handleAddToOwners)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    private func bindUI() {
    }
    
    private func subscribeUI() {
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func dismissScanner(_ sender: UIButton) {
        ScannerService.shared.reset()
        self.dismiss(animated: true, completion: nil)
    }
}

extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    private func initScanner() {
        //        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        self.videoCaptureDevice = AVCaptureDevice.default(for: .video)
        if self.videoCaptureDevice == nil {
            return
        }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            self.failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.vCaptureRegion.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.vCaptureRegion.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    private func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("qr_error_code", comment: "qr error code"), style: .default))
        present(ac, animated: true)
        captureSession = nil
        self.popOKAlertController(title: NSLocalizedString("qr_error_code", comment: "qr error code"), message: popupMessage, okHandler: { _ in
            ScannerService.shared.reset()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    fileprivate func found(code: String) {
        let data = Data(code.utf8)
        self.activityResultScanner.startAnimating()
        print("code \(code)")
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                guard let id = json["_id"] as? String, let stage = json["etage"] as? Int else {
                    print("il passe pas le guard")
                    self.activityResultScanner.stopAnimating()
                    self.popOKAlertController(title: NSLocalizedString("qr_error_code", comment: "qr error code"), message: popupMessage, okHandler: { _ in
                        ScannerService.shared.reset()
                        self.dismiss(animated: true, completion: nil)
                    })
                    return
                }
                let type = json["type"] as? String ?? ""
                if (type == "parcelle") {
                    checkGardenerExistForParcelle(gardenerId: id, completion: { [weak self] gardener, existed  in
                        self?.setActionGardener(gardener: gardener, stage: stage, type: type, rangs: json["rangs"] as! Int?,gardenerParent:  json["gardenerParent"] as! String)
                    })
                } else {
                    //let dimens = json["dimension"] as! Int?
                    self.getGardernerBeforeLink(gardenerId: id, completion: { [weak self] gardener in
                        self?.setActionGardener(gardener: gardener, stage: stage, type: type, rangs: -1, gardenerParent: nil)
                    })
                }
            } else {
                print("il passe pas la verif json")
                ScannerService.shared.reset()
                self.dismiss(animated: true, completion: nil)
            }
        } catch let error as NSError {
            print("il passe pas du tout")
            self.activityResultScanner.stopAnimating()
            self.popOKAlertController(title: NSLocalizedString("qr_error_code", comment: "qr error code"), message: popupMessage, okHandler: { _ in
                ScannerService.shared.reset()
                self.dismiss(animated: true, completion: nil)
            })
            return
            //print("Failed to load: \(error.localizedDescription)")
        }
    }
    
    
    internal func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
    
    fileprivate func setActionGardener(gardener: GardenerModel, stage: Int, type: String, rangs: Int?, gardenerParent: String?) {
        print(gardener.metadata.name)
        let currentUser = Auth.auth().currentUser
        if let user = currentUser {
            if (gardener.owners.count > 0) {
                self.userBeforeAction(gardener: gardener, user: user)
            } else {
                let userRef = self.userRepository.getReference(for: user.uid)
                userRef.observeSingleEvent(of:.value, with: { (snapshot) in
                    let userModel = self.userTransformer.toUserModel(snap: snapshot)
                    if (userModel.gardenersGuest.contains(gardener.id) == true) {
                        self.activityResultScanner.stopAnimating()
                        self.popOKAlertController(title: NSLocalizedString("already_subscribe", comment: "already subscribe"), message: NSLocalizedString("you_have_already_subscribed_to_this_planter", comment: "you have already subscribed to this planter"), okHandler: { _ in
                            ScannerService.shared.reset()
                            self.dismiss(animated: true, completion: nil)
                        })
                    } else if (userModel.gardeners.contains(gardener.id) == true) {
                        self.activityResultScanner.stopAnimating()
                        self.popOKAlertController(title: NSLocalizedString("already_linked", comment: "already linked"), message: NSLocalizedString("you_already_have_this_planter_in_your_list", comment: "you already have this planter in your list"), okHandler: { _ in
                            ScannerService.shared.reset()
                            self.dismiss(animated: true, completion: nil)
                        })
                    } else {
                        self.sendToOwnerWithObserver(userId: user.uid, gardener)
                        var toValue = "\(stage)|\(gardener.id)"
                        switch type {
                        case "cle_en_main":
                            self.gardenerRepository.getReference(for: gardener.id).child("type").setValue("cle_en_main")
                        case "mural":
                            self.gardenerRepository.getReference(for: gardener.id).child("type").setValue("mural")
                        case "capteur":

                            var type = "Unknown"
                            print("AddGardenerService => \(AddGardenerService.shared.selectingTypeStruct)")
                            if let selectType = AddGardenerService.shared.selectingTypeStruct {
                                if (selectType.image == "type_pot") {
                                    type = "capteur_pot"
                                }
                                if (selectType.image == "type_jardinière") {
                                    type = "capteur_jardiniere"
                                }
                                if (selectType.image == "type_carre") {
                                    type = "capteur_carre"
                                    let dimension = AddGardenerService.shared.getDimension()
                                    toValue = "\(dimension! + 2)|\(gardener.id)"
                                }
                                
                                let dimension = AddGardenerService.shared.getDimension()
                                self.gardenerRepository.getReference(for: gardener.id).child("dimension").setValue(dimension)
                                self.gardenerRepository.getReference(for: gardener.id).child("type").setValue(type)
                            }
                        case "parcelle":
                            self.gardenerRepository.getReference(for: gardener.id).child("type").setValue("parcelle")
                            self.gardenerRepository.getReference(for: gardener.id).child("rangs").setValue(rangs!)
                            self.gardenerRepository.getReferenceTest(for: gardener.id).child("gardenerParent").setValue(gardenerParent!)
                        default:
                            "unknown"
                        }
                        
                        self.userRepository.getMetadataAddToOwnersReference(for: user.uid).setValue(toValue)
                        self.userRepository.getCurrentGardenerReference(for: user.uid).setValue(gardener.id)
                    }
                })
            }
        } else {
            print("GO TO READ LIKE NON-USER")
        }
    }
    
    fileprivate func getGardernerBeforeLink(gardenerId: String, completion: @escaping (_ gardener: GardenerModel) -> Void) {
        let reference = self.gardenerRepository.getReferenceTest(for: gardenerId)
        reference.observeSingleEvent(of: .value, with: { snap in
            if let value = snap.value {
                print(gardenerId)
                print(snap.exists())
                guard snap.exists() else {
                    self.popOKAlertController(title: NSLocalizedString("qr_error_code", comment: "qr error code"), message: self.popupMessage, okHandler: { _ in
                        ScannerService.shared.reset()
                        self.dismiss(animated: true, completion: nil)
                    })
                    return
                }
                let gardener = self.gardenerTransformer.toGardenerModel(snap: snap)
                completion(gardener)
            } else {
                self.popOKAlertController(title: NSLocalizedString("qr_error_code", comment: "qr error code"), message: self.popupMessage, okHandler: { _ in
                    ScannerService.shared.reset()
                    self.navigationController?.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
    
    fileprivate func checkGardenerExistForParcelle(gardenerId: String, completion: @escaping (_ gardener: GardenerModel, _ exist: Bool) -> Void) {
        let reference = self.gardenerRepository.getReference(for: gardenerId)
        reference.observeSingleEvent(of: .value, with: { snap in
            print(gardenerId)
            print(snap.exists())
            if (snap.exists()) {
                let gardener = self.gardenerTransformer.toGardenerModel(snap: snap)
                completion(gardener, false)
            } else {
                let parcelle = ParcelleGardener()
                let array = gardenerId.split(separator: "-")
                let dictParcelle = self.gardenerTransformer.toGardenerParcelle(parcelle, String(array[0]))
                reference.setValue(dictParcelle, withCompletionBlock: { (error, result) in
                    if (error == nil) {
                        reference.observeSingleEvent(of: .value, with: { snapParc in
                            var gardener = self.gardenerTransformer.toGardenerModel(snap: snapParc)
                            completion(gardener, false)
                        })
                    } else {
                        self.popOKAlertController(title: NSLocalizedString("qr_error_code", comment: "qr error code"), message: self.popupMessage, okHandler: { _ in
                            ScannerService.shared.reset()
                            self.navigationController?.dismiss(animated: true, completion: nil)
                        })
                    }
                })
            }
        })
    }
    
    fileprivate func sendToOwnerWithObserver(userId: String,_ gardener: GardenerModel) {
        userAddToOwners = self.userRepository.getMetadataAddToOwnersReference(for: userId)
        self.userAddToOwners?.observe(.value, with: { (snapResult) in
            let result = snapResult.value as? String
            switch result {
            case "ok":
                self.userAddToOwners?.removeValue()
                ScannerService.shared.gardener = gardener
                self.performSegue(withIdentifier: "goToModifyGardener", sender: nil)
                break;
            case "ko":
                self.userAddToOwners?.removeValue()
                PopAlertServices().pop(view: self, str: nil, title: "problem_of_twinning_at_the_planter", isDismiss: false)
                break;
            default:
                self.activityResultScanner.stopAnimating()
                break;
            }
        })
    }
    
    
    fileprivate func userBeforeAction(gardener: GardenerModel, user: User) {
        let userRef = self.userRepository.getReference(for: user.uid)
        userRef.observeSingleEvent(of:.value, with: { (snapshot) in
            let user = self.userTransformer.toUserModel(snap: snapshot)
            if (user.gardenersGuest.contains(gardener.id)) {
                self.activityResultScanner.stopAnimating()
                self.popOKAlertController(title: NSLocalizedString("already_subscribe", comment: "already subscribe"), message: NSLocalizedString("you_have_already_subscribed_to_this_planter", comment: "you have already subscribed to this planter"), okHandler: { _ in
                    ScannerService.shared.reset()
                    self.dismiss(animated: true, completion: nil)
                    
                })
            } else if (user.gardeners.contains(gardener.id)) {
                self.activityResultScanner.stopAnimating()
                self.popOKAlertController(title: NSLocalizedString("already_linked", comment: "already linked"), message: NSLocalizedString("you_already_have_this_planter_in_your_list", comment: "you already have this planter in your list"), okHandler: { _ in
                    ScannerService.shared.reset()
                    self.dismiss(animated: true, completion: nil)
                    
                })
            } else {
                self.activityResultScanner.stopAnimating()
                ScannerService.shared.reset()
                ScannerService.shared.showLinksGardener = true
                ScannerService.shared.gardener = gardener
                print("ICI")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}

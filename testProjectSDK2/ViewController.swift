//
//  ViewController.swift
//  testProjectSDK2
//
//  Created by Javier Alex Gonzalez on 03/05/24.
//

import UIKit
import KigoFramework

class ViewController: UIViewController, QRCodeReaderViewControllerDelegate, KigoScannerDelegate {
    func onError(_ error: KigoError) {
        print("status: \(error.status)")
        print("code: \(error.code)")
        print("message: \(error.message)")
        print("name: \(error.name)")
    }
    
    func onQRScanCompleted(_ qrScanResult: QRScanResult) {
        print("QR readed: \(qrScanResult.qrCode)")
        print("# Ticket: \(qrScanResult.ticket?.id)")
        print("Ticket checkInDate: \(qrScanResult.ticket?.checkIn?.checkInDate)")
        print("Parking Lot ID: \(qrScanResult.ticket?.parkingLot?.id)")
        print("Parking Lot Name: \(qrScanResult.ticket?.parkingLot?.parkingLotName)")
        
        if qrScanResult.ticket?.checkOut?.checkOutDate != nil {
            print("Gracias por tu Visita")
            print("Hora de Salida \(qrScanResult.ticket?.checkOut?.checkOutDate)")
        }else if qrScanResult.ticket?.checkIn?.checkInDate != nil{
            print("Bienvenido al Estacionamiento \(qrScanResult.ticket?.parkingLot?.parkingLotName)")
        }
    }
    
    let kigoSDK = KigoSDK(apiKey: "KigoKey1234")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard checkScanPermissions() else { return }
        let readerVC = kigoSDK.scanQrCode(context: self, devReference: "", userKigo: UserKigo(countryCode: "", mobilePhone: "", userName: "", userEmail: ""))
        present(readerVC, animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true) {
            KigoScanner.delegate = self
            KigoScanner.scanQrCode(qrCode: result.value, devReference: "", userKigo: UserKigo(countryCode: "", mobilePhone: "", userName: "", userEmail: ""))
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
      reader.stopScanning()

      dismiss(animated: true, completion: nil)
    }
    
    private func checkScanPermissions() -> Bool {
        do {
          return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
          let alert: UIAlertController

          switch error.code {
          case -11852:
            alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
              DispatchQueue.main.async {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                  UIApplication.shared.openURL(settingsURL)
                }
              }
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
          default:
            alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
          }

          present(alert, animated: true, completion: nil)

          return false
        }
      }
}


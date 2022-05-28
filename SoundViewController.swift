//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Mac 08 on 20/05/22.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    @IBOutlet weak var tiempolbl: UILabel!
    @IBOutlet weak var timeslider: UISlider!
    @IBOutlet weak var volumenslider: UISlider!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        
        volumenslider.isHidden = true
        
        volumenslider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
    }
    
    func configurarGrabacion(){
        do{
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //creando direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            //impresion de ruta donde se guardan los archivos
            print("****************")
            print(audioURL!)
            print("****************")
            
            //crear opciones para el grabador de audio
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError{
            print(error)
        }
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            //detener la grabacion
            grabarAudio?.stop()
            //cambiar texto del boton grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        }else{
            //empezar a grabar
            grabarAudio?.record()
            //cambiar el texto del boton grabar a detener
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            volumenslider.isHidden = false
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.prepareToPlay()
            reproducirAudio!.currentTime = 0
            timeslider.maximumValue = Float(reproducirAudio!.duration)
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.grabacionSlider), userInfo: nil, repeats: true)
            tiempolbl.text = "\(reproducirAudio!.currentTime)"
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in self.tiempolbl.text = "\(round(self.reproducirAudio!.currentTime*10)/10)"
            })
            reproducirAudio!.play()
            
            print("Reproduciendo")
            timeslider.isEnabled = true
        } catch {}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        let audiot = AVURLAsset(url: audioURL!)
        let timeAudio = audiot.duration
        let duracionSegundos = CMTimeGetSeconds(timeAudio)
        let horas:Int = Int(duracionSegundos / 3600)
        let minutos:Int =
            Int(duracionSegundos.truncatingRemainder(dividingBy: 3600) / 60)
        let segundos:Int =
            Int(duracionSegundos.truncatingRemainder(dividingBy: 60))
        let totalAudio: String = String(format: "%i:%02i:%02i", horas, minutos, segundos)
        print(totalAudio)
        grabacion.tiempo = String(totalAudio)
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    @objc func grabacionSlider(){
        timeslider.value = Float(reproducirAudio!.currentTime)
    }
    
    
    @IBAction func volumen(_ sender: UISlider) {
        reproducirAudio!.volume = sender.value
        print(sender.value)
    }
}

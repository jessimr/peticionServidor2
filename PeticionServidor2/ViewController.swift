//
//  ViewController.swift
//  PeticionServidor2
//
//  Created by JESSICA MENDOZA RUIZ on 18/03/2017.
//  Copyright © 2017 JESSICA MENDOZA RUIZ. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var titulo: UILabel!

    @IBOutlet weak var listaAutores: UITableView!
    
    @IBOutlet weak var portadaLibro: UIImageView!
    
    var names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textField.returnKeyType = UIReturnKeyType.search
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sincrono (texto: String){
        
        //Dir servidor
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(texto)"
        //Convertir la dir en URL
        let url = NSURL(string: urls)
        //Peticion al servidor, esperar respuesta y asociarla a la variable data
        let datos: NSData? = NSData(contentsOf: url! as URL)
        
        
        if (datos != nil){
            do{
                
                let json = try JSONSerialization.jsonObject(with: datos as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! AnyObject
                print(json)
                
                if let isbn = json["ISBN:\(self.textField.text!)"] as? [String : AnyObject]{
                    if let titulo = isbn["title"] as? String {
                        print(titulo)
                        self.titulo.text = titulo as! String?
                    }
                    
                    if let autores = isbn["authors"] {
                        for index in 0...autores.count-1 {
                            
                            let nombre = autores[index] as! [String : AnyObject]
                            
                            names.append(nombre["name"] as! String)
                            
                        }
                        self.listaAutores.reloadData()
                        print (names)
                        
                    }
                    if let portada = isbn["cover"] as? [String : AnyObject] {
                        if let imagen = portada["small"] as? String {
                            let urlImagen = URL(string: imagen)
                            let dataImagen = try? Data(contentsOf: urlImagen!)
                            portadaLibro.image = UIImage(data: dataImagen!)
                            print (imagen)
                        }
                    }else{
                        portadaLibro.image = nil
                    }
                }
                
            }
            catch _ {
                
            }
        }else{ //Si no hay datos (fallo en la conexión a Internet)
            //Mostrar mensaje de error
            mostrarAlerta()
            
        }
        
    }
    //Esconder teclado cuando se pulsa fuera (no funciona con el scroll)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Acciones al pulsar buscar (Esconder teclado cuando se da a intro y buscar libro)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        let texto = textField.text
        self.sincrono(texto: texto!)
        return true
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return(names.count)
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = names[indexPath.row]
        self.names.removeAll()
        return(cell)
    }
    
    func mostrarAlerta() {
        let alerta = UIAlertController(title: "Error de conexión", message: "Revise su conexión a Internet", preferredStyle: .alert)
        let continueAccion = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alerta.addAction(continueAccion)
        self.present(alerta, animated: true, completion: nil)
        
    }

}


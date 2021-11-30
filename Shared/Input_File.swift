//
//  Input_File.swift
//  SelfConsistent_Hartree_Fock_Slater_non_relativistic
//
//  Created by Varrick Suezaki on 8/11/18.
//  Copyright © 2018 Varrick Suezaki. All rights reserved.
//

import Cocoa

class Input_File: NSObject {
    
    var myHartreeFockSCFCalculator: HermanSkillmanCalculator? = nil
    
    
    // Opens Finder and returns URL of selected file
    func get_user_file_path() -> URL {
        
        let geFilePanel: NSOpenPanel = NSOpenPanel()
        var filePath :URL = URL(string:("file://"))!
        
        geFilePanel.runModal()
        
        // Get the file path from the NSSavePanel
        
        filePath = URL(string:("file://" + (geFilePanel.url?.path)!))!
        
        return(filePath)
        
    }
    
    /// Name: read_DAT_110pt_inputfile
    /// Description: Reads input file URL (must be in the specified 110 point potential form) and returns a tuple with all the information
    ///
    /// - Parameter input_file_path: URL of 110 point potential input file
    /// - Returns: Returns tuple containing following information: out (atom name, Z, exchange_alpha, KEY, BETA, THRESH, mesh_count, MAXIT, KUT, RADION, BRATIO, XION, # core shells, #val shells, potential values, electron configuration)
    //func read_DAT_110pt_inputfile(input_file_path: String) -> (String, Double, Double, Int, Double, Double,
    
    func read_DAT_110pt_inputfile(input_file_string: String) -> (String, Double, Double, Int, Double, Double, Double, Int, Int, Double, Double, Double, Int, Int, [Double], [(quant_n: Double, quant_l: Double, quant_m: Double, numb_electrons: Double, trial_energy: Double)]) {
        
        // Variables to store input file data
        var read_name: String = ""
        var read_z_value: Double = 0.0
        var read_exchange_alpha: Double = 0.0
        var read_KEY: Int = 0
        var read_BETA_TOL: Double = 0.0
        var read_THRESH: Double = 0.0
        var read_mesh_count: Double = 0.0
        var read_MAXIT: Int = 0
        var read_KUT: Int = 0
        var read_RADION: Double = 0.0
        var read_BRATIO: Double = 0.0
        var read_XION: Double = 0.0
        var read_core_electrons: Int = 0
        var read_val_electrons: Int = 0
        var read_pot_list: [Double] = []
        var read_electron_config_array: [(quant_n: Double, quant_l: Double, quant_m: Double, numb_electrons: Double, trial_energy: Double)] = []
        
        
        do {
            // turns input.dat file into array of string values, cuts out extra lines and empty spaces
            //let contents: String = try String(contentsOf: input_file_path)
            let contents: String = input_file_string
            
            var contents_array: [String] = contents.components(separatedBy: "\n")
            contents_array = contents_array.filter({$0 != ""})
            var input_start_index: Int = 0
            
            // finds index of string array element that starts with "CONT"
            string_loop: for i in contents_array {
                
                let check_CONT_index = i.index(i.startIndex, offsetBy: 4)
                let check_CONT_string: String = String(i.prefix(upTo: check_CONT_index))
                
                if check_CONT_string == "CONT" {
                    input_start_index = contents_array.firstIndex(of: i)!
                    break string_loop
                }
                
            }
            // cuts off anything above line with "CONT"
            contents_array = Array(contents_array[input_start_index...])
            read_name = contents_array[1]
            print(read_name)
            contents_array = contents_array.map({String($0.dropLast())})
            
            
            // reads and assigns following values:  [KEY] [TOL] [THRESH] [MESH] [IPRATT] [MAXIT] [KUT] [RADION] [RATIO] [ALPHA]
            var line03_params: [String] = contents_array[2].components(separatedBy: " ")
            line03_params = line03_params.filter({$0 != ""})
            read_KEY = Int(line03_params[0])!
            read_BETA_TOL = Double(line03_params[1])!
            read_THRESH = Double(line03_params[2])!
            read_mesh_count = Double(line03_params[3])!
            read_MAXIT = Int(line03_params[5])!
            read_KUT = Int(line03_params[6])!
            read_RADION = Double(line03_params[7])!
            read_BRATIO = Double(line03_params[8])!
            read_exchange_alpha = Double(line03_params[9])!
            
            // reads in 110pt pot as string, converts it to a list of Doubles
            let new_pot_string: String = Array(contents_array[3...13]).reduce("",+)
            var new_pot_string_array: [String] = new_pot_string.components(separatedBy: " ")
            new_pot_string_array = new_pot_string_array.filter({$0 != ""})
            read_pot_list = new_pot_string_array.map({Double($0)!})
            
            // reads and assigns following values: [Z] [NCORES] [NVALES] [XION]
            var line15_params: [String] = contents_array[14].components(separatedBy: " ")
            line15_params = line15_params.filter({$0 != ""})
            read_z_value = Double(line15_params[0])!
            read_core_electrons = Int(line15_params[1])!
            read_val_electrons = Int(line15_params[2])!
            read_XION = Double(line15_params[3])!
            
            // Reads orbital quantum numbers and stores in read_electron_config_array
            for i in 15..<contents_array.count-1 {
                
                // Filters out spaces and empty array elements
                var electron_config_string: [String] = contents_array[i].components(separatedBy: " ")
                electron_config_string = electron_config_string.filter({$0 != ""})
                
                let quant_string_list: [String] = electron_config_string[0].map({String($0)})
                
                read_electron_config_array.append((quant_n: Double(quant_string_list[0])!, quant_l: Double(quant_string_list[1])!, quant_m: Double(quant_string_list[2])!, numb_electrons: Double(electron_config_string[1])!, trial_energy: Double(electron_config_string[2])!))
                
                
            }
            
        // If failed to read input file of selected URL, prints error message
        } catch {
            
           // print("Failed reading from URL: \(input_file_path), Error: " + error.localizedDescription)
            print("Failed reading from URL: \(input_file_string), Error: " + error.localizedDescription)
        }
        
        return(read_name, read_z_value, read_exchange_alpha, read_KEY, read_BETA_TOL, read_THRESH, read_mesh_count, read_MAXIT, read_KUT, read_RADION, read_BRATIO, read_XION, read_core_electrons, read_val_electrons, read_pot_list, read_electron_config_array)
        
    }
    
}

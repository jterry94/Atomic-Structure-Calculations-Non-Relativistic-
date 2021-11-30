//
//  HermanSkillmanCalculator.swift
//  HermanSkillmanCalculator
//
//  Created by Jeff_Terry on 11/29/21.
//

import Foundation


import Foundation
import SwiftUI
import CorePlot

class HermanSkillmanCalculator: ObservableObject {
    
    var plotDataModel: PlotDataClass? = nil
    // Class instances
    let functional_functions_inst = Functional_Functions()
    let hfs_textbook_values_inst = HFS_textbook_values()
    let wavefunction_values_inst = WaveFunction_Values()
    let schrod_eq_subroutine_inst = Schroedinger_Eq_SubRoutine()
    let mesh_potential_init_inst = Mesh_Potential_Initialization()
    let self_consistent_potentials_inst = Self_Consistent_Potentials()
    let input_file_inst = Input_File()
    let output_file_inst = Output_File()
    var orbital_energies :[String] = []
    var element = ""
    var inputFileString = ""
    
    var alpha = 0.75
    
    let file_path_input = "file:///Users/jterry94/Downloads/input6.dat"
    
    // Arrays that store all calculated values including energy, potential and weave function values
    var results_array: [(r_list: [Double], psi_list: [Double], quant_n: Double, quant_l: Double, quant_m: Double, number_electrons: Double, new_energy: Double)] = []
    var self_consistent_pot_list: [Double] = []
    var full_mesh: [Double] = []
    
    
    
    // Calculate NonRelativisticHartreeFock:
    // After parameters have been set and the input file has been selected, this function starts the Herman-Skillman program.  Messages and values will be printed in the terminal to help inform the user such as the beta value of the current iteration
    func calculateNonRelativisticHartreeFock() {
        
      
        
        //output: (atom name, Z, exchange_alpha, KEY, BETA, THRESH, mesh_count, MAXIT, KUT, RADION, BRATIO, XION, # core shells, #val shells, potential values, electron configuration)
        //let read_input_file_tuple = input_file_inst.read_DAT_110pt_inputfile(input_file_path: URL(string: file_path_input)!)
        
            
        let read_input_file_tuple = input_file_inst.read_DAT_110pt_inputfile(input_file_string: inputFileString)
        
        
        let atom_name: String = read_input_file_tuple.0
        let z_value: Double = read_input_file_tuple.1
        let exchange_alpha: Double = read_input_file_tuple.2
        let KEY: Int = read_input_file_tuple.3
        let beta_criterion: Double = read_input_file_tuple.4
        let thresh_criterion: Double = read_input_file_tuple.5
        let mesh_count: Double = read_input_file_tuple.6
        let max_beta_iterations: Int = read_input_file_tuple.7
        let ionic_radius: Double = read_input_file_tuple.9
        let branching_ratio: Double = read_input_file_tuple.10
        let ionticity: Double = read_input_file_tuple.11
        let core_shells: Int = read_input_file_tuple.12
        let val_shells: Int = read_input_file_tuple.13
        let user_input_pot_list: [Double] = read_input_file_tuple.14
        let electron_config_array: [(quant_n: Double, quant_l: Double, quant_m: Double, numb_electrons: Double, trial_energy: Double)] = read_input_file_tuple.15
        
        let scalar: Double = (1.0/2.0)*pow((3.0*Double.pi)/4.0, 2.0/3.0)*pow(z_value, -1.0/3.0)
        let max_thresh_iterations: Int = 21
        let number_of_blocks: Double = (mesh_count - 1.0)/40.0
        let number_points: Double = 40.0
        let delta_x_initial: Double = 0.0025
        //var pratt_alpha: Double = 0.9
        var pratt_alpha: Double = 0.7
        
        element = atom_name
        
        pratt_alpha = alpha
        
        self_consistent_potentials_inst.myHartreeFockSCFCalculator = self
        output_file_inst.myHartreeFockSCFCalculator = self

        
        // Times the main section of the code starting from this line
        let t1 = mach_absolute_time()
        
        // Array tuple that calls main program and stores its values
        let results_array_tuple = self_consistent_potentials_inst.self_consistent_potential(z_value: z_value, delta_x_initial: delta_x_initial, number_of_blocks: number_of_blocks, scalar: scalar, number_points: number_points, user_input_pot_list: user_input_pot_list, core_shells: core_shells, val_shells: val_shells, electron_config_array: electron_config_array, beta_criterion: beta_criterion, exchange_alpha: exchange_alpha, pratt_alpha: pratt_alpha, KEY: KEY, thresh_criterion: thresh_criterion, max_beta_iterations: max_beta_iterations, max_thresh_iterations: max_thresh_iterations, ionic_radius: ionic_radius, branching_ratio: branching_ratio, ionticity: ionticity)
        
        // Separates 'results_array_tuple' into three arrays, wavefunction/energy values, potential values and r mesh values
        results_array = results_array_tuple.0
        self_consistent_pot_list = results_array_tuple.1
        full_mesh = results_array_tuple.2
        
        // Ends timing of main section of code
        let t2 = mach_absolute_time()
        
        // Calculates and prints run time of the main code
        let elapsed = t2 - t1
        var timeBaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timeBaseInfo)
        let elapsedNano = elapsed * UInt64(timeBaseInfo.numer) / UInt64(timeBaseInfo.denom);
        
        print("Execution time for the code is:  \(Double(elapsedNano)*1.0E-09) seconds")
        print("")
        
        // Prints r mesh and corresponding potential value
        for i in 0..<self_consistent_pot_list.count {
            print(full_mesh[i], full_mesh[i]/scalar, self_consistent_pot_list[i]/(-2.0*z_value))
        }
        
        // Removes all values from 'orbital_energies' drop down menu
        orbital_energies.removeAll()
        
        // Adds newly calculated orbital energies with correesponding quantum numbers as items in drop down menu.
        for i in results_array {
            
            orbital_energies.append("\(Int(i.quant_n))\(Int(i.quant_l))\(Int(i.quant_m)): \(i.new_energy)")
        }
        
        // Creates an energy output file and wave function/potential output file.
        output_file_inst.make_energy_output_file(atom_name: atom_name, z_value: z_value, final_results_array: results_array)
        output_file_inst.make_wf_pot_output_file(atom_name: atom_name, z_value: z_value, final_results_array: results_array, self_consistent_pot_list: self_consistent_pot_list)
        
        
        
    }

    

}

//
//  Mesh_Potential_Initialization.swift
//  SelfConsistent_Hartree_Fock_Slater_non_relativistic
//
//  Created by Varrick Suezaki on 8/11/18.
//  Copyright © 2018 Varrick Suezaki. All rights reserved.
//

import Foundation

class Mesh_Potential_Initialization: NSObject {
    
    var r_mesh: [Double] = [0.0]
    var trial_pot_list: [Double] = []
    var KE_term_list: [Double] = []
    var delta_r_list: [Double] = []
    
    // Tuples that stores the block number, index of point with reference to the current block, and index of point with reference to the entire mesh for r value where KE crosses 0 (KE_term_list) and outer radius
    var KE_cross_index_tuple: (KE_cross_index_block: Int, KE_cross_block_number: Int, KE_cross_index_univ: Int) = (KE_cross_index_block: 0, KE_cross_block_number: 0, KE_cross_index_univ: 0)
    var outer_radius_index_tuple: (outer_radius_index_block: Int, outer_radius_block_number: Int, outer_radius_index_univ: Int) = (outer_radius_index_block: 0, outer_radius_block_number: 0, outer_radius_index_univ: 0)
    
    var outer_radius_index: Int = 0
    var outer_radius_value: Double = 0.0
    
    /// Name: initialize_r_mesh
    /// Description: Initializes the r-mesh based on user input (number of blocks, number of points per block etc.), stores values in r_mesh array.
    ///
    /// - Parameters:
    ///   - number_blocks: Number of blocks in mesh
    ///   - x_to_r_scalar: Scalar to go from x to r values
    ///   - delta_x_initial: Initial step in x values
    ///   - number_points: Number of points per block
    func initialize_r_mesh(number_blocks: Double, x_to_r_scalar: Double, delta_x_initial: Double, number_points: Double){
        
        // Loop for every block
        for i in stride(from: 0.0, to: number_blocks, by: 1.0){
            
            // Initializes the x-step interval for current block, doubles for each consecutive block
            let delta_x_interval: Double = delta_x_initial*pow(2.0, i)
            
            // Loop for every point
            for _ in stride(from: 1.0, to: number_points + 1.0, by: 1.0){
                r_mesh.append(r_mesh.last! + delta_x_interval)
            }
            
        }
        // Multiplies all r_mesh values by x_to_r_scalar to convert x values to r values
        r_mesh = r_mesh.map({$0*x_to_r_scalar})
    }
    
    /// Name: initialize_pot_list
    /// Description: Initializes potential values list, converts r*V(r) values to V(r) values by dividing input potential values by r_mesh values.  Stores values in trial_pot_list array
    ///
    /// - Parameters:
    ///   - input_pot_list: Input potential values list (actually r*V(r))
    ///   - scaled_r_list: r_mesh values calculated from initialize_r_mesh
    ///   - number_blocks: Number of blocks in mesh
    ///   - number_points: Number of points per block
    func initialize_pot_list(input_pot_list: [Double], scaled_r_list: [Double], number_blocks: Double, number_points: Double){
        
        // Initializes first value of input potential list which is 0
        trial_pot_list.append(input_pot_list[0])
        
        // Loops over every input potential value, converts r*(v(r) to V(r)
        for i in 1 ..< (input_pot_list.count){
            let new_value: Double = input_pot_list[i]/scaled_r_list[i]
            trial_pot_list.append(new_value)
        }

    }
    
    /// Name: initialize_KE_term_list
    /// Description: Calculates KE terms Q(r) where Q(r) = V(r) + l(l+1)/(r^2) - E which is related to the schrodinger: ((d/dr)^2)*P(r) = -Q(r)*P(r) where P(r) = r*Psi(r).  Also finds r value index for which KE value crosses 0 and approximates outer radius point based on r value of crossing.
    ///
    /// - Parameters:
    ///   - scaled_pot_list: trial_pot_list values calculated from initialize_pot_list
    ///   - scaled_r_list: r_mesh values calculated from initialize_r_mesh
    ///   - l_quant_number: l quantum number
    ///   - input_energy: Input trial energy
    ///   - number_blocks: Number of blocks in mesh
    ///   - number_points: Number of points per block
    func initialize_KE_term_list(scaled_pot_list: [Double], scaled_r_list: [Double], l_quant_number: Double, input_energy: Double, number_blocks: Double, number_points: Double){
        
        // Initializes first KE term value
        KE_term_list.append(scaled_pot_list[0] + input_energy)
        
        // Loops over each potential value, calculates Q(r) value and stores it in KE_term_list array
        for i in 1 ..< (scaled_pot_list.count){
            
            // Calculates Q(r) (actually -Q(r))
            let new_gn_value: Double = -scaled_pot_list[i] - ((pow(l_quant_number, 2.0) + l_quant_number)/pow(scaled_r_list[i], 2.0)) + input_energy
            KE_term_list.append(new_gn_value)
            
        }
        
        // Loops over values in KE_term_list and finds where it crosses from positive to negative (should be where KE goes from negative to positive indicating a binding radius, but KE_term_list is actually -Q(r))
        for i in 1 ..< (KE_term_list.count-1){
            
            if KE_term_list[i] > 0.0 && KE_term_list[i+1] < 0.0 {
                
                // Adds index to KE_cross_index_tuple
                KE_cross_index_tuple = (KE_cross_index_block: i%Int(number_points), KE_cross_block_number: (i/Int(number_points))+1, KE_cross_index_univ: i)
                break
                
            }
            
        }
        
        // If quantum number l is 0, outer radius is 8 times that of matching radius (where KE values cross 0), else outer radius is (5+l) times matching radius
        if l_quant_number == 0.0 {
            outer_radius_value = 8.0*scaled_r_list[KE_cross_index_tuple.KE_cross_index_univ]
        } else {
            outer_radius_value = (5.0 + l_quant_number)*scaled_r_list[KE_cross_index_tuple.KE_cross_index_univ]
        }
        
        // Creates array of values of absolute difference between r_mesh values and calcualted outer radius value.  Minimum is the index of r_mesh value closest to calculated outer radius value.
        delta_r_list = scaled_r_list.map({abs($0 - outer_radius_value)})
        outer_radius_index = delta_r_list.firstIndex(of: delta_r_list.min()!)!
        
        // If the calculated outer radius index is larger than the largest index of the r_mesh array, set the outer radius to the second to last value of r_mesh
        if outer_radius_index >= scaled_r_list.count-1 {
            outer_radius_index = scaled_r_list.count-2
        }
        
        // Adds calculated index values to outer_radius_index_tuple
        outer_radius_index_tuple = (outer_radius_index_block: outer_radius_index%Int(number_points), outer_radius_block_number: (outer_radius_index/Int(number_points))+1, outer_radius_index_univ: outer_radius_index)
        
    }
    
    /// Name: initialize_mesh_pot_KE
    /// Description: Combines three previous functions into one to initialize r_mesh, trial_pot_list and KE_term_list at the same time.
    ///
    /// - Parameters:
    ///   - number_blocks: Number of blocks in mesh
    ///   - x_to_r_scalar: Scalar to go from x to r values
    ///   - delta_x_initial: Initial step in x values
    ///   - input_pot_list: Input potential values list (actually r*V(r))
    ///   - l_quant_number: l quantum number
    ///   - input_energy: Input trial energy
    ///   - number_points: Number of points per block
    func initialize_mesh_pot_KE(number_blocks: Double, x_to_r_scalar: Double, delta_x_initial: Double, input_pot_list: [Double], l_quant_number: Double, input_energy: Double, number_points: Double){
        
        self.initialize_r_mesh(number_blocks: number_blocks, x_to_r_scalar: x_to_r_scalar, delta_x_initial: delta_x_initial, number_points: number_points)
        self.initialize_pot_list(input_pot_list: input_pot_list, scaled_r_list: r_mesh, number_blocks: number_blocks, number_points: number_points)
        self.initialize_KE_term_list(scaled_pot_list: trial_pot_list, scaled_r_list: r_mesh, l_quant_number: l_quant_number, input_energy: input_energy, number_blocks: number_blocks, number_points: number_points)
        
    }
    
}

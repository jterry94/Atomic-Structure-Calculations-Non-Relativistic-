//
//  Schroedinger_Eq_SubRoutine.swift
//  SelfConsistent_Hartree_Fock_Slater_non_relativistic
//
//  Created by Varrick Suezaki on 8/11/18.
//  Copyright © 2018 Varrick Suezaki. All rights reserved.
//

import Foundation

class Schroedinger_Eq_SubRoutine: NSObject {
    
    var myHartreeFockSCFCalculator: HermanSkillmanCalculator? = nil

    // Temporary arrays to hold r and wavefunction values for loops
    var test_final_values_list: [Double] = []
    var test_final_r_values_list: [Double] = []
    // number of times calculated wavefunction crosses 0
    var ncross: Double = 0.0
    
    /// Name: outward_integration
    /// Description: Uses numerov numerical integration method to solve schroedinger equation starting at origin (r=0.0)for certain neutral atom
    ///
    /// - Parameters:
    ///   - initial_r_list: Input initial radius list
    ///   - initial_KE_list: Input Kinetic energy term list
    ///   - number_blocks: Total number of mesh blocks
    ///   - l_number: Input quantum l number
    ///   - trial_psi0_guess: Initial trial input wavefunction value
    ///   - number_points: Number of points per block in mesh
    ///   - KE_index_tuple: Tuple of indices that hold index of crossing point (matching radius) from positive to negative for KE term in schroedinger (indicating the transfer from a negative to a positive KE, indicating a bound state).  Holds universal index, index with reference to current block, and block number
    ///   - outward_index_tuple: Tuple of inidces that hold index of outer radius
    func outward_integration(initial_r_list: [Double], initial_KE_list: [Double], number_blocks: Double, l_number: Double, trial_psi0_guess: Double, number_points: Double, KE_index_tuple: (KE_cross_index_block: Int, KE_cross_block_number: Int, KE_cross_index_univ: Int), outward_index_tuple: (outer_radius_index_block: Int, outer_radius_block_number: Int, outer_radius_index_univ: Int)){
        
        // instances of classes that are needed
        let schroed_functional_functions_inst = myHartreeFockSCFCalculator!.functional_functions_inst
        let schroed_wavefunction_values_inst = myHartreeFockSCFCalculator!.wavefunction_values_inst
        // Int version for number of points to be used in index slicing of arrays
        let number_points_int: Int = Int(number_points)
        // resets number of crosses each time outward integration function is used
        ncross = 0.0
        
        // variables to hold index values from KE tuple so values from tuple dont have to be called everytime
        let match_radius_index_univ: Double = Double(KE_index_tuple.KE_cross_index_univ)
        
        // For loop that loops over every block in mesh.  If its the first block, takes 40 points from r list and KE term list and uses it in numerov method to produce wavefunction values.  Every other block is 39 points (first one compensates for index 0)
        for i in stride(from: 0.0, to: Double(outward_index_tuple.outer_radius_block_number), by: 1.0){
            
            switch i {
                
            // First block
            case 0.0:
                
                // Range of r list values from each block based on universal index
                let temp_r_list: [Double] = Array(initial_r_list[(Int(i)*number_points_int)...((Int(i) + 1)*number_points_int)])
                // Range of KE list values from each block based on universal index
                let temp_gn_list: [Double] = Array(initial_KE_list[(Int(i)*number_points_int)...((Int(i) + 1)*number_points_int)])
                // Calculated wavefunction values from r list and KE list above
                let temp_wavefunction_list = schroed_functional_functions_inst.schrodinger_numerov_method(r_list: temp_r_list, gn_coeff_list: temp_gn_list, psi0: 0.0, psi1_guess: trial_psi0_guess)
                
                schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array.append((wavefunction_list: temp_wavefunction_list, block_number: (i + 1.0)))
                
            // Every other block
            default:
                
                // Range of r list values from each block based on universal index
                let temp_r_list: [Double] = Array(initial_r_list[((Int(i)*number_points_int) - 1)...((Int(i) + 1)*number_points_int)])
                // Range of KE list values from each block based on universal index
                let temp_gn_list: [Double] = Array(initial_KE_list[((Int(i)*number_points_int) - 1)...((Int(i) + 1)*number_points_int)])
                
                // Initial wavefunction values to start numerov method taken from previously calculated wavefunction values from previous block
                let temp_psi1: Double = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array.last!.wavefunction_list.last!.wavefunction_value
                let temp_psi0: Double = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array.last!.wavefunction_list[schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array.last!.wavefunction_list.count - 1 - 2].wavefunction_value
                
                // Calculated wavefunction values from r list and KE list above
                var temp_wavefunction_list = schroed_functional_functions_inst.schrodinger_numerov_method(r_list: temp_r_list, gn_coeff_list: temp_gn_list, psi0: temp_psi0, psi1_guess: temp_psi1)
                
                // removes initial guess values as we already have them (previous values from previous block, just needed them to start numerov method for current block wavefunction calculations)
                temp_wavefunction_list.remove(at: 0)
                temp_wavefunction_list.remove(at: 0)
                
                // Adds temp wavefunction list to array with corresponding block number
                schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array.append((wavefunction_list: temp_wavefunction_list, block_number: (i + 1.0)))
                
            }
            
        }
        
        // Adds values from outward integration values to temporary Double arrays
        for i in schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array{
            for j in i.wavefunction_list{
                test_final_values_list.append(j.wavefunction_value)
                test_final_r_values_list.append(j.r_value)
            }
        }
        
        // Checks number of times wavefunction values cross 0
        for i in 0...Int(match_radius_index_univ){
            
            let sign_check: Double = test_final_values_list[i]*test_final_values_list[i+1]
            
            let ncross_bool: Bool = sign_check < 0.0
            
            switch ncross_bool {
                
            case true:
                ncross += 1.0
            default:
                ncross += 0.0
            }
            
        }
        
    }
    
    
    /// Name: inward_integration
    /// Description: Uses numerov numerical integration method to solve schroedinger equation starting from calculated outer radius for certain neutral atom
    ///
    /// - Parameters:
    ///   - initial_r_list: Input initial radius list
    ///   - initial_KE_list: Input Kinetic energy term list
    ///   - number_blocks: Total number of mesh blocks
    ///   - l_number: Input quantum l number
    ///   - psi_n_guess: Wavefunction theoretical approximation at r value right after outer radius
    ///   - psi_n_minus1_guess: Wavefunction theoretical approximation at outer radius
    ///   - number_points: Number of points in each block
    ///   - initial_delta_x: First delta x value
    ///   - test_scalar: Mesh scalar
    ///   - outward_index_tuple: Tuple of inidces that hold index of outer radius
    ///   - KE_index_tuple: Tuple of indices that hold index of crossing point (matching radius) from positive to negative for KE term in schroedinger (indicating the transfer from a negative to a positive KE, indicating a bound state).  Holds universal index, index with reference to current block, and block number
    func inward_integration(initial_r_list: [Double], initial_KE_list: [Double], number_blocks: Double, l_number: Double, psi_n_guess: Double, psi_n_minus1_guess: Double, number_points: Double, initial_delta_x: Double, test_scalar: Double, outward_index_tuple: (outer_radius_index_block: Int, outer_radius_block_number: Int, outer_radius_index_univ: Int), KE_index_tuple: (KE_cross_index_block: Int, KE_cross_block_number: Int, KE_cross_index_univ: Int)){
        
        // instances of classes that are needed
        let schroed_functional_functions_inst = myHartreeFockSCFCalculator!.functional_functions_inst
        let schroed_wavefunction_values_inst = myHartreeFockSCFCalculator!.wavefunction_values_inst
        
        // number of points per block integer form for index slicing
        let number_points_int: Int = Int(number_points)
        
        // variables to hold index values from KE tuple and outward radius tuple so values from tuples dont have to be called everytime
        let outer_radius_index_univ: Int = outward_index_tuple.outer_radius_index_univ + 1
        let outer_radius_block_numb: Double = Double(outward_index_tuple.outer_radius_block_number)
        
        let match_radius_index_univ: Int = KE_index_tuple.KE_cross_index_univ - 1
        let match_radius_block_numb: Double = Double(KE_index_tuple.KE_cross_block_number)
        
        let equal_block_number: Bool = outer_radius_block_numb == match_radius_block_numb
        
        switch equal_block_number {
            
        case false:
            // For loop that loops backward starting at block number containing outer radius.  Refer to indexing section of README file
            for i in stride(from: outer_radius_block_numb - 1.0, to: match_radius_block_numb-2.0, by: -1.0){
                
                switch i {
                    
                // Outer radius block
                case (outer_radius_block_numb - 1.0):
                    
                    // Range of r list values from each block based on universal index
                    let temp_r_list: [Double] = Array(initial_r_list[Int(i*number_points)...outer_radius_index_univ])
                    // Range of KE list values from each block based on universal index
                    let temp_gn_list: [Double] = Array(initial_KE_list[Int(i*number_points)...outer_radius_index_univ])
                    
                    // Initial wavefunction values to start numerov method taken from previously calculated wavefunction values from previous block
                    let temp_wavefunction_list = schroed_functional_functions_inst.schrodinger_backward_numerov_method(r_list: temp_r_list, gn_coeff_list: temp_gn_list, psi_n_guess: psi_n_guess, psi_n_minus1_guess: psi_n_minus1_guess)
                    
                    // Adds temp wavefunction list to array with corresponding block number
                    schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.append((wavefunction_list: temp_wavefunction_list, block_number: (i + 1.0)))
                    
                // Matching radius block
                case (match_radius_block_numb-1.0):
                    
                    // Range of r list values from each block based on universal index
                    var temp_r_list: [Double] = Array(initial_r_list[match_radius_index_univ...((Int(i)+1)*number_points_int)])
                    // Interpolates average r values between blocks (step size must stay the same for numerov method, using inward integration is problematic due to step size decrease)
                    let block_middle_r_value: Double = (initial_r_list[(Int(i)+1)*number_points_int + 1] + initial_r_list[(Int(i)+1)*number_points_int])/2.0
                    temp_r_list.append(block_middle_r_value)
                    
                    // Range of KE list values from each block based on universal index
                    var temp_gn_list: [Double] = Array(initial_KE_list[match_radius_index_univ...((Int(i)+1)*number_points_int)])
                    // Interpolates average KE term values between blocks (step size must stay the same for numerov method, using inward integration is problematic due to step size decrease)
                    let block_middle_KE_value: Double = (initial_KE_list[(Int(i)+1)*number_points_int + 1] + initial_KE_list[(Int(i)+1)*number_points_int])/2.0
                    temp_gn_list.append(block_middle_KE_value)
                    
                    // Interpolates average wavefunction value between previous block and matching radius block (step size must stay the same for numerov method, using inward integration is problematic due to step size decrease)
                    let temp_psi_n: Double = (schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1].wavefunction_list[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1].wavefunction_list.count - 2].wavefunction_value + schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1].wavefunction_list[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1].wavefunction_list.count - 1].wavefunction_value)/2.0
                    let temp_psi_n_minus1: Double = schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1].wavefunction_list.last!.wavefunction_value
                    
                    // Initial wavefunction values to start numerov method taken from previously calculated wavefunction values from previous block
                    var temp_wavefunction_list = schroed_functional_functions_inst.schrodinger_backward_numerov_method(r_list: temp_r_list, gn_coeff_list: temp_gn_list, psi_n_guess: temp_psi_n, psi_n_minus1_guess: temp_psi_n_minus1)
                    
                    // removes initial guess values as we already have them (previous values from previous block, just needed them to start numerov method for current block wavefunction calculations)
                    temp_wavefunction_list.remove(at: 0)
                    temp_wavefunction_list.remove(at: 0)
                    
                    // Adds temp wavefunction list to array with corresponding block number
                    schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.append((wavefunction_list: temp_wavefunction_list, block_number: i+1.0))
                    
                // blocks in between block containing outer radius and block containing matching radius
                default:
                    
                    // Range of r list values from each block based on universal index
                    var temp_r_list: [Double] = Array(initial_r_list[(Int(i)*number_points_int)...((Int(i)+1)*number_points_int)])
                    // Interpolates average r values between blocks (step size must stay the same for numerov method, using inward integration is problematic due to step size decrease)
                    let block_middle_r_value: Double = (initial_r_list[(Int(i)+1)*number_points_int + 1] + initial_r_list[(Int(i)+1)*number_points_int])/2.0
                    temp_r_list.append(block_middle_r_value)
                    
                    // Range of KE list values from each block based on universal index
                    var temp_gn_list: [Double] = Array(initial_KE_list[(Int(i)*number_points_int)...((Int(i)+1)*number_points_int)])
                    // Interpolates average KE term values between blocks (step size must stay the same for numerov method, using inward integration is problematic due to step size decrease)
                    let block_middle_KE_value: Double = (initial_KE_list[(Int(i)+1)*number_points_int + 1] + initial_KE_list[(Int(i)+1)*number_points_int])/2.0
                    temp_gn_list.append(block_middle_KE_value)
                    
                    // Interpolates average wavefunction value between blocks (step size must stay the same for numerov method, using inward integration is problematic due to step size decrease)
                    let temp_psi_n: Double = (schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1].wavefunction_list[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1].wavefunction_list.count - 2].wavefunction_value + schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1].wavefunction_list[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1].wavefunction_list.count - 1].wavefunction_value)/2.0
                    let temp_psi_n_minus1: Double = schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1].wavefunction_list.last!.wavefunction_value
                    
                    // Initial wavefunction values to start numerov method taken from previously calculated wavefunction values from previous block
                    var temp_wavefunction_list = schroed_functional_functions_inst.schrodinger_backward_numerov_method(r_list: temp_r_list, gn_coeff_list: temp_gn_list, psi_n_guess: temp_psi_n, psi_n_minus1_guess: temp_psi_n_minus1)
                    
                    // removes initial guess values as we already have them (previous values from previous block, just needed them to start numerov method for current block wavefunction calculations)
                    temp_wavefunction_list.remove(at: 0)
                    temp_wavefunction_list.remove(at: 0)
                    
                    // Adds temp wavefunction list to array with corresponding block number
                    schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.append((wavefunction_list: temp_wavefunction_list, block_number: (i + 1.0)))
                    
                }
                
            }
            
        default:
            
            // Range of r list values from each block based on universal index
            let temp_r_list: [Double] = Array(initial_r_list[match_radius_index_univ...outer_radius_index_univ])
            // Range of KE list values from each block based on universal index
            let temp_gn_list: [Double] = Array(initial_KE_list[match_radius_index_univ...outer_radius_index_univ])
            
            // Initial wavefunction values to start numerov method taken from previously calculated wavefunction values from previous block
            let temp_wavefunction_list = schroed_functional_functions_inst.schrodinger_backward_numerov_method(r_list: temp_r_list, gn_coeff_list: temp_gn_list, psi_n_guess: psi_n_guess, psi_n_minus1_guess: psi_n_minus1_guess)
            
            // Adds temp wavefunction list to array with corresponding block number
            schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.append((wavefunction_list: temp_wavefunction_list, block_number: outer_radius_block_numb))
            
            
        }
        
        // Reverses inward wavefunction values tuple array as they were calculated backward
        schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array = schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.reversed()
        
        // Reverses wavefunction values list within each tuple as they were calculated backward
        for i in stride(from: 0, to: schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count, by: 1) {
            schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[i].wavefunction_list = schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[i].wavefunction_list.reversed()
        }
        
    }
    
    /// Name: outward_log_deriv_integral
    /// Description: Calculates integral for P^2 values from numerov outward integration values from origin to matching radius
    ///
    /// - Parameters:
    ///   - wavefunction_tuple_array: Array of tuples from numerov outward integration values
    ///   - initial_delta_x: First delta x value
    ///   - mesh_scalar: Mesh scalar
    ///   - KE_index_tuple: Tuple of indices that hold index of crossing point (matching radius) from positive to negative for KE term in schroedinger (indicating the transfer from a negative to a positive KE, indicating a bound state).  Holds universal index, index with reference to current block, and block number
    ///   - outward_index_tuple: Tuple of inidces that hold index of outer radius
    ///   - number_points: Number of points in each block
    func outward_log_deriv_integral(wavefunction_tuple_array: [(wavefunction_list: [(r_value: Double, wavefunction_value: Double)], block_number: Double)], initial_delta_x: Double, mesh_scalar: Double, KE_index_tuple: (KE_cross_index_block: Int, KE_cross_block_number: Int, KE_cross_index_univ: Int), outward_index_tuple: (outer_radius_index_block: Int, outer_radius_block_number: Int, outer_radius_index_univ: Int), number_points: Double) -> Double{
        
        // instances of classes that are needed
        let schroed_functional_functions_inst = myHartreeFockSCFCalculator!.functional_functions_inst
        
        // r list and P(r)^2 list
        let new_r_list: [Double] = test_final_r_values_list
        let new_psi_list: [Double] = test_final_values_list.map({pow($0, 2.0)})
        
        // integrates r and P(r)^2 list from 0 to KE crossing point
        let out_log_deriv_integral_value: Double = schroed_functional_functions_inst.integrate_mesh(x_list: new_r_list, y_list: new_psi_list, lower_bound_index: 0, upper_bound_index: KE_index_tuple.KE_cross_index_univ)
        
        return(out_log_deriv_integral_value)
        
    }
    
    /// Name: inward_log_deriv_integral
    /// Description: Calculates integral for P^2 values from numerov inward integration values from outer radius to matching radius
    ///
    /// - Parameters:
    ///   - wavefunction_tuple_array: Array of tuples from numerov inward integration values
    ///   - initial_delta_x: First delta x value
    ///   - mesh_scalar: Mesh scalar
    ///   - KE_index_tuple: Tuple of indices that hold index of crossing point (matching radius) from positive to negative for KE term in schroedinger (indicating the transfer from a negative to a positive KE, indicating a bound state).  Holds universal index, index with reference to current block, and block number
    ///   - outward_index_tuple: Tuple of inidces that hold index of outer radius
    ///   - number_points: Number of points in each block
    func inward_log_deriv_integral(wavefunction_tuple_array: [(wavefunction_list: [(r_value: Double, wavefunction_value: Double)], block_number: Double)], initial_delta_x: Double, mesh_scalar: Double, KE_index_tuple: (KE_cross_index_block: Int, KE_cross_block_number: Int, KE_cross_index_univ: Int), outward_index_tuple: (outer_radius_index_block: Int, outer_radius_block_number: Int, outer_radius_index_univ: Int), number_points: Double) -> Double{
        
        // instances of classes that are neeedd
        let schroed_functional_functions_inst = myHartreeFockSCFCalculator!.functional_functions_inst
        
        // r list and P(r)^2 list
        var new_r_list: [Double] = []
        var new_psi_list: [Double] = []
        
        // Adds values to above arrays, couldn't use an array to store values like outward integration due to indexing and starting from outer radius point to matching radius
        for i in wavefunction_tuple_array {
            for j in i.wavefunction_list {
                new_r_list.append(j.r_value)
                new_psi_list.append(pow(j.wavefunction_value, 2.0))
            }
        }
        
        // integrates r and P(r)^2 list from outer radius to matching radius
        let in_log_deriv_integral_value: Double = schroed_functional_functions_inst.integrate_mesh(x_list: new_r_list, y_list: new_psi_list, lower_bound_index: 1, upper_bound_index: new_r_list.count-2)
        
        return(in_log_deriv_integral_value)
        
    }
    
    /// Name: schroedinger_subroutine
    /// Description: Subroutine that combines all functions above to calculate self consistent wavefunction values for a given energy, potential input etc.
    ///
    /// - Parameters:
    ///   - z_value: Z value for atom you want to calculate wave functions for
    ///   - trial_energy: Input trial energy
    ///   - number_blocks: Total number of blocks in mesh
    ///   - l_number: Input quantum l number
    ///   - number_points: Total number of points in each block
    ///   - initial_delta_x: First delta x value
    ///   - mesh_scalar: Mesh scalar
    ///   - principal_quant_number: Input principal quantum number n
    ///   - input_pot_list: Input potential list (in the form of r*V(r))
    ///   - thresh_criterion: Acceptable value of deltaE/E
    ///   - max_thresh_iterations: Max number of iterations to check thresh criterion
    ///   - left_energy_scalar: Scalar for lower bound energy when checking log derivative
    ///   - right_energy_scalar: Scalar for upper bound energy when checking log derivative
    func schroedinger_subroutine(z_value: Double, trial_energy: Double, number_blocks: Double, l_number: Double, number_points: Double, initial_delta_x: Double, mesh_scalar: Double, principal_quant_number: Double, input_pot_list: [Double], thresh_criterion: Double, max_thresh_iterations: Int, left_energy_scalar: Double, right_energy_scalar: Double) {
        
        // instances of classes that are needed
        let schroed_functional_functions_inst = myHartreeFockSCFCalculator!.functional_functions_inst
        let schroed_wavefunction_values_inst = myHartreeFockSCFCalculator!.wavefunction_values_inst
        let schroed_mesh_potential_init_inst = myHartreeFockSCFCalculator!.mesh_potential_init_inst
        
        // variables that hold correct number of crosses, calculated number of crosses, and input trial energy
        let correct_numb_crosses: Double = principal_quant_number - l_number - 1
        var calculated_numb_crosses: Double = -1.0
        var ncross_energy_approx: Double = trial_energy
        
        // initializes  and calculates mesh, potential and KE list
        schroed_mesh_potential_init_inst.initialize_mesh_pot_KE(number_blocks: number_blocks, x_to_r_scalar: mesh_scalar, delta_x_initial: initial_delta_x, input_pot_list: input_pot_list, l_quant_number: l_number, input_energy: ncross_energy_approx, number_points: number_points)
        
        // variables to hold r mesh, KE list, KE index tuple and outward index tuple, everything but r mesh is updated for each iteration
        let initial_r_list = schroed_mesh_potential_init_inst.r_mesh
        var initial_KE_list: [Double] = []
        var KE_index_tuple: (KE_cross_index_block: Int, KE_cross_block_number: Int, KE_cross_index_univ: Int) = (KE_cross_index_block: 0, KE_cross_block_number: 0, KE_cross_index_univ: 0)
        var outward_index_tuple: (outer_radius_index_block: Int, outer_radius_block_number: Int, outer_radius_index_univ: Int) = (outer_radius_index_block: 0, outer_radius_block_number: 0, outer_radius_index_univ: 0)
        
        // while loop that calculates wavefunction values up to matching radius, counts crosses, and changes energy accordingly until correct number of crosses achieved
        while calculated_numb_crosses != correct_numb_crosses {
            
            schroed_mesh_potential_init_inst.KE_term_list.removeAll()
            // re-calculates KE list, KE index tuple and outward index tuple
            schroed_mesh_potential_init_inst.initialize_KE_term_list(scaled_pot_list: schroed_mesh_potential_init_inst.trial_pot_list, scaled_r_list: schroed_mesh_potential_init_inst.r_mesh, l_quant_number: l_number, input_energy: ncross_energy_approx, number_blocks: number_blocks, number_points: number_points)
            //print(schroed_mesh_potential_init_inst.KE_term_list.count)
            // gets values from mesh_potential_init instance
            initial_KE_list = schroed_mesh_potential_init_inst.KE_term_list
            KE_index_tuple = schroed_mesh_potential_init_inst.KE_cross_index_tuple
            outward_index_tuple = schroed_mesh_potential_init_inst.outer_radius_index_tuple
            
            // guess for second wavefunction value (first is 0)
            let trial_psi0_guess: Double = schroed_wavefunction_values_inst.wf_origin_boundary_approximation(second_potential_value: schroed_mesh_potential_init_inst.trial_pot_list[1], third_potential_value: schroed_mesh_potential_init_inst.trial_pot_list[2], second_rmesh_value: schroed_mesh_potential_init_inst.r_mesh[1], z_value: z_value, energy_value: ncross_energy_approx, input_l_quant_number: l_number)
            
            // calculates wavefunction values from 0 to outer radius block
            self.outward_integration(initial_r_list: initial_r_list, initial_KE_list: initial_KE_list, number_blocks: number_blocks, l_number: l_number, trial_psi0_guess: trial_psi0_guess, number_points: number_points, KE_index_tuple: KE_index_tuple, outward_index_tuple: outward_index_tuple)
            
            // gets calculated number of crosses
            calculated_numb_crosses = self.ncross
            
            // boolean to compare calculated vs correct number of crosses
            let ncross_energy_bool: Bool = calculated_numb_crosses < correct_numb_crosses
            
            // switch case to check number of crosses, if false, energy is too small, if true (default), energy is too large
            switch ncross_energy_bool {
                
            case false:
                ncross_energy_approx = ncross_energy_approx*1.25
            default:
                ncross_energy_approx = ncross_energy_approx*0.75
                
            }
            
            // clears variables for next iteration
            schroed_mesh_potential_init_inst.KE_term_list.removeAll()
            schroed_mesh_potential_init_inst.delta_r_list.removeAll()
            self.test_final_values_list.removeAll()
            self.test_final_r_values_list.removeAll()
            schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array.removeAll()
            
        }
        
        
        // sets energy convergence tolerance (difference in upper and lower energies needed to continue), initial lower bound energy (left energy) and initial upper bound energy (right energy)
        let energy_conv_tolerance: Double = 1.0E-09
        var left_energy: Double = ncross_energy_approx*left_energy_scalar
        var right_energy: Double = ncross_energy_approx*right_energy_scalar
        
        // initializes variables that will be updated for each iteration
        var delta_energy: Double = 10.0
        var mid_point_energy: Double = 0.0
        var variable_left_wavefunction: Double = 0.0
        var variable_right_wavefunction: Double = 0.0
        var variable_midpoint_wavefunction: Double = 0.0
        
        // calculates wavefunction value at outer radius with given energy
        func outer_radius_wf_value(energy_input: Double) -> Double {
            
            // re-calculates KE list, KE index tuple and outward index tuple
            schroed_mesh_potential_init_inst.initialize_KE_term_list(scaled_pot_list: schroed_mesh_potential_init_inst.trial_pot_list, scaled_r_list: schroed_mesh_potential_init_inst.r_mesh, l_quant_number: l_number, input_energy: energy_input, number_blocks: number_blocks, number_points: number_points)
            
            // gets values from mesh_potential_init instance
            initial_KE_list = schroed_mesh_potential_init_inst.KE_term_list
            KE_index_tuple = schroed_mesh_potential_init_inst.KE_cross_index_tuple
            outward_index_tuple = schroed_mesh_potential_init_inst.outer_radius_index_tuple
            
            // guess for second wavefunction value (first is 0)
            let trial_psi0_guess: Double = schroed_wavefunction_values_inst.wf_origin_boundary_approximation(second_potential_value: schroed_mesh_potential_init_inst.trial_pot_list[1], third_potential_value: schroed_mesh_potential_init_inst.trial_pot_list[2], second_rmesh_value: schroed_mesh_potential_init_inst.r_mesh[1], z_value: z_value, energy_value: energy_input, input_l_quant_number: l_number)
            
            // calculates wavefunction values from 0 to outer radius block
            self.outward_integration(initial_r_list: initial_r_list, initial_KE_list: initial_KE_list, number_blocks: number_blocks, l_number: l_number, trial_psi0_guess: trial_psi0_guess, number_points: number_points, KE_index_tuple: KE_index_tuple, outward_index_tuple: outward_index_tuple)
            
            // wavefunction value at outer radius mesh point
            let variable_wavefunction: Double = self.test_final_values_list[outward_index_tuple.outer_radius_index_univ]
            
            
            // clears variables
            schroed_mesh_potential_init_inst.KE_term_list.removeAll()
            schroed_mesh_potential_init_inst.delta_r_list.removeAll()
            self.test_final_values_list.removeAll()
            self.test_final_r_values_list.removeAll()
            schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array.removeAll()
            
            return(variable_wavefunction)
            
        }
        
        // wavefunction value at outer radius with left energy
        variable_left_wavefunction = outer_radius_wf_value(energy_input: left_energy)
        
        // wavefunction value at outer radius with right energy
        variable_right_wavefunction = outer_radius_wf_value(energy_input: right_energy)
        
        // while loop that calculates average delta E between upper and lower bound energies until it reaches convergence value set previously
        while abs(delta_energy) > energy_conv_tolerance {
            
            // calculates average delta E and midpoint energy
            delta_energy = (right_energy - left_energy)/2.0
            mid_point_energy = left_energy + delta_energy
            
            // wavefunction value at outer radius with mid point energy
            variable_midpoint_wavefunction = outer_radius_wf_value(energy_input: mid_point_energy)
            
            // if there's a sign change between midpoint and right wavefunction value, correct energy must be between midpoint and right energy, otherwise midpoint and right energies are both upper bounds
            if (variable_midpoint_wavefunction*variable_right_wavefunction) <= 0.0 {
                
                // sets new lower bound (left energy and left wavefunction value) as midpoint values
                left_energy = mid_point_energy
                variable_left_wavefunction = variable_midpoint_wavefunction
                
            } else {
                
                // sets new upper bound (right energy and right wavefunction value) as midpoint values
                right_energy = mid_point_energy
                variable_right_wavefunction = variable_midpoint_wavefunction
                
            }
            
            
        }
        
        //THRESH criterion
        
        // sets energy thresh criterion to input, initial final energy to energy from previous energy convergence loop.  Initializes variables for calculated energy thresh and loop counter
        let energy_thresh_criterion: Double = thresh_criterion
        var calculated_energy_thresh_criterion: Double = 1.0
        var final_energy: Double = mid_point_energy
        var criterion_counter: Int = 0
        
        // energy thresh criterion while loop, continues looping until criterion is met, or max number of iterations are reached set by the user
        criterionloop: while calculated_energy_thresh_criterion > energy_thresh_criterion {
            
            criterion_counter += 1
            
            // re-calculates KE list, KE index tuple and outward index tuple
            schroed_mesh_potential_init_inst.initialize_KE_term_list(scaled_pot_list: schroed_mesh_potential_init_inst.trial_pot_list, scaled_r_list: schroed_mesh_potential_init_inst.r_mesh, l_quant_number: l_number, input_energy: final_energy, number_blocks: number_blocks, number_points: number_points)
            
            // gets values from mesh_potential_init instance
            initial_KE_list = schroed_mesh_potential_init_inst.KE_term_list
            KE_index_tuple = schroed_mesh_potential_init_inst.KE_cross_index_tuple
            outward_index_tuple = schroed_mesh_potential_init_inst.outer_radius_index_tuple
            
            // guess for second wavefunction value (first is 0)
            let trial_psi0_guess: Double = schroed_wavefunction_values_inst.wf_origin_boundary_approximation(second_potential_value: schroed_mesh_potential_init_inst.trial_pot_list[1], third_potential_value: schroed_mesh_potential_init_inst.trial_pot_list[2], second_rmesh_value: schroed_mesh_potential_init_inst.r_mesh[1], z_value: z_value, energy_value: final_energy, input_l_quant_number: l_number)
            
            // wavefunction guess values at outer radius and previous point to start inward integration
            let outer_psi_values = schroed_wavefunction_values_inst.wf_outer_boundary_approximation(outer_radius_point: schroed_mesh_potential_init_inst.r_mesh[schroed_mesh_potential_init_inst.outer_radius_index_tuple.outer_radius_index_univ], outer_radius_KE_value: schroed_mesh_potential_init_inst.KE_term_list[schroed_mesh_potential_init_inst.outer_radius_index_tuple.outer_radius_index_univ], next_point: schroed_mesh_potential_init_inst.r_mesh[schroed_mesh_potential_init_inst.outer_radius_index_tuple.outer_radius_index_univ+1], next_KE_value: schroed_mesh_potential_init_inst.KE_term_list[schroed_mesh_potential_init_inst.outer_radius_index_tuple.outer_radius_index_univ+1])
            
            // calculates wavefunction values from 0 to outer radius block
            self.outward_integration(initial_r_list: initial_r_list, initial_KE_list: initial_KE_list, number_blocks: number_blocks, l_number: l_number, trial_psi0_guess: trial_psi0_guess, number_points: number_points, KE_index_tuple: KE_index_tuple, outward_index_tuple: outward_index_tuple)
            
            // calculates wavefunction values from matching radius to outer radius mesh point
            self.inward_integration(initial_r_list: initial_r_list, initial_KE_list: initial_KE_list, number_blocks: number_blocks, l_number: l_number, psi_n_guess: outer_psi_values.1, psi_n_minus1_guess: outer_psi_values.0, number_points: number_points, initial_delta_x: initial_delta_x, test_scalar: mesh_scalar, outward_index_tuple: outward_index_tuple, KE_index_tuple: KE_index_tuple)
            
            // outward log derivative integral
            let out_integral_sum: Double = self.outward_log_deriv_integral(wavefunction_tuple_array: schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array, initial_delta_x: initial_delta_x, mesh_scalar: mesh_scalar, KE_index_tuple: KE_index_tuple, outward_index_tuple: outward_index_tuple, number_points: number_points)
            
            // inward log derivative integral
            var in_integral_sum: Double = self.inward_log_deriv_integral(wavefunction_tuple_array: schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array, initial_delta_x: initial_delta_x, mesh_scalar: mesh_scalar, KE_index_tuple: KE_index_tuple, outward_index_tuple: outward_index_tuple, number_points: number_points)
            
            // initializes block number for previous, current and next wavefunction value at matching radius for outward integration values (initially assume they're all in the same block)
            var out_tuple_array_index_prev: Int = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-1
            var out_tuple_array_index_curr: Int = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-1
            var out_tuple_array_index_next: Int = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-1
            
            // initializes index for previous, current and next wavefunction value at matching radius for outward integration values
            var out_wf_list_index_prev: Int = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_index_block-2
            var out_wf_list_index_curr: Int = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_index_block-1
            var out_wf_list_index_next: Int = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_index_block
            
            // switch case dependent on index value of out_wf_list_index_prev (index of point previous to matching radius from outward integration values)
            switch out_wf_list_index_prev {
                
            // if its -1, matching radius is first value in current block
            case -1:
                
                // changes block number of previous point to matching radius block number -1
                out_tuple_array_index_prev = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-2
                out_tuple_array_index_curr = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-1
                out_tuple_array_index_next = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-1
                
                // changes previous wavefunction index value to last value in previous block
                out_wf_list_index_prev = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-2].wavefunction_list.count-1
                out_wf_list_index_curr = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_index_block-1
                out_wf_list_index_next = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_index_block
                
            // if its -2, matching radius is last value in previous block
            case -2:
                
                // changes block number of previous and current point to matching radius block number -1
                out_tuple_array_index_prev = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-2
                out_tuple_array_index_curr = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-2
                out_tuple_array_index_next = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-1
                
                // changes previous and current wavefunction index value to last and second to last value in previous block
                out_wf_list_index_prev = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-2].wavefunction_list.count-2
                out_wf_list_index_curr = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-2].wavefunction_list.count-1
                out_wf_list_index_next = schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_index_block
                
            default:
                // do nothing
                in_integral_sum += 0.0
            }
            
            // wavefunction values at matching radius, and points before and after for outward integration values
            let out_match_prev_wf: Double = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[out_tuple_array_index_prev].wavefunction_list[out_wf_list_index_prev].wavefunction_value
            let out_match_prev_r: Double = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[out_tuple_array_index_prev].wavefunction_list[out_wf_list_index_prev].r_value
            let out_match_current_wf: Double = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[out_tuple_array_index_curr].wavefunction_list[out_wf_list_index_curr].wavefunction_value
            let out_match_current_r: Double = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[out_tuple_array_index_curr].wavefunction_list[out_wf_list_index_curr].r_value
            let out_match_next_wf: Double = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[out_tuple_array_index_next].wavefunction_list[out_wf_list_index_next].wavefunction_value
            let out_match_next_r: Double = schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[out_tuple_array_index_next].wavefunction_list[out_wf_list_index_next].r_value
            
            // calculates log derivative at matching radius for outward integration values
            let out_log_deriv: Double = schroed_functional_functions_inst.grid_log_deriv(central_f_value: out_match_current_wf, prev_f_value: out_match_prev_wf, next_f_value: out_match_next_wf, central_x_value: out_match_current_r, next_x_value: out_match_next_r, prev_x_value: out_match_prev_r).1
            
            // initializes block number for previous, current and next wavefunction value at matching radius for inward integration values (initially assume they're all in the same block)
            var in_tuple_array_index_list: [Int] = [0,0,0]
            
            // initializes index for previous, current and next wavefunction value at matching radius for inward integration values
            var in_wf_list_index_list: [Int] = [0,1,2]
            
            // switch case based on length of wavefunction list in first (matching) block
            switch schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[0].wavefunction_list.count {
                
            // if its 2, previous and current wavefunction values are in current block, next value is in next block
            case 2:
                
                in_tuple_array_index_list = [0,0,1]
                in_wf_list_index_list = [0,1,0]
                
            // if its 1, only previous wavefunction value is in current block, current and next values are in next block
            case 1:
                
                in_tuple_array_index_list = [0,1,1]
                in_wf_list_index_list = [0,0,1]
                
            default:
                in_integral_sum += 0.0
            }
            
            // wavefunction values at matching radius, and points before and after for inward integration values
            let in_match_prev_wf: Double = schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[in_tuple_array_index_list[0]].wavefunction_list[in_wf_list_index_list[0]].wavefunction_value
            let in_match_prev_r: Double = schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[in_tuple_array_index_list[0]].wavefunction_list[in_wf_list_index_list[0]].r_value
            let in_match_current_wf: Double = schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[in_tuple_array_index_list[1]].wavefunction_list[in_wf_list_index_list[1]].wavefunction_value
            let in_match_current_r: Double = schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[in_tuple_array_index_list[1]].wavefunction_list[in_wf_list_index_list[1]].r_value
            let in_match_next_wf: Double = schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[in_tuple_array_index_list[2]].wavefunction_list[in_wf_list_index_list[2]].wavefunction_value
            let in_match_next_r: Double = schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[in_tuple_array_index_list[2]].wavefunction_list[in_wf_list_index_list[2]].r_value
            
            // calculates log derivative at matching radius for inward integration values
            let in_log_deriv: Double = schroed_functional_functions_inst.grid_log_deriv(central_f_value: in_match_current_wf, prev_f_value: in_match_prev_wf, next_f_value: in_match_next_wf, central_x_value: in_match_current_r, next_x_value: in_match_next_r, prev_x_value: in_match_prev_r).1
            
            // calculates both sides of energy criterion equation, integral from 0 to matching radius for outward integration values over wavefunction value at matching radius squared, integral from matching radius to outer radius for inward integration values over wavefunction value at matching radius squared, set equal to difference in inward and outward log derivative multiplied by delta E.  Divide right side by left gives needed delta E for correct binding energy, delta E over trial energy gives thresh criterion value
            let P_square_out: Double = out_integral_sum/pow(out_match_current_wf, 2.0)
            let P_square_in: Double = in_integral_sum/pow(in_match_current_wf, 2.0)
            let leftside_delta_E: Double = P_square_in + P_square_out
            let rightside_delta_E: Double = (out_log_deriv - in_log_deriv)
            let final_delta_E: Double = rightside_delta_E/leftside_delta_E
            
            // adds delta E to trial energy for input energy for the next iteration
            calculated_energy_thresh_criterion = abs(final_delta_E/final_energy)
            final_energy += final_delta_E
            
            // sets matching radius wavefunction value from inward and outward integration as well as the normalization constant
            schroed_wavefunction_values_inst.wf_normaliztion_constant = 1.0/sqrt(leftside_delta_E)
            schroed_wavefunction_values_inst.inward_wf_value = in_match_current_wf
            schroed_wavefunction_values_inst.outward_wf_value = out_match_current_wf
            
            // breaks loop if max number of thresh iterations achieved
            if criterion_counter == max_thresh_iterations {
                print("EXCEEDED MAX THRESH ITERATIONS")
                break criterionloop
            }
            
            // if calculated energy thresh criterion still larger than set bound, clears values for next iteration
            if calculated_energy_thresh_criterion > energy_thresh_criterion {
                
                schroed_mesh_potential_init_inst.KE_term_list.removeAll()
                schroed_mesh_potential_init_inst.delta_r_list.removeAll()
                self.test_final_values_list.removeAll()
                self.test_final_r_values_list.removeAll()
                schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array.removeAll()
                schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.removeAll()
                schroed_wavefunction_values_inst.inward_log_deriv_integral_values.removeAll()
                schroed_wavefunction_values_inst.outward_log_deriv_integral_values.removeAll()
                
            }
            
            // sets energy in wavefunction values instance for each iteration
            schroed_wavefunction_values_inst.energy_value = final_energy
            
        }
        
        /// normalize wavefunctions
        
        // normaliztion constants for inward and outward integration values
        let outward_normalization_constant: Double = schroed_wavefunction_values_inst.wf_normaliztion_constant/schroed_wavefunction_values_inst.outward_wf_value
        let inward_normalization_constant: Double = schroed_wavefunction_values_inst.wf_normaliztion_constant/schroed_wavefunction_values_inst.inward_wf_value
        
        // For loop that multiplies each outward integration value by outward normaliztion factor and adds it to norm_Pwavefunction_tuple_array from origin to matching radius for each block
        for i in stride(from: 0, to: schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number, by: 1){
            
            // Tuple array for r and wave function values for current block
            var temp_wavefunction_tuple_array: [(r_value: Double, wavefunction_value: Double)] = []
            
            // Switch case depending on current block.  If its the last block, adds values from start to crossing index within block, otherwise add entire r and wave function pair to temp array.
            switch i {
                
            // Last block
            case schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_block_number-1:
                
                for j in stride(from: 0, to: schroed_mesh_potential_init_inst.KE_cross_index_tuple.KE_cross_index_block, by: 1) {
                    
                    temp_wavefunction_tuple_array.append((r_value: schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[i].wavefunction_list[j].r_value, wavefunction_value: schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[i].wavefunction_list[j].wavefunction_value*outward_normalization_constant))
                    
                }
                
            // Every other block
            default:
                
                for j in schroed_wavefunction_values_inst.outward_Pwavefunction_tuple_array[i].wavefunction_list {
                    
                    temp_wavefunction_tuple_array.append((r_value: j.r_value, wavefunction_value: j.wavefunction_value*outward_normalization_constant))
                    
                }
                
            }
            
            // Adds temp_wavefunction_tuple_array and current block number to norm_Pwavefunction_tuple_array
            schroed_wavefunction_values_inst.norm_Pwavefunction_tuple_array.append((wavefunction_list: temp_wavefunction_tuple_array, block_number: Double(i+1)))
            
        }
        
        let out_integration_block_count: Int = schroed_wavefunction_values_inst.norm_Pwavefunction_tuple_array.count
        
        
        // For loop that multiplies each inward integration value by inward normaliztion factor and adds it to norm_Pwavefunction_tuple_array from matching radius to outer radius for each block
        for i in stride(from: 0, to: schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count, by: 1) {
            
            // Tuple array for r and wave function values for current block
            var temp_wavefunction_tuple_array: [(r_value: Double, wavefunction_value: Double)] = []
            
            // Switch case depending on current block.  If its the first block (0), removes first two values (guess values left over from inward integration function) then adds rest of r and wave function values to temp array.  If its last block, adds all r and wavefunction values to temp array and removes last value (guess value left over from inward integration function).  Every other block adds entire r and wave function pair to temp array.  All wave function values multiplied by inward normalization factor
            switch i {
                
            // First block
            case 0:
                
                for j in schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[i].wavefunction_list {
                    
                    temp_wavefunction_tuple_array.append((r_value: j.r_value, wavefunction_value: j.wavefunction_value*inward_normalization_constant))
                    
                }
                
                temp_wavefunction_tuple_array.remove(at: 0)
                temp_wavefunction_tuple_array.remove(at: 0)
                
            // Last block
            case schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array.count-1:
                
                for j in schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[i].wavefunction_list {
                    
                    temp_wavefunction_tuple_array.append((r_value: j.r_value, wavefunction_value: j.wavefunction_value*inward_normalization_constant))
                    
                }
                
                temp_wavefunction_tuple_array.remove(at: temp_wavefunction_tuple_array.count-1)
                
            // Every other block
            default:
                
                for j in schroed_wavefunction_values_inst.inward_Pwavefunction_tuple_array[i].wavefunction_list {
                    
                    temp_wavefunction_tuple_array.append((r_value: j.r_value, wavefunction_value: j.wavefunction_value*inward_normalization_constant))
                    
                }
                
                
            }
            
            // Adds temp_wavefunction_tuple_array and current block number to norm_Pwavefunction_tuple_array
            schroed_wavefunction_values_inst.norm_Pwavefunction_tuple_array.append((wavefunction_list: temp_wavefunction_tuple_array, block_number: Double(i+out_integration_block_count)))
            
        }
        
        
        // If second value in norm_Pwavefunction_tuple_array is negative, flips sign of all values for current orbital wave function values
        if schroed_wavefunction_values_inst.norm_Pwavefunction_tuple_array[0].wavefunction_list[1].wavefunction_value < 0.0 {
            
            for i in stride(from: 0, to: schroed_wavefunction_values_inst.norm_Pwavefunction_tuple_array.count, by: 1) {
                
                for j in stride(from: 0, to: schroed_wavefunction_values_inst.norm_Pwavefunction_tuple_array[i].wavefunction_list.count, by: 1){
                    
                    schroed_wavefunction_values_inst.norm_Pwavefunction_tuple_array[i].wavefunction_list[j].wavefunction_value = -schroed_wavefunction_values_inst.norm_Pwavefunction_tuple_array[i].wavefunction_list[j].wavefunction_value
                    
                }
                
            }
            
        }
        
    }
    
    
}

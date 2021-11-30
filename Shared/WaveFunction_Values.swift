//
//  WaveFunction_Values.swift
//  SelfConsistent_Hartree_Fock_Slater_non_relativistic
//
//  Created by Varrick Suezaki on 8/11/18.
//  Copyright © 2018 Varrick Suezaki. All rights reserved.
//

//import Cocoa
import Foundation

class WaveFunction_Values: NSObject {
    
    // Array of tuples that hold a 'wavefunction_list' which is an array of tuples containing r values and corresponding wavefunction values for that particular block, and block number
    var unnorm_Pwavefunction_tuple_array: [(wavefunction_list: [(r_value: Double, wavefunction_value: Double)], block_number: Double)] = []
    var outward_Pwavefunction_tuple_array: [(wavefunction_list: [(r_value: Double, wavefunction_value: Double)], block_number: Double)] = []
    var inward_Pwavefunction_tuple_array: [(wavefunction_list: [(r_value: Double, wavefunction_value: Double)], block_number: Double)] = []
    var norm_Pwavefunction_tuple_array: [(wavefunction_list: [(r_value: Double, wavefunction_value: Double)], block_number: Double)] = []
    
    // ??
    var energy_value: Double = 0.0
    
    
    // Array of tuples that store integration values from each block for outward and inward Wavefunction lists
    var outward_log_deriv_integral_values: [(integral_sum: Double, block_number: Double)] = []
    var inward_log_deriv_integral_values: [(integral_sum: Double, block_number: Double)] = []
    
    // Variables that hold calculated normalization factor, outward and inward wavefunction values at matching radius
    var wf_normaliztion_constant: Double = 0.0
    var inward_wf_value: Double = 0.0
    var outward_wf_value: Double = 0.0
    
    // Power expansion to approximate wavefunction 'guess' value for point right after origin
    // Power series expansion
    func wf_origin_boundary_approximation(second_potential_value: Double, third_potential_value: Double, second_rmesh_value: Double, z_value: Double, energy_value: Double, input_l_quant_number: Double) -> Double {
        
        let V2: Double = second_potential_value
        let V3: Double = third_potential_value
        let R2: Double = second_rmesh_value
        
        let B1: Double = -2.0*z_value
        let B2: Double = (3.0*z_value/R2) - energy_value + 2.0*V2 - V3
        let B3: Double = ((V3 - V2)/R2) - (z_value/pow(R2, 2.0))
        
        let A1: Double = -(z_value/(input_l_quant_number + 1.0))
        let A2: Double = (A1*B1 + B2)/(4.0*input_l_quant_number + 6.0)
        let A3: Double = (A2*B1 + A1*B2 + B3)/(6.0*input_l_quant_number + 12.0)
        let A4: Double = (A3*B1 + A2*B2 + A1*B3)/(8.0*input_l_quant_number + 20.0)
        
        let P3: Double = (1.0 + A1*R2 + A2*pow(R2, 2.0) + A3*pow(R2, 3.0) + A4*pow(R2, 4.0))*R2
        
        return(P3)
        
    }
    
    // Wavefunction approximation for outer radius value.  At outer radius wavefunction should act like a exponentially damped wave
    // equation: psi = e^(-r*sqrt(Q)) where Q is KE term
    func wf_outer_boundary_approximation(outer_radius_point: Double, outer_radius_KE_value: Double, next_point: Double, next_KE_value: Double) -> (Double, Double) {
        
        let psi_n_exp: Double = -outer_radius_point*sqrt(abs(outer_radius_KE_value))
        let psi_n: Double = pow(M_E, psi_n_exp)
        
        let psi_n_plus1_exp: Double = -next_point*sqrt(abs(next_KE_value))
        let psi_n_plus1: Double = pow(M_E, psi_n_plus1_exp)
        
        return(psi_n, psi_n_plus1)
        
    }


}

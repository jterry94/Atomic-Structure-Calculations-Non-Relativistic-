//
//  Functional_Functions.swift
//  SelfConsistent_Hartree_Fock_Slater_non_relativistic
//
//  Created by Varrick Suezaki on 8/11/18.
//  Copyright © 2018 Varrick Suezaki. All rights reserved.
//

import Foundation

class Functional_Functions: NSObject {
    
    /// Name: forward_numerov_method
    /// Description: Uses Numerov method which is used to solve ordinary differential equations (ODE's) numerically of the
    /// form: ((d/dx)^2)*y(x) = -g(x)*y(x) + s(x) forward (y1, y2, y3....yn).  'yn' and 'xn' stands for the nth value for y and x.
    ///
    /// - Parameters:
    ///   - x_list: List of x values
    ///   - g_list: List of g(x) values
    ///   - s_list: List of s(X) values
    ///   - yn_minus_1: Guess value for yn-1 used to calculate yn+1 (first value in y list)
    ///   - yn: Guess value for yn used to calculate yn+1 (second value in y list)
    /// - Returns: Returns array of tuples containing x value and corresponding y value
    func forward_numerov_method(x_list: [Double], g_list: [Double], s_list: [Double], yn_minus_1: Double, yn: Double) -> [(x_value: Double, y_value: Double)]{
        
        // tuple array that stores x and calculated y values
        var yn_tuple_array: [(x_value: Double, y_value: Double)] = []
        
        // bool that checks if x, g, and s lists are equal length
        let check_list_length: Bool = x_list.count == g_list.count && x_list.count == s_list.count
        
        // switch case that uses check_list_length bool
        switch check_list_length {
            
        // if x, g and s lists are equal length (should be)
        case true:
            
            // stores initial yn-1 and yn guess
            yn_tuple_array.append((x_value: x_list[0], y_value: yn_minus_1))
            yn_tuple_array.append((x_value: x_list[1], y_value: yn))
            
            // for every iteration: yn_prev stores yn-1 value, yn_current stores yn value, yn_next stores yn+1 value and delta_xn stores difference between xn+1 and xn value.
            var yn_prev = yn_minus_1
            var yn_current = yn
            var yn_next = 0.0
            var delta_xn = 0.0
            
            // from given values, calculates next y value (yn+1), adds that value to the tuple array, then sets the yn+1 value to the new yn value, and the current yn value to the new yn-1 value for the next iteration
            for i in 1..<(x_list.count-1){
                
                // calculates current delta_x, compensates for mesh's with changing delta_x values
                delta_xn = x_list[i+1] - x_list[i]
                
                // numerov formula solving for yn+1
                yn_next = (2.0*yn_current*(1.0 - ((pow(delta_xn, 2.0)*g_list[i]*5.0)/12.0)) - yn_prev*(1.0 + ((pow(delta_xn, 2.0)*g_list[i-1])/12.0)) + ((pow(delta_xn, 2.0)/12.0)*(s_list[i+1] + 10.0*s_list[i] + s_list[i-1])))/(1.0 + ((pow(delta_xn, 2.0)*g_list[i+1])/12.0))
                
                // adds x value and calculated y value to tuple array
                yn_tuple_array.append((x_value: x_list[i+1], y_value: yn_next))
                
                // shifts yn+1, yn and yn-1 values for next iteration
                yn_prev = yn_current
                yn_current = yn_next
                
            }
            
        // if one of the lists aren't equal
        default:
            print("list length's dont match")
            
        }
        
        // returns y value tuple array
        return(yn_tuple_array)
    }
    
    /// Name: backward_numerov_method
    /// Description: Same as the forward numerov method except it solves ODE's backward
    ///
    /// - Parameters:
    ///   - x_list: List of x values
    ///   - g_list: List of g(x) values
    ///   - s_list: List of s(X) values
    ///   - yn_plus_1: Guess value for yn+1 used to calculate yn-1 (last value in y list)
    ///   - yn: Guess value for yn used to calculate yn-1 (second to last value in y list)
    /// - Returns: Returns array of tuples containing x value and corresponding y value
    func backward_numerov_method(x_list: [Double], g_list: [Double], s_list: [Double], yn_plus_1: Double, yn: Double) -> [(x_value: Double, y_value: Double)]{
        
        // tuple array that stores x and calculated y values
        var yn_tuple_array: [(x_value: Double, y_value: Double)] = []
        
        // stores last index of x_list
        let x_list_last_index: Int = x_list.count-1
        
        // bool that checks if x, g, and s lists are equal length
        let check_list_length: Bool = x_list.count == g_list.count && x_list.count == s_list.count
        
        // switch case that uses check_list_length bool
        switch check_list_length {
            
        // if x, g and s lists are equal length (should be)
        case true:
            
            // stores initial yn+1 and yn guess
            yn_tuple_array.append((x_value: x_list[x_list_last_index], y_value: yn_plus_1))
            yn_tuple_array.append((x_value: x_list[x_list_last_index - 1], y_value: yn))
            
            // for every iteration: yn_prev stores yn-1 value, yn_current stores yn value, yn_next stores yn+1 value and delta_xn stores difference between xn+1 and xn value.
            var yn_prev: Double = 0.0
            var yn_current: Double = yn
            var yn_next: Double = yn_plus_1
            var delta_xn: Double = 0.0
            
            // from given values, calculates previous y value (yn-1), adds that value to the tuple array, then sets the yn-1 value to the new yn value, and the current yn value to the new yn+1 value for the next iteration
            for i in stride(from: x_list_last_index-1, to: 0, by: -1){
                
                // calculates current delta_x, compensates for mesh's with changing delta_x values
                delta_xn = x_list[i-1] - x_list[i]
                
                // numerov formula solving for yn-1
                yn_prev = (2.0*yn_current*(1.0 - ((pow(delta_xn, 2.0)*g_list[i]*5.0)/12.0)) - yn_next*(1.0 + ((pow(delta_xn, 2.0)*g_list[i+1])/12.0)) + ((pow(delta_xn, 2.0)/12.0)*(s_list[i+1] + 10.0*s_list[i] + s_list[i-1])))/(1.0 + ((pow(delta_xn, 2.0)*g_list[i-1])/12.0))
                
                // adds x value and calculated y value to tuple array
                yn_tuple_array.append((x_value: x_list[i-1], y_value: yn_prev))
                
                // shifts yn+1, yn and yn-1 values for next iteration
                yn_next = yn_current
                yn_current = yn_prev
                
            }
            
        // if one of the lists aren't equal
        default:
            print("list length's dont match")
            
        }
        
        // returns y value tuple array
        return(yn_tuple_array)
    }
    
    /// Name: schrodinger_numerov_method
    /// Description: Uses forward numerov method to solve schroedinger equation starting from origin (outward integration).  Needs two intial 'guess values' to start method
    ///
    /// - Parameters:
    ///   - r_list: Input r-list values
    ///   - gn_coeff_list: Input KE term list values
    ///   - psi0: First wavefunction value at origin (boundary condition, psi(0) should be 0 in this case)
    ///   - psi1_guess: Next wavefunction value approximation.  Uses expansion to approximate next wavefunction value after boundary condition wavefunction value
    /// - Returns: Returns array of tuple's containing r value and corresponding wavefunction value
    func schrodinger_numerov_method(r_list: [Double], gn_coeff_list: [Double], psi0: Double, psi1_guess: Double) -> [(r_value: Double, wavefunction_value: Double)]{
        
        // creates s list full of 0's since all s values for schrodinger solution is 0
        let zeros_s_list: [Double] = Array(repeating: 0.0, count: r_list.count)
        
        // uses general numerov method to solve for schroedinger
        let x_y_array = self.forward_numerov_method(x_list: r_list, g_list: gn_coeff_list, s_list: zeros_s_list, yn_minus_1: psi0, yn: psi1_guess)
        
        // sets x_value to r_value and y_value to wavefunction_value for each tuple in new wavefunction tuple array Array of tuples that will be added to another tuple array defined in wavefunction class, reset after everyloop so its seperated by block number.
        let wavefunction_tuple_array: [(r_value: Double, wavefunction_value: Double)] = x_y_array.map({(r_value: $0.x_value, wavefunction_value: $0.y_value)})
        
        return(wavefunction_tuple_array)
        
    }
    
    
    /// Name: schrodinger_backward_numerov_method
    /// Description: Exactly like schrodinger_numerov_method except it solves schrodinger backward, starting at outer radius and working back to matching radius (inward integration)
    ///
    /// - Parameters:
    ///   - r_list: Input r-list values
    ///   - gn_coeff_list: Input KE term list values
    ///   - psi_n_guess: Wavefunction value approximation for point right after outer radius
    ///   - psi_n_minus1_guess: Wavefunction value approximation for outer radius value
    /// - Returns: Returns array of tuple's containing r value and corresponding wavefunction value
    func schrodinger_backward_numerov_method(r_list: [Double], gn_coeff_list: [Double], psi_n_guess: Double, psi_n_minus1_guess: Double) -> [(r_value: Double, wavefunction_value: Double)]{
        
        // creates s list full of 0's since all s values for schroedinger solution is 0
        let zeros_s_list: [Double] = Array(repeating: 0.0, count: r_list.count)
        
        // uses general numerov method to solve for schroedinger
        let x_y_array = self.backward_numerov_method(x_list: r_list, g_list: gn_coeff_list, s_list: zeros_s_list, yn_plus_1: psi_n_guess, yn: psi_n_minus1_guess)
        
        // sets x_value to r_value and y_value to wavefunction_value for each tuple in new wavefunction tuple array Array of tuples that will be added to another tuple array defined in wavefunction class, reset after everyloop so its seperated by block number.
        let wavefunction_tuple_array: [(r_value: Double, wavefunction_value: Double)] = x_y_array.map({(r_value: $0.x_value, wavefunction_value: $0.y_value)})
        
        return(wavefunction_tuple_array)
        
    }
    
    
    // Newton-Cotes 2 point integration
    // Numerical integration method for equally spaced points.  Integral = (h/2)*(y1 + y2)
    func newton_cotes_twopoint_integral(step_size: Double, y1: Double, y2: Double) -> Double{
        
        let integral_value: Double = (0.5*step_size)*(y1 + y2)
        
        return(integral_value)
        
    }
    
    // Newton-Cotes 3 point integration
    // Numerical integration method for equally spaced points.  Integral = (h/3)*(y1 + 4.0*y2 + y3)
    func newton_cotes_threepoint_integral(step_size: Double, y1: Double, y2: Double, y3: Double) -> Double{
        
        let integral_value: Double = (step_size/3.0)*(y1 + (4.0*y2) + y3)
        
        return(integral_value)
        
    }
    
    /// Name: calculate_delta_x_change
    /// Description: Given a 1D non-uniform mesh of x values, an upper bound and lower bound index, the index for when delta x changes is recorded along with its new value.
    ///
    /// - Parameters:
    ///   - x_list: Non-uniform mesh of x values
    ///   - lower_bound_index: Lower bound index for x mesh
    ///   - upper_bound_index: Upper bound index for x mesh
    /// - Returns: Returns a list of tuples containing the delta x change index and its new value
    func calculate_delta_x_change(x_list: [Double], lower_bound_index: Int, upper_bound_index: Int) -> [(change_index: Int, new_delta_x: Double)]{
        
        // find changes in delta x for mesh
        let first_delta_x: Double = x_list[lower_bound_index+1] - x_list[lower_bound_index]
        
        // Variable to store current delta x value
        var current_delta_x: Double = first_delta_x
        
        // Array of tuples to be returned
        var delta_x_change_array: [(change_index: Int, new_delta_x: Double)] = [(change_index: lower_bound_index, new_delta_x: first_delta_x)]
        
        // Loops from input lower to upper bound index
        for i in lower_bound_index..<upper_bound_index {
            
            // Calculates current delta x value and change from previous delta x
            let delta_x_value: Double = x_list[i+1] - x_list[i]
            let delta_x_change: Double = delta_x_value - current_delta_x
            
            // Boolean to check if there was a change in delta x
            let delta_x_bool: Bool = (abs(delta_x_change) < 1.0) && (abs(delta_x_change) < 1.0E-12)
            
            // Switch case for delta_x_bool, does nothing if true (no change in delta x), defaults to adding current delta_x_change and index to tuple list and changing current_delta_x.
            switch delta_x_bool {
                
            case true:
                
                current_delta_x += 0.0
                
            default:
                
                delta_x_change_array.append((change_index: i, new_delta_x: delta_x_value))
                current_delta_x = delta_x_value
                
            }
            
        }
        
        return(delta_x_change_array)
        
    }
    
    /// Name: integrate_mesh
    /// Description: Integrates a list of y(x) values from a non-uniform mesh of x values using a custom three point newton-cotes integration method
    ///
    /// - Parameters:
    ///   - x_list: Non-uniform mesh of x values
    ///   - y_list: Corresponding y(x) values
    ///   - lower_bound_index: Lower bound index for x mesh
    ///   - upper_bound_index: Upper bound index for x mesh
    /// - Returns: Returns final integration value of y(x) from specified lower and upper bound
    func integrate_mesh(x_list: [Double], y_list: [Double], lower_bound_index: Int, upper_bound_index: Int) -> Double{
        
        // find changes in delta x for mesh using function calculate_delta_x_change
        let delta_x_change_array: [(change_index: Int, new_delta_x: Double)] = self.calculate_delta_x_change(x_list: x_list, lower_bound_index: lower_bound_index, upper_bound_index: upper_bound_index)
        
        // Variable to store final integration value
        var mesh_integral_sum: Double = 0.0
        
        // Loops over each index and new_delta_x pair.  Integrates values between each change in delta x using newton-cotes since newton-cotes method only works for uniform set of x values.
        for i in stride(from: 0, to: delta_x_change_array.count-1, by: 1) {
            
            // Gets the current delta x values
            let mesh_delta_x: Double = delta_x_change_array[i].new_delta_x
            
            // Makes temporary arrays of x and y(x) arrays between change in delta x index values
            let mesh_x_list: [Double] = Array(x_list[delta_x_change_array[i].change_index...delta_x_change_array[i+1].change_index])
            let mesh_y_list: [Double] = Array(y_list[delta_x_change_array[i].change_index...delta_x_change_array[i+1].change_index])
            
            // Calls custom 3 point newton-cotes method to integrate interval, adds value to mesh_integral_sum
            let mesh_integral_sum_value: Double = self.custom_newton_cotes_threepoint(h_value: mesh_delta_x, x_list: mesh_x_list, y_list: mesh_y_list)
            mesh_integral_sum += mesh_integral_sum_value
        }
        
        // Last few lines exactly the same as lines in loop, just integrating over last integral between last change in delta x and last value in y(x) array.
        let last_mesh_delta_x: Double = delta_x_change_array[delta_x_change_array.count-1].new_delta_x
        let last_mesh_x_list: [Double] = Array(x_list[delta_x_change_array[delta_x_change_array.count-1].change_index...upper_bound_index])
        let last_mesh_y_list: [Double] = Array(y_list[delta_x_change_array[delta_x_change_array.count-1].change_index...upper_bound_index])
        
        let mesh_integral_sum_value: Double = self.custom_newton_cotes_threepoint(h_value: last_mesh_delta_x, x_list: last_mesh_x_list, y_list: last_mesh_y_list)
        mesh_integral_sum += mesh_integral_sum_value
        
        return(mesh_integral_sum)
        
    }
    
    /// Name: custom_newton_cotes_threepoint
    /// Description: Integrates a list of y(x) values of uniform x values using two and three point newton-cotes methods.  Integrates using three point method until there are too few points left in the arrays, then switches over to two point to integrate the rest.
    ///
    /// - Parameters:
    ///   - h_value: Delta x value bewteen x values
    ///   - x_list: Array of x values
    ///   - y_list: Array of y(x) values
    /// - Returns: Returns Integral value of given x and y(x) list.
    func custom_newton_cotes_threepoint(h_value: Double, x_list:[Double], y_list:[Double]) -> Double {
        
        // Variable to store final integration value
        var integral_sum: Double = 0.0
        
        // Boolean to make sure x and y(x) arrays have equal length
        let x_y_list_check: Bool = x_list.count == y_list.count
        
        // Switch case for x and y(x) arrays length, if true integrate, default do nothing
        switch x_y_list_check {
            
        case true:
            
            // How many times three point newton-cotes method can be used
            let multiplicity_count: Int = (x_list.count-1)/2
            
            // How many points are left
            let remainder_count: Int = (x_list.count-1)%2
            
            // End index for last possible three point newton-cotes method
            let end_multiplicity_index: Int = multiplicity_count*2
            
            // If the length of the arrays are not equal to or smaller than 2, integrate using three point newton-cotes up until end_multiplicity_index
            if multiplicity_count != 0 {
                
                for i in stride(from: 0, to: end_multiplicity_index, by: 2) {
                    
                    integral_sum += self.newton_cotes_threepoint_integral(step_size: h_value, y1: y_list[i], y2: y_list[i+1], y3: y_list[i+2])
                    
                }
                
                // Switch case for remainder_count, only option is if remainder after end_multiplicity_index is 1, then use two point netwton-cotes method
                switch remainder_count {
                    
                case 1:
                    
                    integral_sum += self.newton_cotes_twopoint_integral(step_size: h_value, y1: y_list[end_multiplicity_index], y2: y_list[end_multiplicity_index+1])
                    
                default:
                    
                    integral_sum += 0.0
                    
                }
                
            } else {
                
                // Switch case if multiplicty is 0, meaning the length of both arrays are either 2 or 3 (remainder would be 1 or 2)
                switch remainder_count {
                    
                // If 2 (3 points), use three point newton-cotes
                case 2:
                    
                    integral_sum += self.newton_cotes_threepoint_integral(step_size: h_value, y1: y_list[0], y2: y_list[1], y3: y_list[2])
                    
                // If 1 (2 points), use two point newton-cotes
                case 1:
                    
                    integral_sum += self.newton_cotes_twopoint_integral(step_size: h_value, y1: y_list[0], y2: y_list[1])
                    
                default:
                    
                    integral_sum += 0.0
                    
                }
                
            }
            
        // Prints out x and y(x) array lengths if they dont match
        default:
            print("x_list: \(x_list.count) does not equal y_list: \(y_list.count)")
        }
        
        return(integral_sum)
        
    }
    
    // Uses central difference method to calculate derivative at x point 'central_x' for function 'f'.  Basically calculates derivative at point before and after 'central_x' to find derivative at 'central_x'
    // This function is for a non-uniform mesh
    func grid_central_difference_method(central_x: Double, next_f_value: Double, prev_f_value: Double, next_x_value: Double, prev_x_value: Double) ->(Double, Double){
        
        let central_x_derivative: Double = (next_f_value - prev_f_value)/(next_x_value - prev_x_value)
        return(central_x, central_x_derivative)
        
    }
    
    // Calculates log derivative for a non-uniform mesh
    func grid_log_deriv(central_f_value: Double, prev_f_value: Double, next_f_value: Double, central_x_value: Double, next_x_value: Double, prev_x_value: Double) -> (Double, Double){
        
        let f_derivative = self.grid_central_difference_method(central_x: central_x_value, next_f_value: next_f_value, prev_f_value: prev_f_value, next_x_value: next_x_value, prev_x_value: prev_x_value)
        let log_f_deriv: Double = f_derivative.1/central_f_value
        
        return(central_x_value, log_f_deriv)
    }
    
    // Name: double_to_scientific_string
    /// Description: Changes a 'Double' to a 'String' in scientific notation
    ///
    /// - Parameters:
    ///   - double_input: Double to be converted
    ///   - number_of_sigfigs: Number of significant digits to use in notation
    /// - Returns: Returns string of input Double in scientific notation
    func double_to_scientific_string(double_input: Double, number_of_sigfigs: Int) -> String{
        
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.positiveFormat = "0." + String(repeating: "0", count: number_of_sigfigs) + "E+00"
        formatter.negativeFormat = "-0." + String(repeating: "0", count: number_of_sigfigs) + "E+00"
        formatter.exponentSymbol = "E"
        let double_string: String = formatter.string(for: double_input)!
        
        return(double_string)
        
    }
    
}

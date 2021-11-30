//
//  Output_File.swift
//  SelfConsistent_Hartree_Fock_Slater_non_relativistic
//
//  Created by Varrick Suezaki on 8/11/18.
//  Copyright © 2018 Varrick Suezaki. All rights reserved.
//

import Foundation

class Output_File: NSObject {
    
    var myHartreeFockSCFCalculator: HermanSkillmanCalculator? = nil
    
    /// Name: make_energy_output_file
    /// Description: Takes the atom name, Z value and final_results_array (contains r, wave function, quantum numbers, number of electrons and energy values for each orbital) and creates an energy output file containing atom name, Z value, quantum numbers and corresponding energies
    ///
    /// - Parameters:
    ///   - atom_name: String of atom name
    ///   - z_value: Z value of atom
    ///   - final_results_array: Array of containing r, wave function, quantum numbers, number of electrons and energy values for each orbital
    func make_energy_output_file(atom_name: String, z_value: Double, final_results_array: [(r_list: [Double], psi_list: [Double], quant_n: Double, quant_l: Double, quant_m: Double, number_electrons: Double, new_energy: Double)]) {
        

        var writeString: String = atom_name + " (Z=" + String(Int(z_value)) + ")\n\n" + "Orbital   # -e       E(NRL)\n\n"
        
        // Variables to hold quantum number, number electrons and energy strings
        var quantum_numbers_string: String = ""
        var number_electrons_string: String = ""
        var new_energy_string: String = ""
        
        // Variable to hold number of spaces between number of electrons and energy value string (makes output file look organized)
        var spaces_count: Int = 0
        
        // For loop that loops over each tuple element in final_results_array and adds quantum number, number of electron and energy strings to 'writeString' string.
        for i in 0..<final_results_array.count {
            
            quantum_numbers_string = String(Int(final_results_array[i].quant_n)) + String(Int(final_results_array[i].quant_l)) + String(Int(final_results_array[i].quant_m))
            number_electrons_string = String(final_results_array[i].number_electrons)
            new_energy_string = String(format: "%.4f", final_results_array[i].new_energy)
            
            // Calculates number of spaces needed between number of electrons string and energy string to line up columns (makes output file look organized)
            spaces_count = 16 - number_electrons_string.count - new_energy_string.count
            
            writeString += " " + quantum_numbers_string + "       " + number_electrons_string + String(repeating: " ", count: spaces_count) + new_energy_string + "\n"
            
        }
        
        // Writes 'writeString' string to energy output file
        
        myHartreeFockSCFCalculator!.plotDataModel!.calculatedText.append(writeString)
        
    }
    
    /// Name: make_wf_pot_output_file
    /// Description:
    ///
    /// - Parameters:
    ///   - atom_name: String of atom name
    ///   - z_value: Z value of atom
    ///   - final_results_array: Array of containing r, wave function, quantum numbers, number of electrons and energy values for each orbital
    ///   - self_consistent_pot_list: Final self-consistent potential list
    func make_wf_pot_output_file(atom_name: String, z_value: Double, final_results_array: [(r_list: [Double], psi_list: [Double], quant_n: Double, quant_l: Double, quant_m: Double, number_electrons: Double, new_energy: Double)], self_consistent_pot_list: [Double]) {
        
        // energy corrections instance, used to call energy correction functions
        let output_functional_functions_inst = myHartreeFockSCFCalculator!.functional_functions_inst
        
        // Temp variables that hold either potential or wave function values as strings in sets of 5
        var temp_variable1: String = ""
        var temp_variable2: String = ""
        var temp_variable3: String = ""
        var temp_variable4: String = ""
        var temp_variable5: String = ""

        
        myHartreeFockSCFCalculator!.plotDataModel!.calculatedText.append("\n\n")
        
        // POTENTIAL SECTION
        
        // First two lines of file, name and Z value of atom, and category names
        var writeString: String = atom_name + " (Z=" + String(Int(z_value)) + ")\n\n" + "Modified Herman-Skillman Potential Values r*V(r)\n\n"
        
        // Finds multiplicity and remainder of potential list (length of potential list divided by 5 and remainder)
        let potential_count: Int = self_consistent_pot_list.count
        let potential_count_multiplicity: Int = potential_count/5
        let potential_count_remainder: Int = potential_count%5
        let end_multiplicity_pot_count: Int = potential_count_multiplicity*5
        print(potential_count, potential_count_multiplicity, potential_count_remainder, end_multiplicity_pot_count)
        
        // Converts each value of potential list to a string in scientific notation (7 sig figs) in sets of 5 and adds to 'writeString' string as one line of string, line number at the end of every line starting after the 80th character (if there was an empty line, there would be 80 spaces then the line number so they all line up in a column).
        for i in stride(from: 0, to: end_multiplicity_pot_count, by: 5) {
            
            temp_variable1 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[i], number_of_sigfigs: 7)
            temp_variable2 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[i+1], number_of_sigfigs: 7)
            temp_variable3 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[i+2], number_of_sigfigs: 7)
            temp_variable4 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[i+3], number_of_sigfigs: 7)
            temp_variable5 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[i+4], number_of_sigfigs: 7)
            
            writeString += temp_variable1 + "  " + temp_variable2 + "  " + temp_variable3 + "  " + temp_variable4 + "  " + temp_variable5 + "  " + String(i/5 + 1) + "\n"
            
        }
        
        // Switch case based on remaining potential values.  Each potential value in string form is 14 character's with 2 spaces between each which changes the amount of spaces needed between the last potential value and line number.  (If remainder is 1, 80 - 14 = 66 so there would need to be 66 spaces between the last potential value and its line number)
        switch potential_count_remainder {
            
        // 1 potential value left
        case 1:
            
            temp_variable1 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[end_multiplicity_pot_count], number_of_sigfigs: 7)
            writeString += temp_variable1 + String(repeating: " ", count: 66) + String(potential_count_multiplicity + 1) + "\n\n"
            
        // 2 potential values left
        case 2:
            
            temp_variable1 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[end_multiplicity_pot_count], number_of_sigfigs: 7)
            temp_variable2 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[end_multiplicity_pot_count+1], number_of_sigfigs: 7)
            writeString += temp_variable1 + "  " + temp_variable2 + String(repeating: " ", count: 50) + String(potential_count_multiplicity + 1) + "\n\n"
            
        // 3 potential values left
        case 3:
            
            temp_variable1 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[end_multiplicity_pot_count], number_of_sigfigs: 7)
            temp_variable2 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[end_multiplicity_pot_count+1], number_of_sigfigs: 7)
            temp_variable3 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[end_multiplicity_pot_count+2], number_of_sigfigs: 7)
            writeString += temp_variable1 + "  " + temp_variable2 + "  " + temp_variable3 + String(repeating: " ", count: 34) + String(potential_count_multiplicity + 1) + "\n\n"
            
        // 4 potential values left
        case 4:
            
            temp_variable1 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[end_multiplicity_pot_count], number_of_sigfigs: 7)
            temp_variable2 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[end_multiplicity_pot_count+1], number_of_sigfigs: 7)
            temp_variable3 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[end_multiplicity_pot_count+2], number_of_sigfigs: 7)
            temp_variable4 = output_functional_functions_inst.double_to_scientific_string(double_input: self_consistent_pot_list[end_multiplicity_pot_count+3], number_of_sigfigs: 7)
            writeString += temp_variable1 + "  " + temp_variable2 + "  " + temp_variable3 + "  " + temp_variable4 + String(repeating: " ", count: 18) + String(potential_count_multiplicity + 1) + "\n\n"
            
        // Number of potential values is a multiple of 5 so remainder is 0, or something went wrong
        default:
            
            writeString += "\n"
            print("either remainder is 0 or somethings wrong")
            
        }
        
        
        // WAVEFUNCTION SECTION
        
        // Adds section title to 'writeString' string indicating wave function section
        writeString += "Herman-Skillman Radial Wavefunction Values P(r) (r*R(r))\n\n"
        
        // Loops over each set of r and wave function values for each orbital
        for i in 0..<final_results_array.count {
            
            // Adds section title to 'writeString' string indicating current orbitals quantum numbers and index of outer radius
            writeString += "Orbital: " + String(Int(final_results_array[i].quant_n)) + String(Int(final_results_array[i].quant_l)) + String(Int(final_results_array[i].quant_m)) + "\n"
            writeString += "Outer Radius Mesh Point: " + String(final_results_array[i].psi_list.count) + "\n\n"
            
            // Finds multiplicity and remainder of psi list of current orbital (length of psi list divided by 5 and remainder)
            let wf_count: Int = final_results_array[i].psi_list.count
            let wf_count_multiplicity: Int = wf_count/5
            let wf_count_remainder: Int = wf_count%5
            let end_multiplicity_wf_count: Int = wf_count_multiplicity*5
            
            // Converts each value of potential list to a string in scientific notation (7 sig figs) in sets of 5 and adds to 'writeString' string as one line of string, line number at the end of every line starting after the 80th character (if there was an empty line, there would be 80 spaces then the line number so they all line up in a column).  To keep columns aligned, adds or subtracts spaces between each string value depending if its positive or negative.
            for j in stride(from: 0, to: end_multiplicity_wf_count, by: 5) {
                
                // Array to hold number of spaces between each string value
                var wf_spaces_array: [String] = []
                
                // Assumes first psi value is negative so no space is needed
                var first_value_space: String = ""
                
                // If first psi value is positive, add a space
                if final_results_array[i].psi_list[j] >= 0.0 {
                    first_value_space = " "
                }
                
                // From 2nd to 5th value of current set of 5, assigns either 2 or 3 spaces if current psi value is negative or positive
                for k in j+1...j+4 {
                    
                    let pos_neg_bool: Bool = final_results_array[i].psi_list[k] < 0.0
                    
                    switch pos_neg_bool {
                        
                    case true:
                        
                        wf_spaces_array.append("  ")
                        
                    default:
                        
                        wf_spaces_array.append("   ")
                        
                    }
                    
                }
                
                // Converts 5 psi values to string's in scientific notation (7 sig figs)
                temp_variable1 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[j], number_of_sigfigs: 7)
                temp_variable2 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[j+1], number_of_sigfigs: 7)
                temp_variable3 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[j+2], number_of_sigfigs: 7)
                temp_variable4 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[j+3], number_of_sigfigs: 7)
                temp_variable5 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[j+4], number_of_sigfigs: 7)
                
                writeString += first_value_space + temp_variable1 + wf_spaces_array[0] + temp_variable2 + wf_spaces_array[1] + temp_variable3 + wf_spaces_array[2] + temp_variable4 + wf_spaces_array[3] + temp_variable5 + "  " + String(j/5 + 1) + "\n"
                
            }
            
            // Array to hold spaces between each psi string value for last line
            var end_wf_spaces_array: [String] = []
            var end_first_value_space: String = ""
            
            // Switch case that formats last line of string exactly like loop but depends on remaining psi values.
            switch wf_count_remainder {
                
            case 0:
                
                end_first_value_space = ""
                
            case 1:
                
                if final_results_array[i].psi_list[end_multiplicity_wf_count] >= 0.0 {
                    end_first_value_space = " "
                }
                
            default:
                
                if final_results_array[i].psi_list[end_multiplicity_wf_count] >= 0.0 {
                    end_first_value_space = " "
                }
                
                for j in end_multiplicity_wf_count+1..<final_results_array[i].psi_list.count {
                    
                    let pos_neg_bool: Bool = final_results_array[i].psi_list[j] < 0.0
                    
                    switch pos_neg_bool {
                        
                    case true:
                        
                        end_wf_spaces_array.append("  ")
                        
                    default:
                        
                        end_wf_spaces_array.append("   ")
                        
                    }
                    
                }
                
            }
            
            // Converts each value of psi list to a string in scientific notation in sets of 5 and adds to 'writeString' string as one line of string, line number at the end of every line starting after the 80th character (if there was an empty line, there would be 80 spaces then the line number so they all line up in a column).
            switch wf_count_remainder {
                
            // 1 psi value left
            case 1:
                
                temp_variable1 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[end_multiplicity_wf_count], number_of_sigfigs: 7)
                writeString += end_first_value_space + temp_variable1 + String(repeating: " ", count: 66) + String(wf_count_multiplicity + 1) + "\n\n"
                
            // 2 psi values left
            case 2:
                
                temp_variable1 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[end_multiplicity_wf_count], number_of_sigfigs: 7)
                temp_variable2 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[end_multiplicity_wf_count+1], number_of_sigfigs: 7)
                writeString += end_first_value_space + temp_variable1 + end_wf_spaces_array[0] + temp_variable2 + String(repeating: " ", count: 50) + String(wf_count_multiplicity + 1) + "\n\n"
                
            // 3 psi values left
            case 3:
                
                temp_variable1 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[end_multiplicity_wf_count], number_of_sigfigs: 7)
                temp_variable2 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[end_multiplicity_wf_count+1], number_of_sigfigs: 7)
                temp_variable3 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[end_multiplicity_wf_count+2], number_of_sigfigs: 7)
                writeString += end_first_value_space + temp_variable1 + end_wf_spaces_array[0] + temp_variable2 + end_wf_spaces_array[1] + temp_variable3 + String(repeating: " ", count: 34) + String(wf_count_multiplicity + 1) + "\n\n"
                
            // 4 psi values left
            case 4:
                
                temp_variable1 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[end_multiplicity_wf_count], number_of_sigfigs: 7)
                temp_variable2 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[end_multiplicity_wf_count+1], number_of_sigfigs: 7)
                temp_variable3 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[end_multiplicity_wf_count+2], number_of_sigfigs: 7)
                temp_variable4 = output_functional_functions_inst.double_to_scientific_string(double_input: final_results_array[i].psi_list[end_multiplicity_wf_count+3], number_of_sigfigs: 7)
                writeString += end_first_value_space + temp_variable1 + end_wf_spaces_array[0] + temp_variable2 + end_wf_spaces_array[1] + temp_variable3 + end_wf_spaces_array[2] + temp_variable4 + String(repeating: " ", count: 18) + String(wf_count_multiplicity + 1) + "\n\n"
                
            // Number of psi values is a multiple of 5 so remainder is 0, or something went wrong
            default:
                
                writeString += "\n"
                print("either remainder is 0 or somethings wrong")
                
            }
            
        }
        
        
        // Writes appended string variable writeString to output file
        
        myHartreeFockSCFCalculator!.plotDataModel!.calculatedText.append(writeString)
        
        
    }
    
    
    
}

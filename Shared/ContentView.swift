//
//  ContentView.swift
//  Shared
//
//  Created by Jeff Terry on 11/28/21.
//

import SwiftUI
import CorePlot

typealias plotDataType = [CPTScatterPlotField : Double]

struct ContentView: View {
    
    @ObservedObject private var dataCalculator = CalculatePlotData()
    @EnvironmentObject var plotDataModel :PlotDataClass
    @ObservedObject var hartreeFockSCFCalculator = HermanSkillmanCalculator()
    
    @State var selectedOutputIndex :Int = 0
    @State var selectedWavefunctionIndex :Int = -1
    
    @State var selectedWavefunction = ""
    @State var filename = ""
    
    @State var outputPickerArray :[String] = []
    @State var outputWavefunctionArray :[String] = []
    
    @State var isImporting: Bool = false
    
    @State var element = ""
    
    @State var alphaParameter = "0.75"
    @State var inputFileString = ""
    
    @State var potential :[Double] = []
    @State var wavefunctionResults: [(r_list: [Double], psi_list: [Double], quant_n: Double, quant_l: Double, quant_m: Double, number_electrons: Double, new_energy: Double)] = []
    @State var mesh: [Double] = []
    

    var body: some View {
        
        VStack{
      
            CorePlot(dataForPlot: $plotDataModel.plotData, changingPlotParameters: $plotDataModel.changingPlotParameters)
                .setPlotPadding(left: 10)
                .setPlotPadding(right: 10)
                .setPlotPadding(top: 10)
                .setPlotPadding(bottom: 10)
                .padding()
            
            
            
            Divider()
            
            HStack{
                
                Button("Load Input File", action: {
                                isImporting = false
                                
                                //fix broken picker sheet
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isImporting = true
                                }
                            })
                                .padding()
                                .fileImporter(
                                            isPresented: $isImporting,
                                            allowedContentTypes: [.text],
                                            allowsMultipleSelection: false
                                        ) { result in
                                            do {
                                                guard let selectedFile: URL = try result.get().first else { return }
                                                
                                                print("Selected file is", selectedFile)
                                                
                                                //trying to get access to url contents
                                                if (CFURLStartAccessingSecurityScopedResource(selectedFile as CFURL)) {
                                                                        
                                                    filename = selectedFile.lastPathComponent
                                                    
                                                    guard let message = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                                                        
                                                    //print(message)
                                                    
                                                    inputFileString = message
                                                        
                                                    //done accessing the url
                                                    CFURLStopAccessingSecurityScopedResource(selectedFile as CFURL)
                                                    
                                                    
                                                }
                                                else {
                                                    print("Permission error!")
                                                }
                                            } catch {
                                                // Handle failure.
                                                print(error.localizedDescription)
                                            }
                                        }
                
                Text($filename.wrappedValue)
                
                
            }

            
            Divider()

            
            
            HStack{
                
                VStack{
                    
                    Text("Alpha Parameter")
                    
                    TextField("Alpha Parameter between 0.1 and 0.95", text: $alphaParameter)
                        .frame(minWidth: 100.0, idealWidth: 300.0, maxWidth: 400.0, alignment: .center)
                }
                
                

                
                Button("Calculate", action: {self.calculateHartreeFock()} )
                .padding()
                
                
                
            }
            
            Divider()
            
            HStack{
                
               // Spacer()
                
#if os(macOS)
                
                Picker("Output", selection: $selectedWavefunction, content: {
                    ForEach(outputWavefunctionArray, id:\.self) {
                    //ForEach(0..<outputWavefunctionArray.count) {
                        Text($0).tag($0)
                                        }
                })
                    .padding()
                    //.frame(minWidth: 100.0, idealWidth: 300.0, maxWidth: 400.0, alignment: .center)
                    .onChange(of: selectedWavefunction, perform: { selection in
                        
                        if let index = outputWavefunctionArray.firstIndex(of: selection) {
                            
                            selectedWavefunctionIndex = index
                            
                        }
                        
                        if selectedWavefunctionIndex != (outputWavefunctionArray.count - 1){
                            
                            updateWavefunctionPlot(index: selectedWavefunctionIndex)
                            
                        }
                        else{
                            
                            updatePotentialPlot()
                            
                        }
                        
                        
                        
                    })

    
#elseif os(iOS)
                
                NavigationView{
                    
                    Form{
                        
                        Section{
                            
                            Picker("Output", selection: $selectedWavefunction, content: {
                                ForEach(outputWavefunctionArray, id:\.self) {
                                //ForEach(0..<outputWavefunctionArray.count) {
                                    Text($0).tag($0)
                                                    }
                            })
                                .padding()
                                //.frame(minWidth: 100.0, idealWidth: 300.0, maxWidth: 400.0, alignment: .center)
                                .onChange(of: selectedWavefunction, perform: { selection in
                                    
                                    if let index = outputWavefunctionArray.firstIndex(of: selection) {
                                        
                                        selectedWavefunctionIndex = index
                                        
                                    }
                                    
                                    if selectedWavefunctionIndex != (outputWavefunctionArray.count - 1){
                                        
                                        updateWavefunctionPlot(index: selectedWavefunctionIndex)
                                        
                                    }
                                    else{
                                        
                                        updatePotentialPlot()
                                        
                                    }
                                    
                                    
                                    
                                })
                            
                            
                        }
                        
                        
                    }
                    
                
                }

#endif
                
                
                    
                
               // Spacer()
                
                
            }
            
            Spacer()
            
        }
        
    }
    
    func updatePotentialPlot(){
        
        if mesh.count == 0 {
            
            return
        }
        
        //set the Plot Parameters
        plotDataModel.changingPlotParameters.xMin = -3.0
        plotDataModel.changingPlotParameters.xLabel = "X"
        plotDataModel.changingPlotParameters.yLabel = "U(X)"
        plotDataModel.changingPlotParameters.lineColor = .blue()
        plotDataModel.changingPlotParameters.title = element + " Potential"
        
        plotDataModel.zeroData()
        
        let MaxXDisplayCoord = mesh.max()!*0.75
        let MinYDisplayCoord = potential.min()!*1.1
        var MaxYDisplayCoord = potential.max()!*1.1
        
        if MaxYDisplayCoord < -0.0 {
            
            MaxYDisplayCoord = -1.0*MinYDisplayCoord/10.0
        }
        
        plotDataModel.changingPlotParameters.xMax = MaxXDisplayCoord
        plotDataModel.changingPlotParameters.yMax = MaxYDisplayCoord
        plotDataModel.changingPlotParameters.yMin = MinYDisplayCoord
        
        
        
        for i in stride(from: 0, to: mesh.count, by: 1) {
            
            let x = mesh[i]
            let y = potential[i]
            
            let dataPoint: plotDataType = [.X: x, .Y: y]
            plotDataModel.plotData.append(dataPoint)
        }
        
    }
    
    
    func updateWavefunctionPlot(index: Int){
        
        if wavefunctionResults.count == 0 {
            
            return
        }
        
        
        //set the Plot Parameters
        
        plotDataModel.changingPlotParameters.xLabel = "r"
        plotDataModel.changingPlotParameters.yLabel = "r 𝜳(r)"
        plotDataModel.changingPlotParameters.lineColor = .red()
        plotDataModel.changingPlotParameters.title = element + " " + outputWavefunctionArray[index] + " Ry"
        
        plotDataModel.zeroData()
    
        
        let MaxXDisplayCoord = wavefunctionResults[index].r_list.max()!*1.25
        var MinYDisplayCoord = wavefunctionResults[index].psi_list.min()!*1.25
        if MinYDisplayCoord > -0.11 {
            
            MinYDisplayCoord = -0.35
        }
        
        let MaxYDisplayCoord = wavefunctionResults[index].psi_list.max()!*1.25
        
        plotDataModel.changingPlotParameters.xMax = MaxXDisplayCoord
        plotDataModel.changingPlotParameters.yMax = MaxYDisplayCoord
        plotDataModel.changingPlotParameters.yMin = MinYDisplayCoord
        plotDataModel.changingPlotParameters.xMin = -1.0*MaxXDisplayCoord/10.0
        
        
        for i in stride(from: 0, to: wavefunctionResults[index].r_list.count, by: 1) {
            
            let x = wavefunctionResults[index].r_list[i]
            let y = wavefunctionResults[index].psi_list[i]
            
            if abs(y) < 50.0{
                let dataPoint: plotDataType = [.X: x, .Y: y]
                plotDataModel.plotData.append(dataPoint)
            }
        }
    
    
    }
    
    func calculateHartreeFock(){
        
        outputPickerArray = []
        outputWavefunctionArray = []
        
        wavefunctionResults.removeAll()
        potential.removeAll()
        mesh.removeAll()
        
        plotDataModel.calculatedText = ""
        
        
        if inputFileString != "" {
            
            hartreeFockSCFCalculator.inputFileString = inputFileString
            
        }
        else{
            
            return
        }
        
        
        hartreeFockSCFCalculator.alpha = Double(alphaParameter)!
        
        //pass the plotDataModel to the calculator
        hartreeFockSCFCalculator.plotDataModel = self.plotDataModel
        //Calculate the new plotting data and place in the plotDataModel
        hartreeFockSCFCalculator.calculateNonRelativisticHartreeFock()
        
        outputWavefunctionArray = hartreeFockSCFCalculator.orbital_energies
        outputWavefunctionArray.append("Potential")
        
        wavefunctionResults = hartreeFockSCFCalculator.results_array
        potential = hartreeFockSCFCalculator.self_consistent_pot_list
        mesh = hartreeFockSCFCalculator.full_mesh
        
        element = hartreeFockSCFCalculator.element
        plotDataModel.fileName = element
        
        updateWavefunctionPlot(index: 0)
    
    }
   
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

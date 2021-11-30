//
//  CorePlot.swift
//  Atomic Structure Calculations (Non-Relativistic)
//
//  Created by Jeff Terry on 12/17/20.
//
//
//  Based on Code Created by Fred Appelman on 14/12/2020.
//

import Foundation
import SwiftUI
import CorePlot

#if os(macOS)
public typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
public typealias ViewRepresentable = UIViewRepresentable
#endif

public struct CorePlot: ViewRepresentable {
    @Binding var dataForPlot : [plotDataType]
    @Binding var changingPlotParameters: ChangingPlotParameters
    
    class Options {
        var plotPaddingLeft: CGFloat = 10
        var plotPaddingRight: CGFloat = 10
        var plotPaddingBottom: CGFloat = 10
        var plotPaddingTop: CGFloat = 10
      
       }

    @State var options = Options()
    
    public func makeUIView(context: Context) -> CPTGraphHostingView {
        
        let hostView = makeView(context: context)
        return hostView
        
    }

    public func makeNSView(context: Context) -> CPTGraphHostingView {
        
        let hostView = makeView(context: context)
        return hostView
        
    }
    
    public func makeView(context: Context) -> CPTGraphHostingView {
        
        // Create graph
        let newGraph = CPTXYGraph(frame: .zero)

        let theme = CPTTheme(named: .darkGradientTheme)
        newGraph.apply(theme)

        // Create Graph Hosting View
        let hostView = CPTGraphHostingView()
        hostView.hostedGraph = newGraph
        
        // Paddings
        newGraph.paddingLeft   = options.plotPaddingLeft
        newGraph.paddingRight  = options.plotPaddingRight
        newGraph.paddingTop    = options.plotPaddingTop
        newGraph.paddingBottom = options.plotPaddingBottom
        
        //Add Plot Title
        let titleTextStyle: CPTMutableTextStyle = CPTMutableTextStyle()
        titleTextStyle.color = CPTColor.white()
        titleTextStyle.fontSize = 20.0
        titleTextStyle.textAlignment = .center
        newGraph.titleTextStyle = titleTextStyle
        newGraph.title = changingPlotParameters.title

        // Plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.yRange = CPTPlotRange(location: changingPlotParameters.yMin as NSNumber, length:(changingPlotParameters.yMax - changingPlotParameters.yMin) as NSNumber)
        plotSpace.xRange = CPTPlotRange(location: changingPlotParameters.xMin as NSNumber, length: (changingPlotParameters.xMax - changingPlotParameters.xMin) as NSNumber)
        
        // Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet

        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 1.0
            x.orthogonalPosition    = 0.0
            x.minorTicksPerInterval = 3
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 0.5
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = 0.0
            y.delegate = context.coordinator
        }
        
        // Create a plot area with color
        let theLineStyle = CPTMutableLineStyle()
        theLineStyle.miterLimit    = 1.0
        theLineStyle.lineWidth     = 3.0
        theLineStyle.lineColor     = changingPlotParameters.lineColor
        
        let linePlot = CPTScatterPlot(frame: .zero)
        linePlot.dataLineStyle = theLineStyle
        linePlot.identifier    = "Blue Plot" as NSString
        linePlot.interpolation = .curved
        newGraph.add(linePlot)

        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = .black()
        let plotSymbol = CPTPlotSymbol.ellipse()
        plotSymbol.fill          = CPTFill(color: changingPlotParameters.lineColor)
        plotSymbol.lineStyle     = symbolLineStyle
        plotSymbol.size          = CGSize(width: 10.0, height: 10.0)
        linePlot.plotSymbol = plotSymbol

        // dataSourceLinePlot.dataSource set to the coordinator of the ViewRepresentable
        linePlot.dataSource  = context.coordinator
        
        // add lineplot to graph
        newGraph.add(linePlot)

        // return the View
        return hostView
        
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, data: dataForPlot, yLabel: changingPlotParameters.yLabel, xLabel: changingPlotParameters.xLabel)
        }
    
    public func updateUIView(_ nsView: CPTGraphHostingView, context: Context) {
        
        updateView(nsView, context: context)

        }

    public func updateNSView(_ nsView: CPTGraphHostingView, context: Context) {
        
        updateView(nsView, context: context)
        
    
   /*
        Leaving this here because it may be useful for live updating of graph
         
        let oldRange =  CPTPlotRange(locationDecimal: CPTDecimalFromDouble(Double(0.0)), lengthDecimal: CPTDecimalFromDouble(Double(2.0)))
        let newRange =  CPTPlotRange(locationDecimal: CPTDecimalFromDouble(Double(0.0)), lengthDecimal: CPTDecimalFromDouble(Double(2.0)))
            
        CPTAnimation.animate(plotSpace, property: "xRange", from: oldRange, to: newRange, duration:0.3)
        plot?.insertData(at: UInt(0.0), numberOfRecords: UInt(dataForPlot.count))*/
        
     
        }
    
    public func updateView(_ nsView: CPTGraphHostingView, context: Context){
        
        // Get graph fromm View
        
        guard let graph = nsView.hostedGraph as? CPTXYGraph else { return }
        
        let theLineStyle = CPTMutableLineStyle()
        theLineStyle.miterLimit    = 1.0
        theLineStyle.lineWidth     = 3.0
        theLineStyle.lineColor     = changingPlotParameters.lineColor
        
        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = .black()
        let plotSymbol = CPTPlotSymbol.ellipse()
        plotSymbol.fill          = CPTFill(color: changingPlotParameters.lineColor)
        plotSymbol.lineStyle     = symbolLineStyle
        plotSymbol.size          = CGSize(width: 10.0, height: 10.0)
        
        //Update the data in the Coordinator
        context.coordinator.data = dataForPlot
        
        //Update the axisLabels
        guard let axisSet = graph.axisSet as? CPTXYAxisSet else { return }
        guard let y = axisSet.yAxis else {return}
        y.title = changingPlotParameters.yLabel
        guard let x = axisSet.xAxis else {return}
        x.title = changingPlotParameters.xLabel
        
        //Update the plot range
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.yRange = CPTPlotRange(location: changingPlotParameters.yMin as NSNumber, length:(changingPlotParameters.yMax - changingPlotParameters.yMin) as NSNumber)
        plotSpace.xRange = CPTPlotRange(location: changingPlotParameters.xMin as NSNumber, length: (changingPlotParameters.xMax - changingPlotParameters.xMin) as NSNumber)
        
        guard let plot = graph.plot(at: 0) as? CPTScatterPlot else {return}
        plot.dataLineStyle = theLineStyle
        plot.plotSymbol = plotSymbol
        
        //Add Plot Title
        //Add Plot Title
        let titleTextStyle: CPTMutableTextStyle = CPTMutableTextStyle()
        titleTextStyle.color = CPTColor.white()
        titleTextStyle.fontSize = 20.0
        titleTextStyle.textAlignment = .center
        graph.titleTextStyle = titleTextStyle
        graph.title = changingPlotParameters.title
        
        //Set the plot for reloading
        graph.reloadData()
    }

    public class Coordinator: NSObject, CPTScatterPlotDataSource, CPTAxisDelegate {

        var parent: CorePlot
        var data: [plotDataType]
        var yLabel: String
        var xLabel: String

        init(parent: CorePlot, data: [plotDataType], yLabel: String, xLabel: String) {
            self.parent = parent
            self.data = data
            self.yLabel = yLabel
            self.xLabel = xLabel
        }

        // MARK: - Plot Data Source Methods
        public func numberOfRecords(for plot: CPTPlot) -> UInt
        {
            return UInt(data.count)
        }

        public func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any?
        {
            let plotField = CPTScatterPlotField(rawValue: Int(field))

            if let num = data[Int(record)][plotField!] {
                return num as NSNumber
            }
            else {
                return nil
            }
        }

        // MARK: - Axis Delegate Methods
        public func axis(_ axis: CPTAxis, shouldUpdateAxisLabelsAtLocations locations: Set<NSNumber>) -> Bool
        {
            if let formatter = axis.labelFormatter {
                let labelOffset = axis.labelOffset

                var newLabels = Set<CPTAxisLabel>()

                for location in locations {
                    if let labelTextStyle = axis.labelTextStyle?.mutableCopy() as? CPTMutableTextStyle {
                        if location.doubleValue >= 0.0 {
                            labelTextStyle.color = .green()
                        }
                        else {
                            labelTextStyle.color = .red()
                        }

                        let labelString   = formatter.string(for:location)
                        let newLabelLayer = CPTTextLayer(text: labelString, style: labelTextStyle)

                        let newLabel = CPTAxisLabel(contentLayer: newLabelLayer)
                        newLabel.tickLocation = location
                        newLabel.offset       = labelOffset
                        
                        newLabels.insert(newLabel)
                    }
                    
                    axis.axisLabels = newLabels
               
                }
            }
            
            return false
        }
        
        
        
        
        
    }
}

extension CorePlot {
    func setPlotPadding(left: CGFloat) -> CorePlot {
        options.plotPaddingLeft = left
        return self
    }

    func setPlotPadding(right: CGFloat) -> CorePlot {
        self.options.plotPaddingRight = right
        return self
    }

    func setPlotPadding(top: CGFloat) -> CorePlot {
        self.options.plotPaddingTop = top
        return self
    }

    func setPlotPadding(bottom: CGFloat) -> CorePlot {
        self.options.plotPaddingBottom = bottom
        return self
    }
    
}




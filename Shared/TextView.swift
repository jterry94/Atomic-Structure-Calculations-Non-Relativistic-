//
//  TextView.swift
//  TextView
//
//  Created by Jeff_Terry on 11/29/21.
//

//
//  TextView.swift
//  cos(x) Tab
//
//  Created by Jeff Terry on 1/23/21.
//
import SwiftUI
import UniformTypeIdentifiers

struct TextView: View {
    
    @EnvironmentObject var plotDataModel :PlotDataClass
    
    @State  var document: TextExportDocument = TextExportDocument(message: "")
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    
    var body: some View {
        
        VStack{
            TextEditor(text: $plotDataModel.calculatedText )
            
            HStack{
                
                Button("Save", action: {
                    isExporting = false
                    document.message = plotDataModel.calculatedText
                    //fix broken picker sheet
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isExporting = true
                    }
                    
                })
                    .padding()
                Button("Load", action: {
                    isImporting = false
                    
                    //fix broken picker sheet
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isImporting = true
                    }
                })
                    .padding()
                
            }
        }
        .padding()
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [UTType.plainText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                
                //trying to get access to url contents
                if (CFURLStartAccessingSecurityScopedResource(selectedFile as CFURL)) {
                    
                    guard let message = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                    
                    document.message = message
                    
                    plotDataModel.calculatedText = message
                        
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
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: UTType.plainText,
            defaultFilename: plotDataModel.fileName
        ) { result in
            if case .success = result {
                // Handle success.
            } else {
                // Handle failure.
            }
        }
        
        
        
    }
    
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView()
    }
}

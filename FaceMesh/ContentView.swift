//
//  ContentView.swift
//  FaceMesh
//
//  Created by jht2 on 3/1/23.
//

import SwiftUI
import ARVideoKit

struct ContentView: View {
    
    @StateObject var recordViewModel = RecordViewModel()
    
    @State var isRecording: Bool = false
    
    var body: some View {
        VStack {
            
            FaceMeshView(recordViewModel: recordViewModel)
            
            Button {
                if isRecording {
                    recordViewModel.recordAR!.stopAndExport({ videoPath, permissionStatus, exported in
                        print("videoPath: \(videoPath)")
                        print("permissionStatus: \(permissionStatus)")
                        print("exported: \(exported)")
                    })
                } else {
                    recordViewModel.recordAR?.record()
                }
                isRecording.toggle()
            } label: {
                Text(isRecording ? "Stop and Export" : "Record")
            }
        }
    }
}

struct BridgeView: UIViewControllerRepresentable {
    @Binding var analysis: String
    var recordViewModel: RecordViewModel

    func makeUIViewController(context: Context) -> ViewController {
        
        let viewCtl = ViewController(recordViewModel: recordViewModel)

        viewCtl.reportChange = {
            // print("reportChange")
            analysis = viewCtl.analysis
        }
        return viewCtl
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // print("BridgeView updateUIViewController")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class RecordViewModel: ObservableObject {
    @Published var recordAR: RecordAR?
}


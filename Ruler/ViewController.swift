//
//  ViewController.swift
//  Ruler
//
//  Created by Faisal Babkoor on 4/8/20.
//  Copyright © 2020 Faisal Babkoor. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.debugOptions = [.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResult.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        if dotNodes.count >= 2 {
            dotNodes.forEach { $0.removeFromParentNode() }
            dotNodes = [SCNNode]()
        }
        
        let sphere = SCNSphere()
        sphere.radius = 0.005
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemRed
        sphere.materials = [material]
        let node = SCNNode()
        node.geometry = sphere
        node.position = SCNVector3(x: Float(CGFloat(hitResult.worldTransform.columns.3.x)),
                                   y: Float(CGFloat(hitResult.worldTransform.columns.3.y)),
                                   z: Float(CGFloat(hitResult.worldTransform.columns.3.z)))
        sceneView.scene.rootNode.addChildNode(node)
        dotNodes.append(node)
        if dotNodes.count > 1 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        print(start.position)
        print(end.position)
        let x = (end.position.x - start.position.x)
        let y = (end.position.y - start.position.y)
        let z = (end.position.z - start.position.z)
        let poX = powf(x, 2)
        let poY = powf(y, 2)
        let poZ = powf(z, 2)
        let p = sqrtf(poX + poY + poZ)
        print(p)
        updateText(text: "\(p)", atPostion: end.position)
        
    }
    
    func updateText(text: String, atPostion p: SCNVector3) {
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.systemRed
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(p.x, p.y + 0.01 , p.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}

import SwiftUI
import SceneKit

// MARK: - データモデル
struct ChainNodeData {
    let id: String
    let name: String
    let role: ChainRole
    let level: Int      // 0: 恩人, 1: ユーザー, 2: 受益者
    var connections: [String] = []

    enum ChainRole {
        case benefactor, user, recipient
        var color: UIColor {
            switch self {
            case .benefactor: return UIColor(red: 1.0, green: 0.84, blue: 0.43, alpha: 1)  // batAccent
            case .user:       return UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1)  // batPrimary
            case .recipient:  return UIColor(red: 0.31, green: 0.80, blue: 0.77, alpha: 1) // batSecondary
            }
        }
        var size: CGFloat {
            switch self {
            case .benefactor: return 0.18
            case .user:       return 0.22
            case .recipient:  return 0.14
            }
        }
        var label: String {
            switch self {
            case .benefactor: return "恩人"
            case .user:       return "あなた"
            case .recipient:  return "受益者"
            }
        }
    }
}

// MARK: - SceneKit ビュー
struct GratitudeChainSceneView: UIViewRepresentable {
    let nodes: [ChainNodeData]

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.10, alpha: 1)
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X

        let scene = SCNScene()
        sceneView.scene = scene

        setupCamera(scene: scene)
        setupLighting(scene: scene)
        buildGraph(scene: scene)
        addStarfield(scene: scene)

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    // MARK: - カメラ設定
    private func setupCamera(scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 100
        cameraNode.position = SCNVector3(x: 0, y: 0.5, z: 3.5)
        scene.rootNode.addChildNode(cameraNode)
    }

    // MARK: - ライト設定
    private func setupLighting(scene: SCNScene) {
        // アンビエントライト
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.15, alpha: 1)
        scene.rootNode.addChildNode(ambientLight)

        // ポイントライト（中心）
        let pointLight = SCNNode()
        pointLight.light = SCNLight()
        pointLight.light?.type = .omni
        pointLight.light?.color = UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1)
        pointLight.light?.intensity = 800
        pointLight.light?.attenuationStartDistance = 2
        pointLight.light?.attenuationEndDistance = 8
        pointLight.position = SCNVector3(0, 0, 1)
        scene.rootNode.addChildNode(pointLight)

        // トップライト
        let topLight = SCNNode()
        topLight.light = SCNLight()
        topLight.light?.type = .directional
        topLight.light?.color = UIColor(white: 0.5, alpha: 1)
        topLight.eulerAngles = SCNVector3(-Float.pi / 4, 0, 0)
        scene.rootNode.addChildNode(topLight)
    }

    // MARK: - グラフ構築
    private func buildGraph(scene: SCNScene) {
        var nodePositions: [String: SCNVector3] = [:]

        // ノードの位置を決定
        for node in nodes {
            let pos: SCNVector3
            switch node.level {
            case 0: // 恩人（最上部）
                pos = SCNVector3(0, 1.2, 0)
            case 1: // ユーザー（中央）
                pos = SCNVector3(0, 0, 0)
            case 2: // 受益者（最下部、放射状）
                let recipients = nodes.filter { $0.level == 2 }
                let idx = recipients.firstIndex(where: { $0.id == node.id }) ?? 0
                let total = recipients.count
                let angle = (Float(idx) / Float(total)) * Float.pi * 2
                let radius: Float = 1.0
                pos = SCNVector3(cos(angle) * radius, -1.0, sin(angle) * radius * 0.5)
            default:
                pos = SCNVector3(0, 0, 0)
            }
            nodePositions[node.id] = pos
            addNodeSphere(node: node, position: pos, scene: scene)
        }

        // エッジを描画
        for node in nodes {
            guard let fromPos = nodePositions[node.id] else { continue }
            for connId in node.connections {
                if let toPos = nodePositions[connId] {
                    addEdge(from: fromPos, to: toPos, scene: scene)
                }
            }
        }
    }

    // MARK: - ノード球体を追加
    private func addNodeSphere(node: ChainNodeData, position: SCNVector3, scene: SCNScene) {
        let sphereNode = SCNNode()

        // 外側の発光球体
        let glowSphere = SCNSphere(radius: node.role.size * 1.6)
        let glowMaterial = SCNMaterial()
        glowMaterial.diffuse.contents = node.role.color.withAlphaComponent(0.08)
        glowMaterial.emission.contents = node.role.color.withAlphaComponent(0.05)
        glowMaterial.isDoubleSided = true
        glowSphere.materials = [glowMaterial]
        let glowNode = SCNNode(geometry: glowSphere)
        sphereNode.addChildNode(glowNode)

        // メイン球体
        let sphere = SCNSphere(radius: node.role.size)
        sphere.segmentCount = 48
        let material = SCNMaterial()
        material.diffuse.contents = node.role.color.withAlphaComponent(0.3)
        material.emission.contents = node.role.color.withAlphaComponent(0.6)
        material.specular.contents = UIColor.white
        material.shininess = 80
        material.lightingModel = .phong
        sphere.materials = [material]
        let mainNode = SCNNode(geometry: sphere)
        sphereNode.addChildNode(mainNode)

        // リング（恩人・ユーザーのみ）
        if node.level < 2 {
            let ring = SCNTorus(ringRadius: node.role.size * 1.5, pipeRadius: 0.012)
            let ringMaterial = SCNMaterial()
            ringMaterial.diffuse.contents = node.role.color.withAlphaComponent(0.4)
            ringMaterial.emission.contents = node.role.color.withAlphaComponent(0.4)
            ring.materials = [ringMaterial]
            let ringNode = SCNNode(geometry: ring)
            ringNode.eulerAngles = SCNVector3(Float.pi / 2.2, 0, 0)
            sphereNode.addChildNode(ringNode)

            // リングをゆっくり回転
            let spin = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 8))
            ringNode.runAction(spin)
        }

        // フロートアニメーション
        let floatUp = SCNAction.moveBy(x: 0, y: 0.06, z: 0, duration: 1.5 + Double(node.level) * 0.3)
        floatUp.timingMode = .easeInEaseOut
        let floatDown = SCNAction.moveBy(x: 0, y: -0.06, z: 0, duration: 1.5 + Double(node.level) * 0.3)
        floatDown.timingMode = .easeInEaseOut
        let floatLoop = SCNAction.repeatForever(SCNAction.sequence([floatUp, floatDown]))
        sphereNode.runAction(floatLoop)

        // パルスアニメーション
        let pulse = SCNAction.repeatForever(SCNAction.sequence([
            SCNAction.scale(to: 1.08, duration: 1.0),
            SCNAction.scale(to: 1.0, duration: 1.0)
        ]))
        glowNode.runAction(pulse)

        sphereNode.position = position
        scene.rootNode.addChildNode(sphereNode)

        // テキストラベル
        addLabel(text: node.name, subtext: node.role.label, position: position, color: node.role.color, scene: scene)
    }

    // MARK: - テキストラベルを追加
    private func addLabel(text: String, subtext: String, position: SCNVector3, color: UIColor, scene: SCNScene) {
        let textGeometry = SCNText(string: text, extrusionDepth: 0.005)
        textGeometry.font = UIFont.systemFont(ofSize: 0.18, weight: .bold)
        textGeometry.flatness = 0.01
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = color
        textMaterial.emission.contents = color.withAlphaComponent(0.5)
        textGeometry.materials = [textMaterial]

        let textNode = SCNNode(geometry: textGeometry)
        let (min, max) = textNode.boundingBox
        let width = max.x - min.x
        textNode.position = SCNVector3(position.x - width / 2, position.y - 0.38, position.z)
        textNode.scale = SCNVector3(1, 1, 1)
        scene.rootNode.addChildNode(textNode)
    }

    // MARK: - エッジを追加
    private func addEdge(from: SCNVector3, to: SCNVector3, scene: SCNScene) {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let dz = to.z - from.z
        let length = sqrt(dx*dx + dy*dy + dz*dz)

        let cylinder = SCNCylinder(radius: 0.008, height: CGFloat(length))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 0.4)
        material.emission.contents = UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 0.3)
        cylinder.materials = [material]

        let edgeNode = SCNNode(geometry: cylinder)

        let midX = (from.x + to.x) / 2
        let midY = (from.y + to.y) / 2
        let midZ = (from.z + to.z) / 2
        edgeNode.position = SCNVector3(midX, midY, midZ)

        let up = SCNVector3(0, 1, 0)
        let dir = SCNVector3(dx/length, dy/length, dz/length)
        let cross = SCNVector3(
            up.y * dir.z - up.z * dir.y,
            up.z * dir.x - up.x * dir.z,
            up.x * dir.y - up.y * dir.x
        )
        let dot = up.x * dir.x + up.y * dir.y + up.z * dir.z
        let angle = acos(dot)
        edgeNode.rotation = SCNVector4(cross.x, cross.y, cross.z, angle)

        // パーティクル流れアニメーション
        let pulse = SCNAction.repeatForever(SCNAction.sequence([
            SCNAction.customAction(duration: 1.0) { node, time in
                let alpha = Float(0.2 + 0.4 * sin(Float(time) * .pi))
                material.emission.contents = UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: CGFloat(alpha))
            }
        ]))
        edgeNode.runAction(pulse)

        scene.rootNode.addChildNode(edgeNode)
    }

    // MARK: - 星空背景
    private func addStarfield(scene: SCNScene) {
        for _ in 0..<200 {
            let star = SCNSphere(radius: 0.015)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.white
            mat.emission.contents = UIColor.white.withAlphaComponent(0.8)
            star.materials = [mat]
            let node = SCNNode(geometry: star)
            node.position = SCNVector3(
                Float.random(in: -8...8),
                Float.random(in: -5...5),
                Float.random(in: -8...(-2))
            )
            scene.rootNode.addChildNode(node)
        }
    }
}

// MARK: - SwiftUI ラッパー
struct GratitudeChain3DView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    var userName: String = "あなた"

    // 実データからノードを構築
    private var chainNodes: [ChainNodeData] {
        let userId = "u1"
        var nodes: [ChainNodeData] = []

        // 恩人ノード（ユーザーノードに接続）
        let benefactorIds = appViewModel.benefactors.map { $0.id }
        for b in appViewModel.benefactors {
            nodes.append(ChainNodeData(id: b.id, name: b.name, role: .benefactor, level: 0, connections: [userId]))
        }

        // 受益者ノード（重複を名前で排除）
        var recipientNames: [String] = []
        var recipientNodes: [ChainNodeData] = []
        for act in appViewModel.kindnessActs {
            let name = act.recipientName
            if !recipientNames.contains(name) {
                recipientNames.append(name)
                recipientNodes.append(ChainNodeData(id: "r_\(name)", name: name, role: .recipient, level: 2))
            }
        }

        // ユーザーノード（受益者に接続）
        let recipientIds = recipientNodes.map { $0.id }
        let userNode = ChainNodeData(id: userId, name: userName, role: .user, level: 1, connections: recipientIds)
        nodes.append(userNode)
        nodes.append(contentsOf: recipientNodes)

        // データがない場合はサンプルを返す
        if nodes.count == 1 {
            return [
                ChainNodeData(id: userId, name: userName, role: .user, level: 1, connections: [])
            ]
        }
        return nodes
    }

    private var benefactorCount: Int { appViewModel.benefactors.count }
    private var recipientCount: Int { Set(appViewModel.kindnessActs.map { $0.recipientName }).count }
    private var connectionCount: Int { benefactorCount + recipientCount }

    var body: some View {
        ZStack {
            Color.batBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("感謝チェーン")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.batTextPrimary)
                        Text("ドラッグして回転 / ピンチでズーム")
                            .font(.system(size: 12))
                            .foregroundColor(Color.batTextSecondary)
                    }
                    Spacer()
                }
                .padding()

                if appViewModel.benefactors.isEmpty && appViewModel.kindnessActs.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Text("🌐")
                            .font(.system(size: 64))
                        Text("チェーンがまだありません")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.batTextSecondary)
                        Text("恩人を登録して活動を記録すると\nここに感謝のつながりが広がります")
                            .font(.system(size: 13))
                            .foregroundColor(Color.batTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.45)
                } else {
                    // 3D ビュー
                    GratitudeChainSceneView(nodes: chainNodes)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.55)
                        .cornerRadius(20)
                        .padding(.horizontal)
                }

                // 凡例
                HStack(spacing: 24) {
                    LegendItem(color: Color(UIColor(red: 1.0, green: 0.84, blue: 0.43, alpha: 1)), label: "恩人")
                    LegendItem(color: Color.batPrimary, label: "あなた")
                    LegendItem(color: Color.batSecondary, label: "受益者")
                }
                .padding(.top, 20)

                // 統計（実データ）
                HStack(spacing: 0) {
                    Chain3DStatItem(value: "\(benefactorCount)", label: "恩人")
                    Divider().frame(height: 36).background(Color.batCardLight)
                    Chain3DStatItem(value: "\(recipientCount)", label: "受益者")
                    Divider().frame(height: 36).background(Color.batCardLight)
                    Chain3DStatItem(value: "\(connectionCount)", label: "繋がり")
                }
                .padding(.vertical, 16)
                .background(Color.batCard)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
            }
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.batTextSecondary)
        }
    }
}

struct Chain3DStatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.batTextPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.batTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GratitudeChain3DView()
        .environmentObject(AppViewModel())
}

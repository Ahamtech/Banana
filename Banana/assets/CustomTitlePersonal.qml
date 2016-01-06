import bb.cascades 1.3

TitleBar {
    signal refresh
    property alias titlename: banana.text
    kind: TitleBarKind.FreeForm
    kindProperties: FreeFormTitleBarKindProperties {
        Container {
            layout: DockLayout {
            
            }
            Label {
                
                id: banana
                text: qsTr("Banana")
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Center
                textStyle.fontSize: FontSize.Large
            }
            
            ImageView {
                animations: [
                    RotateTransition {
                        id: rotateanimate
                        toAngleZ: 360
                        fromAngleZ: 0
                        delay: 0
                        duration: 1000
                        easingCurve:StockCurve.CircularIn
                        repeatCount: AnimationRepeatCount.Forever
                    }
                
                ]
                verticalAlignment: VerticalAlignment.Center
                maxHeight: 70
                maxWidth: 70
                horizontalAlignment: HorizontalAlignment.Right
                imageSource: "asset:///Images/BBicons/ic_reload.png"
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            rotateanimate.play()
                            refresh()
                            tabbedPane.activeTab.enabled=false
                        }
                    }
                ]
            
            }
        
        }
    }
}

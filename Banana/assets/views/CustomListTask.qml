import bb.cascades 1.3
import bb.device 1.4
import bb.system 1.2
Container {
    signal complete
    signal incomplete
    rightPadding: ui.du(2.0)
    leftPadding: ui.du(2.0)
    topPadding: ui.du(1.0)
    bottomPadding: ui.du(1.0)
    property alias taskname: taskid.text
    property alias tasktime: duedate.text
    property alias taskassigne: assignee.text
    property alias fav: favorite.visible
    attachedObjects: [
        DisplayInfo {
            id: displayinfo
        },
        SystemToast {
            id: compltetoast
            body: qsTr("Marked as completed")
        },
        SystemToast {
            id: notcompltetoast
            body: qsTr("Marked as not completed")
        }
    ]
    
    Container {
        
        Container {
            maxHeight: 70
            minHeight: 70
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            Container {
                
                Container {
                    background: Color.Black
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        
                        }
                        
                        Container {
                            verticalAlignment: VerticalAlignment.Center
                            
                            rightMargin: ui.du(1.0)
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            
                            }
                            CheckBox {
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                scaleX: 0.9
                                scaleY: 0.9
                                onCheckedChanged: {
                                    if (checked) {
                                        complete()
                                        compltetoast.show()
                                    } else {
                                        incomplete()
                                        notcompltetoast.show()
                                    }
                                }
                            
                            }
                        
                        }
                        Container {
                            verticalAlignment: VerticalAlignment.Center
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                            Label {
                                id: taskid
                                // text: "task"
                                textStyle.fontSize: FontSize.Small
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Center
                            }
                        }
                        Container {
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: -1
                            }
                            verticalAlignment: VerticalAlignment.Center
                            Container {
                                verticalAlignment: VerticalAlignment.Center
                                layout: StackLayout {
                                    orientation: LayoutOrientation.LeftToRight
                                
                                }
                                Label {
                                    id: assignee
                                    // text: "task"
                                    visible: displayinfo.pixelSize.width == 1440
                                }
                                
                                Label {
                                    verticalAlignment: VerticalAlignment.Center
                                    //  text: 'apro ukslkas lkjsakfkask'
                                    id: duedate
                                    textStyle.fontSize: FontSize.PointValue
                                    textStyle.fontSizeValue: 5
                                    opacity: 0.8
                                }
                            
                            }
                            
                            Container {
                                
                                id: favorite
                                background: Application.themeSupport.theme.colorTheme.primary
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                visible: false
                                ImageView {
                                    imageSource: "asset:///Images/BBicons/ic_heartblack.png"
                                    maxHeight: 40
                                    maxWidth: 40
                                    leftMargin: ui.du(4.0)
                                
                                }
                            
                            }
                        
                        }
                    
                    }
                
                
                }
            }
        }
        Container {
            minHeight: 2
            maxHeight: 1
            horizontalAlignment: HorizontalAlignment.Fill
            background: Color.LightGray
        }
    }

}

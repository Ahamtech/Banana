import bb.cascades 1.3
Container {
    property alias taskname:taskid.text
    property alias tasktime:story.text
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom         
        }
        horizontalAlignment: HorizontalAlignment.Fill
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            
            }
            horizontalAlignment: HorizontalAlignment.Fill
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                
                }
                horizontalAlignment: HorizontalAlignment.Fill
                background: Color.create("#50ffffff")
                Container {
                    preferredHeight: 100
                    preferredWidth: 10
                }
                Container {
                    verticalAlignment: VerticalAlignment.Center
                    leftPadding: 10
                    Label {
                        // Give Task Header ID  here
                        text: qsTr(taskname) + Retranslate.onLocaleOrLanguageChanged
                        textStyle.fontSize: FontSize.Medium
                    }
                    Label {
                        text: qsTr(tasktime) + Retranslate.onLocaleOrLanguageChanged
                    }
                }
            }
        
        }
        Container {
            background: Color.LightGray
            preferredHeight: 2
            horizontalAlignment: HorizontalAlignment.Fill
        }
    }
}


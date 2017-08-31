// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the AGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import UM 1.2 as UM
import Cura 1.0 as Cura

import "Menus"

Column
{
    id: base;

    property int currentExtruderIndex: ExtruderManager.activeExtruderIndex;
    property bool currentExtruderVisible: extrudersList.visible;

    spacing: UM.Theme.getSize("default_margin").height

    signal showTooltip(Item item, point location, string text)
    signal hideTooltip()

    Item
    {
        height: UM.Theme.getSize("default_margin").height / 4
        width: height
        visible: extruderSelectionRow.visible
    }

    Label
    {
        id: extruderSelectionLabel
        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("default_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }
        height: UM.Theme.getSize("sidebar_tabs").height / 3
        text: catalog.i18nc("@label", "Extruder configuration")
        font: UM.Theme.getFont("default_bold")
        color: UM.Theme.getColor("text")
        visible: extruderSelectionRow.visible
    }

    Item
    {
        id: extruderSelectionRow
        width: parent.width
        height: UM.Theme.getSize("sidebar_tabs").height
        visible: machineExtruderCount.properties.value > 1 && !sidebar.monitoringPrint

        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("default_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }

        ListView
        {
            id: extrudersList
            property var index: 0

            height: UM.Theme.getSize("sidebar_header_mode_tabs").height
            width: parent.width
            boundsBehavior: Flickable.StopAtBounds

            anchors
            {
                left: parent.left
                leftMargin: UM.Theme.getSize("default_margin").width / 2
                right: parent.right
                rightMargin: UM.Theme.getSize("default_margin").width / 2
                verticalCenter: parent.verticalCenter
            }

            ExclusiveGroup { id: extruderMenuGroup; }

            orientation: ListView.Horizontal

            model: Cura.ExtrudersModel { id: extrudersModel; addGlobal: false }

            Connections
            {
                target: Cura.MachineManager
                onGlobalContainerChanged:
                {
                    forceActiveFocus() // Changing focus applies the currently-being-typed values so it can change the displayed setting values.
                    var extruder_index = (machineExtruderCount.properties.value == 1) ? -1 : 0
                    ExtruderManager.setActiveExtruderIndex(extruder_index);
                }
            }

            delegate: Button
            {
                height: ListView.view.height
                width: ListView.view.width / extrudersModel.rowCount()

                text: model.name
                tooltip: model.name
                exclusiveGroup: extruderMenuGroup
                checked: base.currentExtruderIndex == index

                onClicked:
                {
                    forceActiveFocus() // Changing focus applies the currently-being-typed values so it can change the displayed setting values.
                    ExtruderManager.setActiveExtruderIndex(index);
                }

                style: ButtonStyle
                {
                    background: Item
                    {
                        Rectangle
                        {
                            anchors.fill: parent
                            border.width: UM.Theme.getSize("default_lining").width
                            border.color: control.checked ? UM.Theme.getColor("toggle_checked_border") :
                                          control.pressed ? UM.Theme.getColor("toggle_active_border") :
                                          control.hovered ? UM.Theme.getColor("toggle_hovered_border") : UM.Theme.getColor("toggle_unchecked_border")
                            color: control.checked ? UM.Theme.getColor("toggle_checked") :
                                   control.pressed ? UM.Theme.getColor("toggle_active") :
                                   control.hovered ? UM.Theme.getColor("toggle_hovered") : UM.Theme.getColor("toggle_unchecked")
                            Behavior on color { ColorAnimation { duration: 50; } }
                        }

                        Item
                        {
                            id: extruderButtonFace
                            anchors.centerIn: parent
                            width: {
                                var extruderTextWidth = extruderStaticText.visible ? extruderStaticText.width : 0;
                                var iconWidth = extruderIconItem.width;
                                return extruderTextWidth + iconWidth + UM.Theme.getSize("default_margin").width / 4;
                            }

                            // Static text "Extruder"
                            Text
                            {
                                id: extruderStaticText
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left

                                color: control.checked ? UM.Theme.getColor("toggle_checked_text") :
                                       control.pressed ? UM.Theme.getColor("toggle_active_text") :
                                       control.hovered ? UM.Theme.getColor("toggle_hovered_text") : UM.Theme.getColor("toggle_unchecked_text")

                                font: UM.Theme.getFont("default")
                                text: catalog.i18nc("@label", "Extruder")
                                visible: width < (control.width - extruderIconItem.width - UM.Theme.getSize("default_margin").width)
                                elide: Text.ElideRight
                            }

                            // Everthing for the extruder icon
                            Item
                            {
                                id: extruderIconItem
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right

                                property var sizeToUse:
                                {
                                    var minimumWidth = control.width < UM.Theme.getSize("button").width ? control.width : UM.Theme.getSize("button").width;
                                    var minimumHeight = control.height < UM.Theme.getSize("button").height ? control.height : UM.Theme.getSize("button").height;
                                    var minimumSize = minimumWidth < minimumHeight ? minimumWidth : minimumHeight;
                                    minimumSize -= UM.Theme.getSize("default_margin").width;
                                    return minimumSize;
                                }

                                width: sizeToUse
                                height: sizeToUse

                                UM.RecolorImage {
                                    id: mainCircle
                                    anchors.fill: parent

                                    sourceSize.width: parent.width
                                    sourceSize.height: parent.width
                                    source: UM.Theme.getIcon("extruder_button")

                                    color: extruderNumberText.color
                                }

                                Text
                                {
                                    id: extruderNumberText
                                    anchors.centerIn: parent
                                    text: index + 1;
                                    color: control.checked ? UM.Theme.getColor("toggle_checked_text") :
                                           control.pressed ? UM.Theme.getColor("toggle_active_text") :
                                           control.hovered ? UM.Theme.getColor("toggle_hovered_text") : UM.Theme.getColor("toggle_unchecked_text")
                                    font: UM.Theme.getFont("default_bold")
                                }

                                // Material colour circle
                                // Only draw the filling colour of the material inside the SVG border.
                                Rectangle
                                {
                                    anchors
                                    {
                                        right: parent.right
                                        top: parent.top
                                        rightMargin: parent.sizeToUse * 0.04
                                        topMargin: parent.sizeToUse * 0.04
                                    }

                                    color: model.color

                                    width: parent.width * 0.27
                                    height: parent.height * 0.27
                                    radius: width / 2

                                    border.width: 0
                                    border.color: "transparent"

                                    opacity: !control.checked ? 0.6 : 1.0
                                }
                            }
                        }
                    }
                    label: Item {}
                }
            }
        }
    }

    Item
    {
        id: variantRowSpacer
        height: UM.Theme.getSize("default_margin").height / 4
        width: height
        visible: !extruderSelectionRow.visible
    }

    // Material Row
    Item
    {
        id: materialRow
        height: UM.Theme.getSize("sidebar_setup").height
        visible: Cura.MachineManager.hasMaterials && !sidebar.monitoringPrint && !sidebar.hideSettings

        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("default_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }

        Text
        {
            id: materialLabel
            text: catalog.i18nc("@label","Material");
            width: parent.width * 0.45 - UM.Theme.getSize("default_margin").width
            font: UM.Theme.getFont("default");
            color: UM.Theme.getColor("text");
        }

        ToolButton {
            id: materialSelection
            text: Cura.MachineManager.activeMaterialName
            tooltip: Cura.MachineManager.activeMaterialName
            visible: Cura.MachineManager.hasMaterials
            property var valueError:
            {
                var data = Cura.ContainerManager.getContainerMetaDataEntry(Cura.MachineManager.activeMaterialId, "compatible")
                if(data == "False")
                {
                    return true
                }
                else
                {
                    return false
                }

            }
            property var valueWarning: ! Cura.MachineManager.isActiveQualitySupported

            enabled: !extrudersList.visible || base.currentExtruderIndex  > -1

            height: UM.Theme.getSize("setting_control").height
            width: parent.width * 0.7 + UM.Theme.getSize("default_margin").width
            anchors.right: parent.right
            style: UM.Theme.styles.sidebar_header_button
            activeFocusOnPress: true;

            menu: MaterialMenu { extruderIndex: base.currentExtruderIndex }
        }
    }

    // Print core row
    Item
    {
        id: printCoreRow
        height: UM.Theme.getSize("sidebar_setup").height
        visible: Cura.MachineManager.hasVariants && !sidebar.monitoringPrint && !sidebar.hideSettings

        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("default_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }

        Text
        {
            id: printCoreLabel
            text: Cura.MachineManager.activeDefinitionVariantsName;
            width: parent.width * 0.45 - UM.Theme.getSize("default_margin").width
            font: UM.Theme.getFont("default");
            color: UM.Theme.getColor("text");
        }

        ToolButton {
            id: printCoreSelection
            text: Cura.MachineManager.activeVariantName
            tooltip: Cura.MachineManager.activeVariantName;
            visible: Cura.MachineManager.hasVariants

            height: UM.Theme.getSize("setting_control").height
            width: parent.width * 0.7 + UM.Theme.getSize("default_margin").width
            anchors.right: parent.right
            style: UM.Theme.styles.sidebar_header_button
            activeFocusOnPress: true;

            menu: NozzleMenu { extruderIndex: base.currentExtruderIndex }
        }
    }

    // Material info row
    Item
    {
        id: materialInfoRow
        height: UM.Theme.getSize("sidebar_setup").height
        visible: (Cura.MachineManager.hasVariants || Cura.MachineManager.hasMaterials) && !sidebar.monitoringPrint && !sidebar.hideSettings

        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("default_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }

        Item
        {
            height: UM.Theme.getSize("sidebar_setup").height
            anchors.right: parent.right
            width: parent.width * 0.7 + UM.Theme.getSize("default_margin").width

            Text
            {
                id: materialInfoLabel
                wrapMode: Text.WordWrap
                text: catalog.i18nc("@label","Check material compability");
                font: UM.Theme.getFont("default");
                verticalAlignment: Text.AlignVCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color:
                {
                    if (!Cura.MachineManager.isActiveQualitySupported)
                    {
                        UM.Theme.getColor("setting_validation_error");
                    }
                    else
                    {
                        UM.Theme.getColor("text");
                    }
                }

                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:
                    {
                        // open the material URL with web browser
                        var version = UM.Application.version;
                        var machineName = Cura.MachineManager.activeMachine.definition.id;

                        var url = "https://ultimaker.com/materialcompatibility/" + version + "/" + machineName;
                        Qt.openUrlExternally(url);
                    }
                    onEntered:
                    {

                        var content = catalog.i18nc("@tooltip", "Click to check the material compatibility on Ultimaker.com.");
                        base.showTooltip(
                            materialInfoRow,
                            Qt.point(-UM.Theme.getSize("default_margin").width, 0),
                            catalog.i18nc("@tooltip", content)
                        );
                    }
                    onExited: base.hideTooltip();
                }
            }

            UM.RecolorImage
            {
                id: warningImage
                anchors.right: parent.right
                anchors.verticalCenter: parent.Bottom
                source: UM.Theme.getIcon("warning")
                width: UM.Theme.getSize("section_icon").width
                height: UM.Theme.getSize("section_icon").height
                //sourceSize.width: width + 5
                //sourceSize.height: width + 5

                color: UM.Theme.getColor("setting_control_text")
                visible: !Cura.MachineManager.isActiveQualitySupported
            }
        }
    }

    UM.SettingPropertyProvider
    {
        id: machineExtruderCount

        containerStackId: Cura.MachineManager.activeMachineId
        key: "machine_extruder_count"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.I18nCatalog { id: catalog; name:"cura" }
}

import QtQuick 2.3
import ToolTip 1.0
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

import "../../../elements"

Rectangle {

	id: top

	// The height adjusts dynamically depending on how many elements there are
	height: Math.max(childrenRect.height,5)
	Behavior on height { NumberAnimation { duration: 150; } }

	// The current key combo is taken from the parent widget
	property string currentKeyCombo: parent.parent.currentKeyCombo
	onCurrentKeyComboChanged: newComboRightHere(currentKeyCombo)

	// the current mouse combo is taken from the parent widget
	property string currentMouseCombo: parent.parent.currentMouseCombo
	onCurrentMouseComboChanged: newMouseComboRightHere(currentMouseCombo)

	// Keys released signals an end to shortcut detection
	property bool keysReleased: parent.parent.keysReleased

	// Mouse combo change cancelled
	property bool mouseCancelled: parent.parent.mouseCancelled

	// An external shortcut shows a TextEdit instead of a title
	property bool external: parent.parent.external

	// These govern the behaviour of the children elements:
	// A new combo was detected and each child checks if they're looking for a new
	// shortcut, and if they do, then they take it
	signal newComboRightHere(var combo)
	// Only one child at a time can detect a shortcut -> starting a new one cancels all others
	signal cancelAllOtherDetection()

	color: "transparent"
	radius: 4
	clip: true

	// The currently set shortcuts
	property var shortcuts: []

	property string lastaction: ""

	GridView {

		id: grid

		x: 3
		y: 3
		width: parent.width-6
		height: shortcuts.length*cellHeight

		cellWidth: parent.width
		cellHeight: 30

		model: shortcuts.length

		delegate: Rectangle {

			id: ele

			x: 3
			y: 3
			width: grid.cellWidth-6
			height: grid.cellHeight-6

			radius: 3
			clip: true

			// Change color when hovered
			property bool hovered: false
			color: hovered ? colour.tiles_inactive : colour.tiles_disabled
			Behavior on color { ColorAnimation { duration: 150; } }

			property bool error_doubleShortcut: false

			// Click on title triggers shortcut detection
			ToolTip {
				cursorShape: shortcuts[index][4] === "key" ? Qt.PointingHandCursor : Qt.ArrowCursor
				text: shortcuts[index][4] === "key" ? "Click to change shortcut" : ""
				onClicked: triggerDetection()
				onEntered: ele.hovered = true
				onExited: ele.hovered = false
			}

			Row {

				x: 4
				y: 2

				// What shortcut this is
				Rectangle {
					height: ele.height-4
					width: ele.width/2-6
					color: "transparent"
					Text {
						id: thetitle
						anchors.fill: parent
						visible: !external
						color: colour.text
						elide: Text.ElideRight
						text: shortcuts[index][0]
					}
					CustomLineEdit {
						id: externalCommand
						anchors.fill: parent
						visible: external
						text: shortcuts[index][0]
						emptyMessage: "The command goes here"
						onTextEdited:
							updateExternalString.restart()
						onClicked:
							tab_top.cancelDetectionEverywhere()
					}
					Timer {
						id: updateExternalString
						interval: 500
						running: false
						repeat: false
						onTriggered: {
							shortcuts[index][0] = externalCommand.getText()
						}
					}
				}

				// The currently set key (split into two parts)
				Rectangle {

					width: (ele.width/2-sh_delete.width)-4
					height: ele.height-4

					color: "transparent"

					// The prefix
					Text {
						id: sh_key_desc
						color: colour.text
						text: shortcuts[index][4] === "key" ? "Key: " : "Mouse: "
					}
					// The current shortcut
					Rectangle {
						color: "transparent"
						anchors.left: sh_key_desc.right
						width: parent.width-sh_key_desc.width
						height: parent.height
						Text {

							id: key_combo

							visible: shortcuts[index][4] === "key"

							// We store the current shortcut in seperate variable. A '...' signals that no shortcut is set (yet)
							property string store: shortcuts[index][1] === "" ? "..." : shortcuts[index][1]

							// This boolean is changed when a new shortcut is requested
							property bool ignoreAllCombos: true
							onIgnoreAllCombosChanged:
								amDetectingANewShortcut = !ignoreAllCombos

							anchors.fill: parent
							color: ele.error_doubleShortcut ? colour.shortcut_double_error : colour.text
							font.bold: ele.error_doubleShortcut
							text: store

							// We update the array with the new data
							onTextChanged: {
								if(!ele.error_doubleShortcut)
									shortcuts[index][1] = text
							}

						}

						Rectangle {

							visible: shortcuts[index][4] === "mouse"

							color: "transparent"
							anchors.fill: parent

							CustomComboBox {
								id: mods
								width: parent.width/2-5
								height: parent.height
								fontsize: 8
								transparentBackground: true
								anchors.left: parent.left
								displayAsError: ele.error_doubleShortcut
								model: ["----", "Ctrl", "Alt", "Shift", "Ctrl+Alt", "Ctrl+Shift", "Alt+Shift", "Ctrl+Alt+Shift"]
								onPressedChanged: if(pressed) triggerDetection()
								Component.onCompleted: {
									if(shortcuts[index][4] === "mouse") {
										for(var i = count-1; i >= 0; --i) {
											var txt = textAt(i)
											if(shortcuts[index][1].slice(0,txt.length) === txt) {
												currentIndex = i
												break;
											}
										}
									}
								}
								onCurrentIndexChanged:
									updateshortcut.restart()
							}

							CustomComboBox {
								id: but
								width: parent.width/2-5
								height: parent.height
								fontsize: 8
								transparentBackground: true
								anchors.left: mods.right
								anchors.leftMargin: 5
								displayAsError: ele.error_doubleShortcut
								model: ["Left Button", "Right Button", "Middle Button", "Wheel Up", "Wheel Down"]
								onPressedChanged: if(pressed) triggerDetection()
								Component.onCompleted: {
									if(shortcuts[index][4] === "mouse") {
										for(var i = count-1; i >= 0; --i) {
											var txt = textAt(i)
											var but = shortcuts[index][1].split("+")
											but = but[but.length-1]
											if(but === txt) {
												currentIndex = i
												break;
											}
										}
									}
								}
								onCurrentIndexChanged:
									updateshortcut.restart()

							}

							// We only do this after 250ms, otherwise when setting it up the default one (index 0) overrides any setting
							Timer {
								id: updateshortcut
								interval: 100
								repeat: false
								running: false
								onTriggered: {
									if(shortcuts[index][4] === "mouse") {

										var composed = ""
										if(mods.currentIndex != 0)
											composed += mods.currentText + "+"
										composed += but.currentText

										// if it was a valid shortcut, we remove it from the list
										if(!ele.error_doubleShortcut)
											deleteAKeyCombo("[M] " + key_combo.store)

										// check if the new key combo already exists
										var found = false;
										for(var i = 0; i < tab_top.usedUpKeyCombos.length; ++i) {
											if(tab_top.usedUpKeyCombos[i] === "[M] " + composed) {
												found = true
												break;
											}
										}

										// if it does, display error
										if(found)
											ele.error_doubleShortcut = true
										// if not, add to the list of set combos
										else {
											ele.error_doubleShortcut = false
											addAKeyCombo("[M] " + composed)
											shortcuts[index][1] = composed
										}
									}
								}
							}

						}
					}

				}

				Text {
					id: sh_delete
					height: ele.height-4
					color: colour.text
					Behavior on color { ColorAnimation { duration: 150; } }
					elide: Text.ElideRight
					text: "x"
					horizontalAlignment: Text.AlignHCenter
					width: 20
					ToolTip {
						cursorShape: Qt.PointingHandCursor
						text: "Delete shortcut"
						onClicked: {
							tab_top.cancelDetectionEverywhere()
							deleteElement.start()
						}
						onEntered: parent.color = colour.warning
						onExited: parent.color = colour.text
					}
				}

			}

			// When requesting a new shortcut, if nothing happens after 2 seconds, then it is cancelled
			Timer {

				id: abortDetection
				interval: 2000
				running: false
				repeat: false
				onTriggered: {

					if(!key_combo.ignoreAllCombos) {

						key_combo.ignoreAllCombos = true
						key_combo.text = key_combo.store
						key_combo.font.italic = false

					}

				}

			}

			Connections {

				target: grid.parent

				// New key combo
				onNewComboRightHere: {

					if(!key_combo.ignoreAllCombos) {

						// if it was a valid shortcut, we remove it from the list
						if(!ele.error_doubleShortcut)
							deleteAKeyCombo(key_combo.store)

						// check if the new key combo already exists
						var found = false;
						for(var i = 0; i < tab_top.usedUpKeyCombos.length; ++i) {
							if(tab_top.usedUpKeyCombos[i] === grid.parent.currentKeyCombo) {
								found = true
								break;
							}
						}

						// if it does, display error
						if(found)
							ele.error_doubleShortcut = true
						// if not, add to the list of set combos
						else {
							ele.error_doubleShortcut = false
							addAKeyCombo(grid.parent.currentKeyCombo)
						}

						abortDetection.stop()
						key_combo.font.italic = true
						key_combo.text = grid.parent.currentKeyCombo


					}

				}

				// Keys released -> key combo possibly finished
				onKeysReleasedChanged: {

					if(!key_combo.ignoreAllCombos) {

						key_combo.ignoreAllCombos = true
						abortDetection.stop()
						key_combo.font.italic = false
						if(key_combo.text.charAt(key_combo.text.length-1) == "+")
							key_combo.text = key_combo.store
						else
							key_combo.store = key_combo.text

					}

				}

				onMouseCancelledChanged: {

					if(!key_combo.ignoreAllCombos) {

						key_combo.ignoreAllCombos = true
						key_combo.text = key_combo.store

					}

				}

				// Another element requested a new shortcut
				onCancelAllOtherDetection: {

					if(!key_combo.ignoreAllCombos) {

						key_combo.ignoreAllCombos = true
						key_combo.text = key_combo.store
						key_combo.font.italic = false

					}

				}

			}

			PropertyAnimation {
				id: deleteElement
				target: ele
				property: "x"
				to: -1.1*ele.width
				duration: 200
				onStopped: {
					var tmp = shortcuts
					tmp.splice(index,1)
					lastaction = "del"
					shortcuts = tmp
				}
			}

			// Cancel all detection anywhere
			Connections {
				target: tab_top
				onCancelDetectionEverywhere: cancelAllOtherDetection()
			}

			function triggerDetection() {

				// Cancel all detection anywhere, in any category
				tab_top.cancelDetectionEverywhere()

				if(shortcuts[index][4] === "key") {
					grid.parent.cancelAllOtherDetection()
					key_combo.text = "... Press keys ..."
					key_combo.font.italic = true
					key_combo.ignoreAllCombos = false
					key_combo.forceActiveFocus()
					abortDetection.restart()
				}

			}

			Component.onCompleted: {
				if(index == shortcuts.length-1 && key_combo.text == "..." && lastaction == "add")
					triggerDetection()
			}

		}

	}

}

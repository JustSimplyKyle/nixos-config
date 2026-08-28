import QtQuick
import Quickshell
import Quickshell.Io
import qs.Widgets

NIconButtonHot {
  id: root

  property ShellScreen screen
  property var pluginApi: null
  property bool fastModeEnabled: false

  icon: fastModeEnabled ? "rocket" : "rocket-off"
  hot: fastModeEnabled
  enabled: !toggleProcess.running
  tooltipText: fastModeEnabled ? "Disable Niri fast mode" : "Enable Niri fast mode"

  onClicked: toggleProcess.running = true

  Component.onCompleted: statusProcess.running = true

  Process {
    id: statusProcess
    command: ["niri-fast-mode", "status"]
    onExited: function(exitCode, stdout, stderr) {
      root.fastModeEnabled = exitCode === 0
    }
  }

  Process {
    id: toggleProcess
    command: ["niri-fast-mode", "toggle"]
    onExited: function(exitCode, stdout, stderr) {
      statusProcess.running = true
    }
  }
}

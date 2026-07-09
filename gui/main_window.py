from qtpy.QtWidgets import QMainWindow, QHBoxLayout, QLabel, QWidget, QPushButton
from monitor_panel import MonitorPanel
from alarm_mem_panel import AlarmMemPanel
from usb_interface import USBInterface
from cdu_control import CDUControl
from dsky import DSKY
import resources

class MainWindow(QMainWindow):
    def __init__(self, parent):
        super().__init__(parent)
        self.setWindowTitle('AGC Monitor')

        # Construct the USB interface thread first, since widgets need to know
        # where to find it
        self._usbif = USBInterface()
        self._usbif.connected.connect(self.connected)

        # Set up the UI
        self._setup_ui()
        self._dsky = DSKY(self, self._usbif)
        self._cdu = CDUControl(self, self._usbif)

    def _setup_ui(self):
        # Create a status bar widget to display connection state
        # FIXME: Replace with an indicator?
        status_bar = self.statusBar()
        self._status = QLabel('')
        status_bar.addWidget(self._status, stretch=1)

        # Create a central widget, give it a layout, and set it up
        central = QWidget(self)
        self.setCentralWidget(central)
        layout = QHBoxLayout(central)
        central.setLayout(layout)
        layout.setSpacing(0)
        layout.setContentsMargins(0,0,0,0)

        self._monitor_panel = MonitorPanel(central, self._usbif)
        layout.addWidget(self._monitor_panel)

        self._alarm_mem_panel = AlarmMemPanel(central, self._usbif)
        layout.addWidget(self._alarm_mem_panel)

        label = QLabel('DSKY')
        font = label.font()
        font.setPointSize(8)
        font.setBold(True)
        label.setFont(font)
        status_bar.addWidget(label)

        button = QPushButton(self)
        button.setFixedSize(20,20)
        status_bar.addWidget(button)
        button.pressed.connect(lambda: self._dsky.show())

        label = QLabel('CDU')
        font = label.font()
        font.setPointSize(8)
        font.setBold(True)
        label.setFont(font)
        status_bar.addWidget(label)

        button = QPushButton(self)
        button.setFixedSize(20,20)
        status_bar.addWidget(button)
        button.pressed.connect(lambda: self._cdu.show())

    def connected(self, connected):
        if connected:
            message = 'Connected!'
        else:
            message = 'Device not found.'

        self._status.setText(message)

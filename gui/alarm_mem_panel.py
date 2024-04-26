from PySide6.QtWidgets import QFrame, QVBoxLayout, QWidget
from PySide6.QtCore import Qt
from core_rope_sim import CoreRopeSim
from erasable_mem_sim import ErasableMemSim
from measurements import Measurements
from alarms import Alarms
from trace import Trace

class AlarmMemPanel(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)

        self._usbif = usbif

        # Set up the UI
        self._setup_ui()

    def _setup_ui(self):
        self.setFrameStyle(QFrame.Panel | QFrame.Raised)
        layout = QVBoxLayout(self)
        self.setLayout(layout)
        layout.setAlignment(Qt.AlignTop)
        layout.setSpacing(2)
        layout.setContentsMargins(2,2,2,2)
        layout.addSpacing(20)

        self._alarms = Alarms(self, self._usbif)
        layout.addWidget(self._alarms)

        self._meas = Measurements(self, self._usbif)
        layout.addWidget(self._meas)

        self._core_rope_sim = CoreRopeSim(self, self._usbif)
        layout.addWidget(self._core_rope_sim)
        layout.setAlignment(self._core_rope_sim, Qt.AlignTop)

        self._erasable_mem_sim = ErasableMemSim(self, self._usbif)
        layout.addWidget(self._erasable_mem_sim)
        layout.setAlignment(self._erasable_mem_sim, Qt.AlignTop)

        self._trace = Trace(self, self._usbif)
        layout.addWidget(self._trace)

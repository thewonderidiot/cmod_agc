from qtpy.QtWidgets import QWidget, QVBoxLayout, QLabel, QRadioButton
from qtpy.QtGui import QFont
from qtpy.QtCore import Qt
import usb_msg as um

class BankS(QWidget):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self._usbif = usbif
        self._setup_ui()
        usbif.connected.connect(self._connected)

    def _connected(self, connected):
        if connected:
            self._set_bank_s()

    def _set_bank_s(self, on=None):
        self._usbif.send(um.WriteControlBankS(self._s_only.isChecked()))

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        self.setLayout(layout)
        layout.setContentsMargins(1,1,1,1)
        layout.setSpacing(1)
        
        layout.addSpacing(50)

        l = QLabel('BANK S', self)
        l.setMinimumHeight(20)
        l.setAlignment(Qt.AlignCenter | Qt.AlignBottom)

        font = l.font()
        font.setPointSize(7)
        font.setBold(True)
        l.setFont(font)
        layout.addWidget(l, Qt.AlignCenter)

        bank_s = QRadioButton(self)
        bank_s.setStyleSheet('QRadioButton::indicator{subcontrol-position:center;}')
        layout.addWidget(bank_s, Qt.AlignTop | Qt.AlignCenter)

        self._s_only = QRadioButton(self)
        self._s_only.setStyleSheet('QRadioButton::indicator{subcontrol-position:center;}')
        self._s_only.toggled.connect(self._set_bank_s)
        layout.addWidget(self._s_only, Qt.AlignTop | Qt.AlignCenter)

        l = QLabel('S ONLY', self)
        l.setAlignment(Qt.AlignCenter | Qt.AlignTop)
        l.setFont(font)
        layout.addWidget(l, Qt.AlignTop | Qt.AlignCenter)

        bank_s.setChecked(True)

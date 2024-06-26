from qtpy.QtWidgets import QWidget, QVBoxLayout, QLabel, QRadioButton
from qtpy.QtGui import QFont
from qtpy.QtCore import Qt
import usb_msg as um

class BankS(QWidget):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        self._usbif = usbif
        self._setup_ui()

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

        s_only = QRadioButton(self)
        s_only.setStyleSheet('QRadioButton::indicator{subcontrol-position:center;}')
        s_only.toggled.connect(lambda s: self._usbif.send(um.WriteControlBankS(s)))
        layout.addWidget(s_only, Qt.AlignTop | Qt.AlignCenter)

        l = QLabel('S ONLY', self)
        l.setAlignment(Qt.AlignCenter | Qt.AlignTop)
        l.setFont(font)
        layout.addWidget(l, Qt.AlignTop | Qt.AlignCenter)

        bank_s.setChecked(True)

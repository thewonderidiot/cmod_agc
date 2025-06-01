from qtpy.QtWidgets import QWidget, QFrame, QGridLayout, QLabel, QLineEdit
from qtpy.QtGui import QFont
from qtpy.QtCore import Qt
import os
import usb_msg as um

class Measurements(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)
        
        self._usbif = usbif

        self._setup_ui()

        usbif.poll(um.ReadStatusMonTemp())
        usbif.poll(um.ReadStatusVccInt())
        usbif.poll(um.ReadStatusVccAux())
        usbif.poll(um.ReadStatusAgcA15())
        usbif.poll(um.ReadStatusAgcA16())
        usbif.listen(self)

    def handle_msg(self, msg):
        if isinstance(msg, um.StatusVccAux):
            self._vccaux.setText('%.02f V' % self._convert_fpga_volts(msg.counts))
        elif isinstance(msg, um.StatusVccInt):
            self._vccint.setText('%.02f V' % self._convert_fpga_volts(msg.counts))
        elif isinstance(msg, um.StatusMonTemp):
            self._mon_temp.setText('%.02f C' % self._convert_mon_temp(msg.counts))
        elif isinstance(msg, um.StatusAgcA15):
            self._agc_a15.setText('%.02f V' % self._convert_agc_volts(msg.counts, 30e3))
        elif isinstance(msg, um.StatusAgcA16):
            self._agc_a16.setText('%.02f V' % self._convert_agc_volts(msg.counts, 13e3))

    def _convert_mon_temp(self, counts):
        # Taken from UG480 p.33
        return ((counts * 503.975) / 4096.0) - 273.15

    def _convert_fpga_volts(self, counts):
        # Taken from UG480 p.34
        return (counts / 4096.0) * 3

    def _convert_agc_volts(self, counts, rin):
        return (counts / 4096.0) * (1000+2320+rin)/1000.0

    def _setup_ui(self):
        self.setFrameStyle(QFrame.Panel | QFrame.Raised)

        layout = QGridLayout(self)
        self.setLayout(layout)
        layout.setContentsMargins(1,1,1,1)
        layout.setHorizontalSpacing(10)
        layout.setVerticalSpacing(1)

        self._create_header('MONITOR', layout, 0)
        self._mon_temp = self._create_meas('TEMP', layout, 1, 0, True)
        self._vccint = self._create_meas('VCCINT', layout, 2, 0, False)
        self._vccaux = self._create_meas('VCCAUX', layout, 3, 0, False)

        self._create_header('AGC', layout, 2)
        self._agc_a15 = self._create_meas('28V', layout, 1, 2, True)
        self._agc_a16 = self._create_meas('14V', layout, 2, 2, False)

        label = QLabel('MEASUREMENTS', self)
        font = label.font()
        font.setPointSize(12)
        font.setBold(True)
        label.setFont(font)
        label.setAlignment(Qt.AlignCenter)
        layout.addWidget(label, 3, 2, 1, 2, Qt.AlignRight)
    
    def _create_header(self, name, layout, col):
        label = QLabel(name, self)
        font = label.font()
        font.setPointSize(10)
        font.setBold(True)
        label.setFont(font)
        layout.addWidget(label, 0, col, 1, 2)
        layout.setAlignment(label, Qt.AlignCenter)

    def _create_meas(self, name, layout, row, col, temp):
        label = QLabel(name, self)
        font = label.font()
        font.setPointSize(8)
        font.setBold(True)
        label.setFont(font)
        layout.addWidget(label, row, col)
        layout.setAlignment(label, Qt.AlignRight)

        meas_value = QLineEdit(self)
        meas_value.setReadOnly(True)
        meas_value.setMaximumSize(72, 32)
        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        font.setPointSize(10)
        meas_value.setFont(font)
        meas_value.setAlignment(Qt.AlignCenter)
        if temp:
            meas_value.setText('0.00 C')
        else:
            meas_value.setText('0.00 V')
        layout.addWidget(meas_value, row, col + 1)
        layout.setAlignment(meas_value, Qt.AlignLeft)

        return meas_value

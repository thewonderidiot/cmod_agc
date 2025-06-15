from qtpy.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QGridLayout, QDoubleSpinBox, QLabel, QLineEdit, QSpacerItem
from qtpy.QtGui import QFont
from qtpy.QtCore import Qt
from phasing import Phasing
from angle import Angle

import usb_msg as um

class CDUControl(QWidget):
    def __init__(self, parent, usbif):
        super().__init__(parent)

        self._usbif = usbif

        self._setup_ui()

        usbif.poll(um.ReadCDUCduX())
        usbif.poll(um.ReadCDUCduY())
        usbif.poll(um.ReadCDUCduZ())
        usbif.poll(um.ReadCDUCduT())
        usbif.poll(um.ReadCDUCduS())
        usbif.poll(um.ReadCDUTLoss())

        usbif.listen(self)

        usbif.connected.connect(self._connected)

    def handle_msg(self, msg):
        if isinstance(msg, um.CDUTLoss):
            self._tloss.setText('%.3f%%' % (100*msg.tloss/65536))
        elif isinstance(msg, um.CDUCduX):
            self._update_angle(0, msg.value)
        elif isinstance(msg, um.CDUCduY):
            self._update_angle(1, msg.value)
        elif isinstance(msg, um.CDUCduZ):
            self._update_angle(2, msg.value)
        elif isinstance(msg, um.CDUCduT):
            self._update_angle(3, msg.value)
        elif isinstance(msg, um.CDUCduS):
            self._update_angle(4, msg.value)

    def _update_angle(self, idx, value):
        angle = 360*(value/0o100000)
        self._angle_displays[idx].setAngle(angle)
        self._angle_texts[idx].setText('%.3f\xB0' % angle)

    def set_phase(self, phase):
        phase = (360 - phase) % 360
        self._usbif.send(um.WriteCDUPhase(int((phase/360)*40000)))

    def _setup_ui(self):
        self.setObjectName('#CDUControl')
        self.setWindowFlags(Qt.Window)
        self.setWindowTitle('CDU Control')

        layout = QVBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(2)

        info = QWidget(self)
        layout.addWidget(info)
        info_layout = QHBoxLayout(info)
        info.setLayout(info_layout)

        label = QLabel('TLOSS', info)
        info_layout.addWidget(label)

        self._tloss = QLineEdit(self)
        self._tloss.setReadOnly(True)
        self._tloss.setMaximumSize(100, 32)
        font = QFont('Monospace')
        font.setStyleHint(QFont.TypeWriter)
        font.setPointSize(10)
        self._tloss.setFont(font)
        self._tloss.setAlignment(Qt.AlignCenter)
        info_layout.addWidget(self._tloss)

        s = QSpacerItem(280, 10)
        info_layout.addItem(s)

        label = QLabel('ATCA Phase', info)
        info_layout.addWidget(label)

        phasebox = QDoubleSpinBox(info)
        info_layout.addWidget(phasebox)
        phasebox.setDecimals(3)
        phasebox.setMinimum(0)
        phasebox.setMaximum(359.991)
        phasebox.setSingleStep(0.009)
        phasebox.setWrapping(True)
        phasebox.setSuffix('\xB0')

        self.phasing = Phasing(self)
        layout.addWidget(self.phasing)
        self.phasing.phaseChanged.connect(self.set_phase)
        self.phasing.phaseChanged.connect(phasebox.setValue)
        phasebox.valueChanged.connect(self.phasing.setPhase)

        angles = QWidget(self)
        angles_layout = QGridLayout(angles)
        angles.setLayout(angles_layout)
        layout.addWidget(angles)

        self._angle_displays = []
        self._angle_texts = []

        for i,name in enumerate(['Outer', 'Inner', 'Middle', 'Trunnion', 'Shaft']):
            row = 2 * (i // 3)
            col = 2 * (i % 3)

            disp = Angle(angles)
            angles_layout.addWidget(disp, row, col, 1, 2)
            self._angle_displays.append(disp)

            label = QLabel(name, angles)
            angles_layout.addWidget(label, row+1, col, 1, 1, Qt.AlignRight)

            text = QLineEdit(self)
            text.setReadOnly(True)
            text.setMaximumSize(100, 32)
            text.setFont(font)
            text.setAlignment(Qt.AlignCenter)
            angles_layout.addWidget(text, row+1, col+1, 1, 1, Qt.AlignLeft)
            self._angle_texts.append(text)

        self.show()

    def _connected(self, connected):
        if connected:
            self.phasing.setPhase(0)

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = CDUControl(None)
    window.show()
    app.exec()


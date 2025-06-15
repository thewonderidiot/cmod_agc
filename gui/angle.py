from qtpy.QtWidgets import QWidget, QSizePolicy
from qtpy.QtGui import QPainter, QColor, QPalette, QPen
from qtpy.QtCore import Qt, QPointF, Signal
from math import *

class Angle(QWidget):
    phaseChanged = Signal(float)

    def __init__(self, parent):
        super().__init__(parent)

        self.setSizePolicy(QSizePolicy.MinimumExpanding, QSizePolicy.MinimumExpanding)
        self.setMinimumSize(200, 200)
        self._angle = 0

    def setAngle(self, angle):
        self._angle = radians(angle % 360)
        self.update()

    def paintEvent(self, e):
        painter = QPainter()
        painter.begin(self)
        painter.setRenderHint(QPainter.Antialiasing, True)

        pen = painter.pen()
        pen.setStyle(Qt.SolidLine)
        pen.setColor(QColor(0xA0, 0xA0, 0xA0))
        pen.setWidth(2)
        painter.setPen(pen)

        r = min(self.height()/2, self.width()/2)-2
        center = QPointF(self.width()/2, self.height()/2)
        painter.drawEllipse(center, r, r)

        pen.setColor(QColor(0x40, 0x40, 0x40))
        painter.setPen(pen)
        painter.drawLine(center, center+QPointF(r*cos(self._angle), -r*sin(self._angle)))

        painter.end()

from qtpy.QtWidgets import QWidget, QSizePolicy
from qtpy.QtGui import QPainter, QColor, QPalette, QPen
from qtpy.QtCore import Qt, QPointF, Signal
from math import *

class Phasing(QWidget):
    phaseChanged = Signal(float)

    def __init__(self, parent):
        super().__init__(parent)

        palette = self.palette()
        palette.setColor(QPalette.Window, QColor(0, 0, 0))
        self.setPalette(palette)
        self.setAutoFillBackground(True)

        self.setSizePolicy(QSizePolicy.MinimumExpanding, QSizePolicy.MinimumExpanding)
        self.setMinimumSize(600, 200)

        self._cycles = 2
        self._phase = 0.0
        self._last_x = None

    def setPhase(self, phase):
        phase = round(phase, 3)
        phase = phase % 360
        phase = (phase + 360) % 360
        phase_rad = radians(phase)
        if phase_rad != self._phase:
            self._phase = phase_rad
            self.phaseChanged.emit(phase)
            self.update()

    def getPhase(self):
        return degrees(self._phase)

    def mousePressEvent(self, event):
        self._last_x = event.pos().x()

    def mouseReleaseEvent(self, event):
        self._last_x = None

    def mouseMoveEvent(self, event):
        if self._last_x is not None:
            new_x = event.pos().x()
            delta = new_x - self._last_x
            self._last_x = new_x
            self.setPhase(self.getPhase()-360*delta*self._cycles/self.width())

    def paintEvent(self, e):
        painter = QPainter()
        painter.begin(self)
        painter.setRenderHint(QPainter.Antialiasing, True)

        pen = painter.pen()
        pen.setStyle(Qt.SolidLine)
        pen.setColor(QColor(0x80, 0x80, 0x80))
        pen.setWidth(2)
        painter.setPen(pen)

        hline = self.height() / 2
        vscale = (self.height()/2)*0.98
        tscale = self._cycles/self.width()

        pgncs_points = []
        for i in range(self.width()):
            pgncs_points.append(QPointF(i, hline-vscale*sin(2*pi*tscale*i)))
        painter.drawPolyline(pgncs_points)

        pen.setColor(QColor(0x00, 0xFF, 0x00))
        painter.setPen(pen)

        atca_points = []
        for i in range(self.width()):
            atca_points.append(QPointF(i, hline-(15/28)*vscale*sin(2*pi*tscale*i + self._phase)))
        painter.drawPolyline(atca_points)

        painter.end()

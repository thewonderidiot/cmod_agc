from qtpy.QtWidgets import QFrame, QHBoxLayout, QVBoxLayout, QWidget, QLabel
from qtpy.QtGui import QColor
from qtpy.QtCore import Qt
from write_w import WriteW
from register import Register
from address_register import AddressRegister
from instruction_register import InstructionRegister
from control import Control
from comp_stop import CompStop
from s_comparator import SComparator
from w_comparator import WComparator
from i_comparator import IComparator
from read_load import ReadLoad
from bank_s import BankS

class MonitorPanel(QFrame):
    def __init__(self, parent, usbif):
        super().__init__(parent)

        self._usbif = usbif

        # Set up the UI
        self._setup_ui()

    def _setup_ui(self):
        self.setFrameStyle(QFrame.Panel | QFrame.Raised)
        layout = QVBoxLayout(self)
        self.setLayout(layout)
        layout.setSpacing(2)

        # Create a horizontal widget to hold the Write W settings on the left, and
        # the computer register displays on the right
        upper_displays = QWidget(self)
        upper_layout = QHBoxLayout(upper_displays)
        upper_displays.setLayout(upper_layout)
        upper_layout.setContentsMargins(0,0,0,0)
        upper_layout.setSpacing(1)
        layout.addWidget(upper_displays)

        self._write_w = WriteW(upper_displays, self._usbif)
        upper_layout.addWidget(self._write_w)
        upper_layout.setAlignment(self._write_w, Qt.AlignRight)

        regs = QWidget(upper_displays)
        regs_layout = QVBoxLayout(regs)
        regs.setLayout(regs_layout)
        regs_layout.setSpacing(2)
        regs_layout.setContentsMargins(0,0,0,0)
        regs_layout.addSpacing(25)
        upper_layout.addWidget(regs)
        upper_layout.setAlignment(regs, Qt.AlignTop)

        # Add all of the registers for display
        self._reg_a = Register(regs, self._usbif, 'A', False, QColor(0,255,0))
        regs_layout.addWidget(self._reg_a)
        regs_layout.setAlignment(self._reg_a, Qt.AlignRight)

        self._reg_l = Register(regs, self._usbif, 'L', False, QColor(0,255,0))
        regs_layout.addWidget(self._reg_l)
        regs_layout.setAlignment(self._reg_l, Qt.AlignRight)

        # self._reg_q = Register(regs, self._usbif, 'Q', False, QColor(0,255,0))
        # regs_layout.addWidget(self._reg_q)
        # regs_layout.setAlignment(self._reg_q, Qt.AlignRight)

        self._reg_z = Register(regs, self._usbif, 'Z', False, QColor(0,255,0))
        regs_layout.addWidget(self._reg_z)
        regs_layout.setAlignment(self._reg_z, Qt.AlignRight)

        # self._reg_b = Register(regs, self._usbif, 'B', False, QColor(0,255,0))
        # regs_layout.addWidget(self._reg_b)
        # regs_layout.setAlignment(self._reg_b, Qt.AlignRight)

        self._reg_g = Register(regs, self._usbif, 'G', True, QColor(0,255,0))
        regs_layout.addWidget(self._reg_g)
        regs_layout.setAlignment(self._reg_g, Qt.AlignRight)

        self._reg_w = Register(regs, self._usbif, 'W', True, QColor(0,255,0))
        regs_layout.addWidget(self._reg_w)
        regs_layout.setAlignment(self._reg_w, Qt.AlignRight)

        self._w_cmp = WComparator(regs, self._usbif)
        regs_layout.addWidget(self._w_cmp)
        regs_layout.setAlignment(self._w_cmp, Qt.AlignRight)

        self._reg_s = AddressRegister(self, self._usbif, QColor(0, 255, 0))
        layout.addWidget(self._reg_s)
        layout.setAlignment(self._reg_s, Qt.AlignRight)

        s_comp_widget = QWidget(self)
        layout.addWidget(s_comp_widget)
        layout.setAlignment(s_comp_widget, Qt.AlignRight)
        s_comp_layout = QHBoxLayout(s_comp_widget)
        s_comp_layout.setContentsMargins(0,0,0,0)
        s_comp_layout.setSpacing(1)

        s1_s2_widget = QWidget(s_comp_widget)
        s_comp_layout.addWidget(s1_s2_widget)
        s_comp_layout.setAlignment(s1_s2_widget, Qt.AlignRight)
        s1_s2_layout = QVBoxLayout(s1_s2_widget)
        s1_s2_layout.setContentsMargins(0,0,0,0)
        s1_s2_layout.setSpacing(1)

        self._s1 = SComparator(s1_s2_widget, self._usbif, 1)
        s1_s2_layout.addWidget(self._s1)
        s1_s2_layout.setAlignment(self._s1, Qt.AlignRight)

        self._s2 = SComparator(s1_s2_widget, self._usbif, 2)
        s1_s2_layout.addWidget(self._s2)
        s1_s2_layout.setAlignment(self._s2, Qt.AlignRight)

        self._bank_s = BankS(s_comp_widget, self._usbif)
        s_comp_layout.addWidget(self._bank_s)
        s_comp_layout.setAlignment(self._bank_s, Qt.AlignTop | Qt.AlignRight)

        self._reg_i = InstructionRegister(self, self._usbif, QColor(0, 255, 0))
        layout.addWidget(self._reg_i)
        layout.setAlignment(self._reg_i, Qt.AlignRight)

        self._i_comp = IComparator(self, self._usbif)
        layout.addWidget(self._i_comp)
        layout.setAlignment(self._i_comp, Qt.AlignRight)

        lower_controls = QWidget(self)
        lower_layout = QHBoxLayout(lower_controls)
        lower_controls.setLayout(lower_layout)
        lower_layout.setContentsMargins(0,0,0,0)
        lower_layout.setSpacing(1)
        layout.addWidget(lower_controls)

        control_stop = QWidget(lower_controls)
        control_stop_layout = QVBoxLayout(control_stop)
        control_stop.setLayout(control_stop_layout)
        control_stop_layout.setSpacing(2)
        control_stop_layout.setContentsMargins(0,0,0,0)
        lower_layout.addWidget(control_stop, Qt.AlignTop)

        # Add the control panel
        self._ctrl_panel = Control(control_stop, self._usbif)
        control_stop_layout.addWidget(self._ctrl_panel)
        control_stop_layout.setAlignment(self._ctrl_panel, Qt.AlignRight)

        # Add the computer stop panel
        self._comp_stop = CompStop(control_stop, self._usbif)
        control_stop_layout.addWidget(self._comp_stop)
        control_stop_layout.setAlignment(self._comp_stop, Qt.AlignRight)

        self._read_load = ReadLoad(self, self._usbif)
        lower_layout.addWidget(self._read_load)
        lower_layout.setAlignment(self._read_load, Qt.AlignTop)

    def connected(self, connected):
        if connected:
            message = 'Connected!'
        else:
            message = 'Device not found.'

        self._status.setText(message)

import warnings
import queue
import time
from ctypes import *
from qtpy.QtCore import QObject, QIODevice, QThread, QTimer, Qt, Signal
from qtpy.QtSerialPort import QSerialPort, QSerialPortInfo

from slip import slip, unslip, unslip_from
import usb_msg as um

POLL_PERIOD_MS = 5

class USBInterface(QObject):
    msg_received = Signal(object)
    connected = Signal(bool)

    def __init__(self):
        QObject.__init__(self)

        self._dev = None

        self._poll_msgs = []
        self._tx_queue = queue.Queue()
        self._rx_bytes = b''
        self._poll_ctr = 0

        self._timer = QTimer(None)
        self._timer.timeout.connect(self._service)
        self._timer.start(POLL_PERIOD_MS)

    def send(self, msg):
        self._tx_queue.put(msg)

    def poll(self, msg):
        if msg not in self._poll_msgs:
            self._poll_msgs.append(msg)

    def listen(self, listener):
        self.msg_received.connect(listener.handle_msg)

    def _enqueue_poll_msgs(self):
        for msg in self._poll_msgs:
            self._tx_queue.put(msg)

    def _service(self):
        if self._dev is None:
            self._connect()
        else:
            self._enqueue_poll_msgs()
            while not self._tx_queue.empty():
                msg = self._tx_queue.get_nowait()
                packed_msg = um.pack(msg)
                slipped_msg = slip(packed_msg)
                try:
                    self._dev.write(slipped_msg)
                except:
                    self._disconnect()
                    return

            try:
                self._rx_bytes += bytes(self._dev.readAll())
            except:
                self._disconnect()
                return

            while self._rx_bytes != b'':
                msg_bytes, self._rx_bytes = unslip_from(self._rx_bytes)
                if msg_bytes == b'':
                    break

                try:
                    msg = um.unpack(msg_bytes)
                except:
                    warnings.warn('Unknown message %s' % msg_bytes)
                    continue

                self.msg_received.emit(msg)

    def _connect(self):
        try:
            dev_info = None
            for info in QSerialPortInfo.availablePorts():
                if ((info.manufacturer() == 'Digilent') and
                    (info.hasVendorIdentifier() and info.vendorIdentifier() == 0x0403) and
                    (info.hasProductIdentifier() and info.productIdentifier() == 0x6010)):
                    dev_info = info


            if dev_info == None:
                raise RuntimeError('Unable to locate serial device!')

            self._dev = QSerialPort(dev_info, self)
            self._dev.setBaudRate(1000000)
            if not self._dev.open(QIODevice.ReadWrite):
                raise RuntimeError('Failed to open %s' % info.name())

            self._dev.errorOccurred.connect(self._error)

            # Mark ourselves connected
            self.connected.emit(True)

        except:
            pass

    def _error(self, error):
        self._disconnect()

    def _disconnect(self):
        self._dev.close()
        # self._dev.setParent(None)
        # self._dev.deleteLater()
        self.connected.emit(False)
        self._dev = None

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles, Lock
import random

class Registers(object):
    def __init__(self, dut):
        self.dut = dut
        self.lock = Lock()
        self.dut.USB_RDn.value = 1
        self.dut.USB_WRn.value = 1
        self.dut.USB_CEn.value = 1

    async def setup_rw_address(self, address):
        self.dut.USB_CEn.value = 1
        self.dut.USB_Addr_Bytecount.value = 0
        await ClockCycles(self.dut.clk_usb, 1)
        self.dut.USB_Addr.value = address
        await ClockCycles(self.dut.clk_usb, 3)


    async def write(self, address, data):
        await self.lock.acquire()
        try:
            await self.setup_rw_address(address)
            for i in range(len(data)):
                self.dut.USB_Data.value = data[i]
                self.dut.USB_WRn.value = 0
                await ClockCycles(self.dut.clk_usb, 1)
                self.dut.USB_WRn.value = 1
                self.dut.USB_CEn.value = 0
                await ClockCycles(self.dut.clk_usb, 1)
                self.dut.USB_CEn.value = 1
                await ClockCycles(self.dut.clk_usb, 2)
                self.dut.USB_Addr_Bytecount.value = self.dut.USB_Addr_Bytecount.value + 1
        finally:
            self.dut.w.value = 0
            self.lock.release()

    async def read(self, address, size=1):
        data = []
        await self.lock.acquire()
        try:
            await self.setup_rw_address(address)
            for i in range(size):
                data.append(await self.read_next_byte())
        finally:
            self.lock.release()
        return bytearray(data)

    async def read_next_byte(self):
        self.dut.USB_RDn.value = 0
        self.dut.USB_CEn.value = 0
        await ClockCycles(self.dut.clk_usb, 1)
        self.dut.USB_CEn.value = 1
        await ClockCycles(self.dut.clk_usb, 2)
        rdata = self.dut.USB_Data.value
        self.dut.USB_RDn.value = 1
        await ClockCycles(self.dut.clk_usb, 1)
        await ClockCycles(self.dut.clk_usb, 2) # TODO: extra cycles here are to accomodate CW310
        self.dut.USB_Addr_Bytecount.value = (self.dut.USB_Addr_Bytecount.value + 1) % 128
        return rdata

    def to_bytes(self, data, size):
        return list(int.to_bytes(data, length=size, byteorder='little'))

    def from_bytes(self, data):
        return int.from_bytes(data, byteorder='little')




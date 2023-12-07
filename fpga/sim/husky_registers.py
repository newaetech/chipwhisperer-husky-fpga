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

    async def setup_rw_address(self, address) -> None:
        self.dut.USB_CEn.value = 1
        self.dut.USB_Addr.value = address
        self.dut.USB_ALEn.value = 0
        await ClockCycles(self.dut.clk_usb, 1)
        self.dut.USB_ALEn.value = 1
        await ClockCycles(self.dut.clk_usb, 1)


    async def write(self, address, data) -> None:
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
                await ClockCycles(self.dut.clk_usb, 1)
        finally:
            self.dut.w.value = 0
            self.lock.release()

    async def read(self, address, size=1) -> bytearray:
        data = []
        await self.lock.acquire()
        try:
            await self.setup_rw_address(address)
            for i in range(size):
                data.append(await self.read_next_byte())
        finally:
            self.lock.release()
        return bytearray(data)

    async def read_next_byte(self) -> int:
        self.dut.USB_RDn.value = 0
        self.dut.USB_CEn.value = 0
        await ClockCycles(self.dut.clk_usb, 1)
        self.dut.USB_CEn.value = 1
        await ClockCycles(self.dut.clk_usb, 2)
        rdata = self.dut.USB_Data.value
        self.dut.USB_RDn.value = 1
        await ClockCycles(self.dut.clk_usb, 1)
        return rdata

    def to_bytes(self, data, size) -> list:
        return list(int.to_bytes(data, length=size, byteorder='little'))

    def from_bytes(self, data) -> int:
        return int.from_bytes(data, byteorder='little')




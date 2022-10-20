import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles, Lock
import random

class Registers(object):
    def __init__(self, dut):
        self.dut = dut
        self.lock = Lock()
        self.rdata_r = None
        self.i12BitReadCount = False

    async def setup_rw_address(self, address):
        self.dut.USB_CEn.value = 1
        self.dut.USB_Addr_Bytecount.value = 0
        await ClockCycles(self.dut.clk_usb, 1)
        self.dut.USB_Addr.value = address
        await ClockCycles(self.dut.clk_usb, 3)


    async def write(self, address, data, size=1):
        await self.lock.acquire()
        try:
            await self.setup_rw_address(address)
            for i in range(size):
                self.dut.USB_Data.value = data & 0xff
                self.dut.USB_WRn.value = 0
                await ClockCycles(self.dut.clk_usb, 1)
                self.dut.USB_WRn.value = 1
                self.dut.USB_CEn.value = 0
                await ClockCycles(self.dut.clk_usb, 1)
                self.dut.USB_CEn.value = 1
                await ClockCycles(self.dut.clk_usb, 2)
                data = data >> 8
                self.dut.USB_Addr_Bytecount.value = self.dut.USB_Addr_Bytecount.value + 1
        finally:
            self.dut.w.value = 0
            self.lock.release()

    async def read(self, address, size=1):
        await self.lock.acquire()
        try:
            await self.setup_rw_address(address)
            data = 0
            for i in range(size):
                rdata = await self.read_next_byte()
                data |= rdata << (8*i)
        finally:
            self.lock.release()
        return data

    async def read_next_byte(self):
        self.dut.USB_RDn.value = 0
        self.dut.USB_CEn.value = 0
        await ClockCycles(self.dut.clk_usb, 1)
        self.dut.USB_CEn.value = 1
        await ClockCycles(self.dut.clk_usb, 2)
        rdata = self.dut.USB_Data.value
        self.dut.USB_RDn.value = 1
        await ClockCycles(self.dut.clk_usb, 1)
        self.dut.USB_Addr_Bytecount.value = self.dut.USB_Addr_Bytecount.value + 1
        return rdata

    async def read_next_sample(self, lowres):
        if lowres:
            sample = await self.read_next_byte()
        else:
            if not self.i12BitReadCount:
                rdata_r = await self.read_next_byte();
                rdata = await self.read_next_byte();
                self.rdata_r = rdata
                sample = (rdata_r << 4) + (rdata >> 4)
            else:
                rdata = await self.read_next_byte();
                sample = ((self.rdata_r[3:0] & 0x0f) << 8) + rdata
            self.i12BitReadCount = not self.i12BitReadCount
        return sample

    async def read_samples_init(self):
        await self.lock.acquire()
        await self.setup_rw_address(3)

    async def read_samples_done(self):
        self.lock.release()



# Copyright (c) 2023-2024, NewAE Technology Inc
# All rights reserved.
#
# Find this and more at newae.com - this file is part of the chipwhisperer
# project, http://www.chipwhisperer.com . ChipWhisperer is a registered
# trademark of NewAE Technology Inc in the US & Europe.
#
#    This file is part of chipwhisperer.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

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


    async def write(self, address, data, wait=None) -> None:
        await self.lock.acquire()
        try:
            await RisingEdge(self.dut.clk_usb) # ensure all that follows is sync'd to clock
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
                if wait:
                    await ClockCycles(self.dut.clk_usb, wait)
        finally:
            self.lock.release()

    async def read(self, address, size=1) -> bytearray:
        data = []
        await self.lock.acquire()
        try:
            await self.setup_rw_address(address)
            for i in range(size):
                rdata = await self.read_next_byte()
                if not rdata.is_resolvable:
                    self.dut._log.warning('read unresolvable data from address %0x, byte %d: %s' % (address, i, rdata))
                data.append(rdata)
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




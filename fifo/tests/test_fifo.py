import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
import random
import math

TICK = 20000

@cocotb.test()
def fifo_basic_test(dut):
    """put in a 1, see if it comes out later"""

    dut.reset = 0;
    dut.data_in = 0;
    dut.clk = 0
    yield Timer(TICK)
    dut.clk = 1
    yield Timer(TICK)

    dut.reset = 1;
    for i in range(10):
        dut.clk = 0
        yield Timer(TICK)
        dut.clk = 1
        yield Timer(TICK)

    if int(dut.data_out) != 0:
        raise TestFailure("Incorrect data coming out of the fifo")

@cocotb.test()
def fifo_sequence_test(dut):
    """put in a 1, see if it comes out later"""

    dut.reset = 0;
    dut.data_in = 0;
    dut.clk = 0
    yield Timer(TICK)
    dut.clk = 1
    yield Timer(TICK)

    dut.reset = 1;
    for i in range(10):
        dut.data_in = i
        dut.clk = 0
        yield Timer(TICK)
        dut.clk = 1
        yield Timer(TICK)

    for i in range(10):       
        if int(dut.data_out) != i:
            raise TestFailure("Incorrect data coming out of the fifo")
            
        dut.clk = 0
        yield Timer(TICK)
        dut.clk = 1
        yield Timer(TICK)
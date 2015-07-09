
import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
import random
import math

TICK = 1
INPUT_WIDTH = 28

@cocotb.test()
def sqrt_basic_test(dut):
    """Test for sqrt(127)"""
    i = 127

    dut.integer_input = i
    dut.remainder_previous = 0;
    dut.result_previous = 0;
    dut.reset = 0
    dut.clk = 0
    yield Timer(TICK)
    dut.clk = 1
    yield Timer(TICK)
    dut.clk = 0
    yield Timer(TICK)
    dut.reset = 1
    yield Timer(TICK)

    # for _ in range(int(INPUT_WIDTH/2)+2):

    for k in range(10):
        dut.clk = 0
        yield Timer(TICK)
        dut.clk = 1
        yield Timer(TICK)

        if k % 2 == 0:
            dut.integer_input = 0
        else:
            dut.integer_input = i

    # dut.clk = 0
    # yield Timer(TICK)
    # dut.clk = 1
    # yield Timer(TICK)

    # dut.integer_input = i

    # dut.clk = 0
    # yield Timer(TICK)
    # dut.clk = 1
    # yield Timer(TICK)

    # integer_sqrt = int(math.sqrt(i))
    # remainder = int(i - integer_sqrt**2)

    if int(dut.result) != 1 or int(dut.remainder) != 0:
        raise TestFailure(
            "sqrt is incorrect for %i; r: %s, q: %s" % (i, int(dut.remainder), int(dut.result))) 
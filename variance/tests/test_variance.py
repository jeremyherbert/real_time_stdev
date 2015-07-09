import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
import random
import math
import numpy as np

TICK = 1

def integer_variance(integers):
    raw_style = int(np.sum(integers**2)>>7) - int((np.sum(integers)>>7)**2)
    return raw_style

@cocotb.test()
def variance_basic_test(dut):
    integers = np.random.randint(0, (2**14)-1, 128)

    # reset
    dut.reset = 0;
    dut.data_in = 0;
    dut.clk = 0
    yield Timer(TICK)
    dut.clk = 1
    yield Timer(TICK)
    dut.reset = 1;

    # feed in 100 integers
    for i in range(128):
        dut.data_in = int(integers[i])
        dut.clk = 0
        yield Timer(TICK)
        dut.clk = 1
        yield Timer(TICK)

    for i in range(7):
        dut.clk = 0
        yield Timer(TICK)
        dut.clk = 1
        yield Timer(TICK)

    integer_var = integer_variance(integers)

    # np_var = int(np.mean(integers**2)) - int(np.mean(integers)**2)
    # print("first integer was", hex(integers[0]))
    # print("integer sum was", hex(np.sum(integers)))
    # print("integer square sum was", hex(np.sum(integers**2)))
    # print("mean was", hex(int(np.mean(integers))))
    # print("mean of squares was", hex(int(np.mean(integers**2))))
    # print("integer variance was", integer_var, " (hex: %s)" % hex(integer_var))
    # print("numpy variance was", np_var)
    # print("variance needs", np.log(integer_variance(integers))/np.log(2), "bits")

    if int(dut.data_out) != integer_var:
        raise TestFailure("variance output was wrong; got %i, expected %i" % (int(dut.data_out), integer_variance(integers)))

    # one more clock
    dut.clk = 0
    yield Timer(TICK)
    dut.clk = 1
    yield Timer(TICK)
    integer_var = integer_variance(np.append(integers[1:], integers[-1]))
    if int(dut.data_out) != integer_var:
        raise TestFailure("variance output was wrong; got %i, expected %i" % (int(dut.data_out), integer_variance(integers)))
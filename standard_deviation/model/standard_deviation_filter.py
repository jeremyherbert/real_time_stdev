import numpy as np


def rolling_window(a, window):
    shape = a.shape[:-1] + (a.shape[-1] - window + 1, window)
    strides = a.strides + (a.strides[-1],)
    return np.lib.stride_tricks.as_strided(a, shape=shape, strides=strides)


def standard_deviation_filter(input_data, window_size):
	return np.array(np.std(rolling_window(input_data, window_size), 1), dtype=np.uint64)


if __name__ == "__main__":
	window_size = 128

	data = np.append(np.zeros(window_size*2), np.ones(window_size*2)*(2**14-1))
	result = standard_deviation_filter(data, window_size) 

	import matplotlib.pyplot as plt
	plt.plot(result)
	plt.show()
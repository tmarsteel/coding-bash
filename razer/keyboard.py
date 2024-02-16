#!/usr/bin/python3

import openrazer.client
import subprocess
import json
import sys
import time
import colorsys
import random

color_left = (3, 252, 180)
color_right = (252, 80, 3)
color_temperature = (200, 0, 0)
color_locked = (0, 0, 0)
color_locked_escape_key = (255, 0, 0)

def main(n_minutes):
	devman = openrazer.client.DeviceManager()
	devman.sync_effects = False
	devices = list(
		filter(lambda d: d.has('keyboard_layout'), devman.devices)
	)

	if len(devices) == 0:
		print("[ERRO] No razer keyboards found")
		return
	if len(devices) > 1:
	  print("[WARN] Found multiple razer keyboards. Updating the first reported by the driver.")

	if n_minutes is None:
		update_coloring(devices[0])
	else:
		for i in range((n_minutes * 30) - 1):
			update_coloring(devices[0])
			time.sleep(2)

def update_coloring(keyboard):
	temp_rel = get_temperature_relative()

	rows, cols = keyboard.fx.advanced.rows, keyboard.fx.advanced.cols
	indicators = [
		[5, 0],
		[4, 0],
		[3, 0],
		[2, 0],
		[1, 0]
	]

	screen_locked = is_screen_locked()

	for row in range(rows):
		for col in range(cols):
			keyboard.fx.advanced.matrix[row, col] = base_color_of_key(row, col, screen_locked)

	# disable razer logo
	# keyboard.fx.advanced.matrix[0, cols - 2] = (0, 0, 0)

	if screen_locked:
		keyboard.brightness = 100
		keyboard.fx.advanced.draw()
		return

	keyboard.brightness = 70

	temp_per_indicator = 1 / len(indicators)
	temp_remain = temp_rel
	indicator_index = 0
	for indicator in indicators:
		base_color = base_color_of_key(indicator[0], indicator[1], screen_locked)
		if temp_remain >= temp_per_indicator:
			keyboard.fx.advanced.matrix[indicator[0], indicator[1]] = color_temperature
		elif temp_remain > 0:
			tip_amount = temp_remain / temp_per_indicator
			tip_color = mix_colors(base_color, color_temperature, tip_amount)
			keyboard.fx.advanced.matrix[indicator[0], indicator[1]] = tip_color
		else:
			keyboard.fx.advanced.matrix[indicator[0], indicator[1]] = base_color

		indicator_index += 1
		temp_remain -= temp_per_indicator

	keyboard.fx.advanced.draw()

def get_temperature_relative():
	temperatures = get_temperatures()
	cpu_min = 40
	cpu_max = 105
	cpu_current = temperatures['k10temp-pci-00c3']['Tctl']['input']
	cpu_rel = (cpu_current - cpu_min) / (cpu_max - cpu_min)

	gpu_current = temperatures['nvidia-smi']['temp']['input']
	gpu_min = 40
	gpu_max = 75
	gpu_rel = (gpu_current - gpu_min) / (gpu_max - gpu_min)

	print(f"gpu: {gpu_current}, cpu: {cpu_current}")

	return max(gpu_rel, cpu_rel);

def get_temperatures():
	output = subprocess.check_output(['sensors', '-u', '-A']).decode("utf-8").split('\n')
	result = dict()

	device = dict()
	device_name = None
	sensor = dict()
	sensor_name = None
	for line in output:
		if line.strip() == '':
			if sensor_name is not None:
				device[sensor_name] = sensor
				sensor = dict()
				sensor_name = None

			if device_name is not None:
				result[device_name] = device

			device = dict()
			device_name = None
		elif device_name is None:
			device_name = line.strip()
		elif line.endswith(':'):
			if sensor_name is not None:
				device[sensor_name] = sensor
			sensor = dict()
			sensor_name = line[:-1].strip()
		else:
			parts = line.split(':')
			metric_name = parts[0].strip().split('_')[1]
			metric_value = float(parts[1].strip())
			sensor[metric_name] = metric_value

	try:
		nvidiaSMIOutput = subprocess.check_output(['nvidia-smi', '--query-gpu=temperature.gpu', '--format=csv,noheader']).decode("UTF-8")
	except:
		nvidiaSMIOutput = "25.0"

	result['nvidia-smi'] = {
		'temp': {
			'input': float(nvidiaSMIOutput)
		}
	}

	return result


def is_screen_locked():
	try:
		result = subprocess.check_output(['gnome-screensaver-command', '--query']).decode('utf-8').lower()
		deactivated = ('inactive' in result) or ('is not' in result)
		return not deactivated;
	except FileNotFoundError:
		return False


def base_color_of_key(row, col, is_screen_locked):
	if is_screen_locked:
		if row == 0 and col == 1:
			return color_locked_escape_key
		return color_locked

	divides = {
		0: 9,
		1: 10,
		2: 10,
		3: 10,
		4: 11,
		5: 11
	}

	if row in divides and col <= divides[row]:
		return mix_colors(
			color_left,
			(0, 0, 0),
			1 - ((row + 1) / 7)
		)

	return mix_colors(
		color_right,
		(0, 0, 0),
		(row + 1) / 7
	)


def mix_colors(color_a, color_b, color_b_ratio):
	weighed_diff = (
		(color_b[0] - color_a[0]) * color_b_ratio,
		(color_b[1] - color_a[1]) * color_b_ratio,
		(color_b[2] - color_a[2]) * color_b_ratio
	)
	return (
		color_a[0] + weighed_diff[0],
		color_a[1] + weighed_diff[1],
		color_a[2] + weighed_diff[2],
	)


if __name__ == "__main__":
	if len(sys.argv) > 1:
		main(int(sys.argv[1]))
	else:
		main(None)


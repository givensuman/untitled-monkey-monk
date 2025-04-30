extends Node

var total_bananas := 3
var collected_bananas := 0

func collect_banana():
	collected_bananas += 1
	print("Bananas collected: %d/%d" % [collected_bananas, total_bananas])

func all_bananas_collected():
	if collected_bananas >= total_bananas:
		return true

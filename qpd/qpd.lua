local qpd = {}

qpd.ann = require "qpd.ann"
qpd.array = require "qpd.array"
qpd.camera = require "qpd.camera"
qpd.collision = require "qpd.collision"
qpd.color = require "qpd.color"
qpd.gamestate = require "qpd.gamestate"
qpd.grid = require "qpd.grid"
qpd.matrix = require "qpd.matrix"
qpd.point = require "qpd.point"
qpd.tilemap_view = require "qpd.tilemap_view"
qpd.tilemap = require "qpd.tilemap"
qpd.random = require "qpd.random"
qpd.table = require "qpd.table"
qpd.timer = require "qpd.timer"
qpd.value = require "qpd.value"

qpd.files = require "qpd.services.files"
qpd.fonts = require "qpd.services.fonts"
qpd.keymap = require "qpd.services.keymap"
qpd.strings = require "qpd.services.strings"
qpd.window = require "qpd.services.window"

qpd.cell_box = require "qpd.widgets.cell_box"
qpd.file_picker = require "qpd.widgets.file_picker"
qpd.fps = require "qpd.widgets.fps"
qpd.grid_selector = require "qpd.widgets.grid_selector"
qpd.particle = require "qpd.widgets.particle"
qpd.selection_box = require "qpd.widgets.selection_box"
qpd.text_box= require "qpd.widgets.text_box"

qpd.cell_color = require "qpd.cells.color"
qpd.cell_sprite = require "qpd.cells.sprite"

function qpd.run_tests()
	print("Starting qpd.utils.run_tests()")

	-- test clamp
	assert(
		qpd.value.clamp(5, 1, 10) == 5,
		"error on qpd.value.clamp, test 1")
	assert(
		qpd.value.clamp(0, 1, 10) == 1,
		"error on qpd.value.clamp, test 2")
	assert(
		qpd.value.clamp(11, 1, 10) == 10,
		"error on qpd.value.clamp, test 3")

	-- test normalize
	local x, y = qpd.point.normalize(1, 1)
	assert(
		x == 1/(2^(1/2)) and y == 1/(2^(1/2)),
		"error on qpd.point.normalize, test 1")

	local x, y = qpd.point.normalize(-1, 2)
	assert(
		x == -1/(5^(1/2)) and y == 2/(5^(1/2)),
		"error on qpd.point.normalize, test 2")

	local x, y = qpd.point.normalize(100, -1)
	assert(
		x == 100/(10001^(1/2)) and y == -1/(10001^(1/2)),
		"error on qpd.point.normalize, test 3")

	local x, y = qpd.point.normalize(-10, -10)
	assert(
		x == -10/(200^(1/2)) and y == -10/(200^(1/2)),
		"error on qpd.point.normalize, test 4")

	local x, y = qpd.point.normalize(0, 0)
	assert(
		x == 0 and y == 0,
		"error on qpd.point.normalize, test 5")

	local x, y = qpd.point.normalize(0, 1)
	assert(
		x == 0 and y == 1,
		"error on qpd.point.normalize, test 6")

	-- test max
	assert(
		qpd.value.max(5, 1) == 5,
		"error on qpd.value.max, test 1")
	assert(
		qpd.value.max(1, 5) == 5,
		"error on qpd.value.max, test 2")
	assert(
		qpd.value.max(-5, 1) == 1,
		"error on qpd.value.max, test 3")
	assert(
		qpd.value.max(1, -5) == 1,
		"error on qpd.value.max, test 4")
	assert(
		qpd.value.max(-5, -1) == -1,
		"error on qpd.value.max, test 5")
	assert(
		qpd.value.max(-1, -5) == -1,
		"error on qpd.value.max, test 6")

	-- test min
	assert(
		qpd.value.min(5, 1) == 1,
		"error on qpd.value.min, test 1")
	assert(
		qpd.value.min(1, 5) == 1,
		"error on qpd.value.min, test 2")
	assert(
		qpd.value.min(-5, 1) == -5,
		"error on qpd.value.min, test 3")
	assert(
		qpd.value.min(1, -5) == -5,
		"error on qpd.value.min, test 4")
	assert(
		qpd.value.min(-5, -1) == -5,
		"error on qpd.value.min, test 5")
	assert(
		qpd.value.min(-1, -5) == -5,
		"error on qpd.value.min, test 6")

	-- test round_to_dec
	assert(
		qpd.value.round_to_dec(5) == 5,
		"error on qpd.value.round_to_dec, test 1")
	assert(
		qpd.value.round_to_dec(5.12345) == 5.12,
		"error on qpd.value.round_to_dec, test 2")
	assert(
		qpd.value.round_to_dec(5.125) == 5.13,
		"error on qpd.value.round_to_dec, test 3")

	assert(
		qpd.value.round_to_dec(-5) == -5,
		"error on qpd.value.round_to_dec, test 4")
	assert(
		qpd.value.round_to_dec(-5.12345) == -5.12,
		"error on qpd.value.round_to_dec, test 5")
	assert(
		qpd.value.round_to_dec(-5.125) == -5.13,
		"error on qpd.value.round_to_dec, test 6")

	assert(
		qpd.value.round_to_dec(5.124999999999999) == 5.12,
		"error on qpd.value.round_to_dec, test 7")
	assert(
		qpd.value.round_to_dec(5.125000000000000000000000000000000000000) == 5.13,
		"error on qpd.value.round_to_dec, test 8")

	-- test number_to_bool
	assert(
		qpd.value.number_to_bool(0) == false,
		"error on qpd.value.number_to_bool, test 1")
	assert(
		qpd.value.number_to_bool(1) == true,
		"error on qpd.value.number_to_bool, test 2")
	assert(
		qpd.value.number_to_bool(5) == nil,
		"error on qpd.value.number_to_bool, test 3")

	-- test string_to_bool
	assert(
		qpd.value.string_to_bool("false") == false,
		"error on qpd.value.string_to_bool, test 1")
	assert(
		qpd.value.string_to_bool("true") == true,
		"error on qpd.value.string_to_bool, test 2")
	assert(
		qpd.value.string_to_bool(5) == nil,
		"error on qpd.value.string_to_bool, test 3")
	assert(
		qpd.value.string_to_bool(true) == nil,
		"error on qpd.value.string_to_bool, test 4")
	assert(
		qpd.value.string_to_bool("Zaratrusta") == nil,
		"error on qpd.value.string_to_bool, test 5")

	-- test string_maybe_bool
	assert(
		qpd.value.string_maybe_bool("false") == false,
		"error on qpd.value.string_maybe_bool, test 1")
	assert(
		qpd.value.string_maybe_bool("true") == true,
		"error on qpd.value.string_maybe_bool, test 2")
	assert(
		qpd.value.string_maybe_bool(5) == 5,
		"error on qpd.value.string_maybe_bool, test 3")
	assert(
		qpd.value.string_maybe_bool(true) == true,
		"error on qpd.value.string_maybe_bool, test 4")
	assert(
		qpd.value.string_maybe_bool("Zaratrusta") == "Zaratrusta",
		"error on qpd.value.string_maybe_bool, test 5")

	-- check_quad() is just a wrapper for check()
	local A = {x = 0, y = 0, w = 1, h = 1}
	local B = {x = 0.5, y = 0.5, w = 1, h = 1}
	local C = {x = -0.5, y = -0.5, w = 1, h = 1}
	local D = {x = 1, y = 1, w = 1, h = 1}
	assert(
		qpd.collision.check_quad(A, B) == true,
		"error on qpd.collision.check, test 1")
	assert(
		qpd.collision.check_quad(B, C) == true,
		"error on qpd.collision.check, test 2")
	assert(
		qpd.collision.check_quad(C, D) == false,
		"error on qpd.collision.check, test 3")

	-- if we got here maybe things are ok
	print("qpd.run_tests() says ok!")
end

return qpd
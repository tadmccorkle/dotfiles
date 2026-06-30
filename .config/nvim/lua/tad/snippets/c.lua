require("luasnip.session.snippet_collection").clear_snippets("c")

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta

local snippets = {
	s(
		"$ig",
		fmta(
			[[
			#ifndef <>_H
			#define <>_H

			<>

			#endif // <>_H
			]],
			{ i(1), rep(1), i(0), rep(1) }
		)
	),
	s(
		"$tde",
		fmta(
			[[
			typedef enum
			{
				<>_<>,
			} <>;
			]],
			{ rep(1), i(2), i(1) }
		)
	),
	s(
		"$tdec",
		fmta(
			[[
			typedef enum
			{
				<>_<>,
				<>_COUNT,
			} <>;
			]],
			{ rep(1), i(2), rep(1), i(1) }
		)
	),
	s(
		"$tds",
		fmta(
			[[
			typedef struct <> <>;
			struct <>
			{
				<>
			};
			]],
			{ rep(1), rep(1), i(1), i(2) },
			{ indent_string = "  " }
		)
	),
	s(
		"$section",
		fmta([[
			// ]] .. ("="):rep(61) .. [[

			// <>
			]], { i(1) }, { indent_string = "  " })
	),
}

ls.add_snippets("c", snippets)
ls.add_snippets("cpp", snippets)
